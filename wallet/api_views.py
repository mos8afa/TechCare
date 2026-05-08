from decimal import Decimal, InvalidOperation

from drf_spectacular.utils import extend_schema, OpenApiParameter, OpenApiExample
from rest_framework import status
from rest_framework.decorators import api_view, permission_classes, throttle_classes
from rest_framework.permissions import IsAuthenticated, IsAdminUser
from rest_framework.response import Response

from .api_response import (
    success_response, created_response, error_response,
    not_found_response, no_content_response,
)
from .models import Wallet, Transaction, LedgerEntry, SavedCard, Notification
from .pagination import WalletPageNumberPagination
from .permissions import IsWalletOwner, IsWalletActive, IsProvider, IsConsumer
from .serializers import (
    WalletSerializer, TransactionSerializer, LedgerEntrySerializer,
    DepositRequestSerializer, WithdrawRequestSerializer,
    SavedCardSerializer, NotificationSerializer,
    AnalyticsSummarySerializer,
)
from .throttles import DepositThrottle, WithdrawThrottle, WalletReadThrottle
from .services import (
    create_deposit_request, approve_deposit_request,
    create_withdraw_request, approve_withdraw_request,
    get_dashboard_summary, get_monthly_deposits,
    get_monthly_spending, get_weekly_stats,
    get_provider_earnings, reconcile_wallet_balance,
)


# ─────────────────────────────────────────────
#  Internal helper
# ─────────────────────────────────────────────

def _get_wallet(user) -> Wallet:
    wallet, _ = Wallet.objects.get_or_create(user=user)
    return wallet


# ─────────────────────────────────────────────
#  Wallet summary
# ─────────────────────────────────────────────

@extend_schema(
    tags=['Wallet'],
    summary='Get wallet summary',
    description='Returns the authenticated user\'s wallet balance, totals, and recent analytics.',
    responses={200: WalletSerializer},
)
@api_view(['GET'])
@permission_classes([IsAuthenticated, IsWalletActive])
@throttle_classes([WalletReadThrottle])
def api_wallet_me(request):
    wallet = _get_wallet(request.user)
    role   = getattr(request.user, 'role', '')

    wallet_data = WalletSerializer(wallet).data

    # Attach role-specific analytics
    if role in ('doctor', 'nurse'):
        wallet_data['analytics'] = get_provider_earnings(wallet)
    else:
        summary = get_dashboard_summary(wallet)
        wallet_data['analytics'] = {
            'month_deposits': summary['month_deposits'],
            'month_payments': summary['month_payments'],
            'last_30_spent':  summary['last_30_spent'],
        }

    return success_response(wallet_data, 'Wallet retrieved successfully.')


# ─────────────────────────────────────────────
#  Transactions
# ─────────────────────────────────────────────

@extend_schema(
    tags=['Transactions'],
    summary='List transactions',
    description='Paginated, filterable transaction history for the authenticated user.',
    parameters=[
        OpenApiParameter('type',     description='Filter by type (deposit/withdraw/payment/refund)', required=False),
        OpenApiParameter('status',   description='Filter by status (pending/completed/failed)',      required=False),
        OpenApiParameter('ordering', description='Order by field (e.g. -created_at)',                required=False),
        OpenApiParameter('page',     description='Page number',                                      required=False),
        OpenApiParameter('page_size',description='Results per page (max 100)',                       required=False),
    ],
    responses={200: TransactionSerializer(many=True)},
)
@api_view(['GET'])
@permission_classes([IsAuthenticated, IsWalletActive])
@throttle_classes([WalletReadThrottle])
def api_transactions(request):
    wallet = _get_wallet(request.user)
    qs     = wallet.transactions.all()

    # Filtering
    tx_type   = request.query_params.get('type')
    tx_status = request.query_params.get('status')
    ordering  = request.query_params.get('ordering', '-created_at')

    if tx_type:
        qs = qs.filter(transaction_type=tx_type)
    if tx_status:
        qs = qs.filter(status=tx_status)

    # Ordering (whitelist safe fields)
    safe_orderings = {
        'created_at', '-created_at', 'amount', '-amount',
        'transaction_type', '-transaction_type',
    }
    if ordering in safe_orderings:
        qs = qs.order_by(ordering)

    # Pagination
    paginator = WalletPageNumberPagination()
    page = paginator.paginate_queryset(qs, request)
    serializer = TransactionSerializer(page, many=True)
    return paginator.get_paginated_response(serializer.data)


# ─────────────────────────────────────────────
#  Ledger
# ─────────────────────────────────────────────

@extend_schema(
    tags=['Ledger'],
    summary='List ledger entries',
    description='Immutable audit trail of all balance changes. Read-only.',
    responses={200: LedgerEntrySerializer(many=True)},
)
@api_view(['GET'])
@permission_classes([IsAuthenticated, IsWalletActive])
@throttle_classes([WalletReadThrottle])
def api_ledger(request):
    wallet  = _get_wallet(request.user)
    entries = wallet.ledger_entries.all().order_by('-created_at')

    paginator = WalletPageNumberPagination()
    page = paginator.paginate_queryset(entries, request)
    serializer = LedgerEntrySerializer(page, many=True)
    return paginator.get_paginated_response(serializer.data)


# ─────────────────────────────────────────────
#  Deposit
# ─────────────────────────────────────────────

@extend_schema(
    tags=['Deposits'],
    summary='Add funds to wallet',
    description=(
        'Creates and immediately approves a deposit request (fake gateway). '
        'In production, replace with real gateway callback.'
    ),
    request=DepositRequestSerializer,
    responses={201: TransactionSerializer},
    examples=[
        OpenApiExample(
            'Visa deposit',
            value={'amount': '500.00', 'cardholder_name': 'Ahmed Ali', 'card_last4': '4242', 'card_type': 'visa'},
            request_only=True,
        )
    ],
)
@api_view(['POST'])
@permission_classes([IsAuthenticated, IsWalletActive])
@throttle_classes([DepositThrottle])
def api_deposit(request):
    wallet     = _get_wallet(request.user)
    serializer = DepositRequestSerializer(data=request.data)

    if not serializer.is_valid():
        return error_response('Invalid deposit data.', serializer.errors)

    try:
        amount = Decimal(str(serializer.validated_data['amount']))
    except (InvalidOperation, KeyError):
        return error_response('Invalid amount.')

    # Idempotency key from header (optional)
    idempotency_key = request.headers.get('X-Idempotency-Key', '')

    try:
        dep_req = create_deposit_request(
            wallet=wallet,
            amount=amount,
            cardholder_name=serializer.validated_data.get('cardholder_name', ''),
            card_last4=serializer.validated_data.get('card_last4', ''),
            card_type=serializer.validated_data.get('card_type', 'visa'),
            idempotency_key=idempotency_key,
        )
        txn = approve_deposit_request(dep_req)
    except ValueError as exc:
        return error_response(str(exc))

    wallet.refresh_from_db()
    return created_response(
        data={
            'transaction':   TransactionSerializer(txn).data,
            'new_balance':   str(wallet.balance),
        },
        message=f'{amount:.2f} EGP added to your wallet.',
    )


# ─────────────────────────────────────────────
#  Withdraw
# ─────────────────────────────────────────────

@extend_schema(
    tags=['Withdrawals'],
    summary='Withdraw funds from wallet',
    description='Creates and immediately approves a withdrawal request.',
    request=WithdrawRequestSerializer,
    responses={201: TransactionSerializer},
)
@api_view(['POST'])
@permission_classes([IsAuthenticated, IsWalletActive])
@throttle_classes([WithdrawThrottle])
def api_withdraw(request):
    wallet     = _get_wallet(request.user)
    serializer = WithdrawRequestSerializer(data=request.data)

    if not serializer.is_valid():
        return error_response('Invalid withdrawal data.', serializer.errors)

    try:
        amount = Decimal(str(serializer.validated_data['amount']))
    except (InvalidOperation, KeyError):
        return error_response('Invalid amount.')

    idempotency_key = request.headers.get('X-Idempotency-Key', '')

    try:
        wr  = create_withdraw_request(
            wallet=wallet,
            amount=amount,
            bank_name=serializer.validated_data.get('bank_name', ''),
            account_number=serializer.validated_data.get('account_number', ''),
            account_holder=serializer.validated_data.get('account_holder', ''),
            idempotency_key=idempotency_key,
        )
        txn = approve_withdraw_request(wr)
    except ValueError as exc:
        return error_response(str(exc))

    wallet.refresh_from_db()
    return created_response(
        data={
            'transaction': TransactionSerializer(txn).data,
            'new_balance': str(wallet.balance),
        },
        message=f'{amount:.2f} EGP withdrawn from your wallet.',
    )


# ─────────────────────────────────────────────
#  Saved Cards
# ─────────────────────────────────────────────

@extend_schema(
    tags=['Cards'],
    summary='List or add saved cards',
    responses={200: SavedCardSerializer(many=True), 201: SavedCardSerializer},
)
@api_view(['GET', 'POST'])
@permission_classes([IsAuthenticated])
def api_saved_cards(request):
    wallet = _get_wallet(request.user)

    if request.method == 'GET':
        cards = wallet.saved_cards.all()
        return success_response(SavedCardSerializer(cards, many=True).data)

    serializer = SavedCardSerializer(data=request.data)
    if not serializer.is_valid():
        return error_response('Invalid card data.', serializer.errors)

    card = serializer.save(wallet=wallet)
    return created_response(SavedCardSerializer(card).data, 'Card saved successfully.')


@extend_schema(
    tags=['Cards'],
    summary='Delete a saved card',
    responses={204: None},
)
@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def api_delete_card(request, card_id):
    wallet  = _get_wallet(request.user)
    deleted, _ = SavedCard.objects.filter(pk=card_id, wallet=wallet).delete()
    if deleted:
        return no_content_response('Card removed.')
    return not_found_response('Card not found.')


# ─────────────────────────────────────────────
#  Notifications
# ─────────────────────────────────────────────

@extend_schema(
    tags=['Notifications'],
    summary='List wallet notifications',
    responses={200: NotificationSerializer(many=True)},
)
@api_view(['GET'])
@permission_classes([IsAuthenticated])
@throttle_classes([WalletReadThrottle])
def api_notifications(request):
    wallet  = _get_wallet(request.user)
    notifs  = wallet.notifications.all()
    paginator = WalletPageNumberPagination()
    page = paginator.paginate_queryset(notifs, request)
    return paginator.get_paginated_response(NotificationSerializer(page, many=True).data)


@extend_schema(
    tags=['Notifications'],
    summary='Mark all notifications as read',
    responses={200: None},
)
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def api_mark_notifications_read(request):
    wallet  = _get_wallet(request.user)
    updated = wallet.notifications.filter(is_read=False).update(is_read=True)
    return success_response({'marked_read': updated}, f'{updated} notification(s) marked as read.')


# ─────────────────────────────────────────────
#  Analytics
# ─────────────────────────────────────────────

@extend_schema(
    tags=['Analytics'],
    summary='Full dashboard analytics',
    description='Returns all data needed for the wallet dashboard — balance, charts, recent activity.',
    responses={200: AnalyticsSummarySerializer},
)
@api_view(['GET'])
@permission_classes([IsAuthenticated, IsWalletActive])
@throttle_classes([WalletReadThrottle])
def api_analytics_dashboard(request):
    wallet = _get_wallet(request.user)
    role   = getattr(request.user, 'role', '')

    if role in ('doctor', 'nurse'):
        data = get_provider_earnings(wallet)
    else:
        data = get_dashboard_summary(wallet)

    return success_response(data, 'Analytics retrieved.')


@extend_schema(
    tags=['Analytics'],
    summary='Monthly deposit/spending chart data',
    parameters=[
        OpenApiParameter('months', description='Number of months to return (default 6)', required=False),
    ],
)
@api_view(['GET'])
@permission_classes([IsAuthenticated])
@throttle_classes([WalletReadThrottle])
def api_analytics_monthly(request):
    wallet = _get_wallet(request.user)
    try:
        months = int(request.query_params.get('months', 6))
        months = min(max(months, 1), 24)  # clamp 1–24
    except (ValueError, TypeError):
        months = 6

    return success_response({
        'deposits':  get_monthly_deposits(wallet, months=months),
        'spending':  get_monthly_spending(wallet, months=months),
    })


@extend_schema(
    tags=['Analytics'],
    summary='Weekly stats',
    description='Returns daily breakdown for the current week.',
)
@api_view(['GET'])
@permission_classes([IsAuthenticated])
@throttle_classes([WalletReadThrottle])
def api_analytics_weekly(request):
    wallet = _get_wallet(request.user)
    return success_response(get_weekly_stats(wallet))


# ─────────────────────────────────────────────
#  Ledger reconciliation (admin only)
# ─────────────────────────────────────────────

@extend_schema(
    tags=['Ledger'],
    summary='Reconcile wallet balance against ledger',
    description='Admin-only. Verifies that Wallet.balance matches the sum of all ledger entries.',
)
@api_view(['POST'])
@permission_classes([IsAuthenticated, IsAdminUser])
def api_reconcile(request):
    wallet = _get_wallet(request.user)
    result = reconcile_wallet_balance(wallet)
    http_status = status.HTTP_200_OK if result['is_reconciled'] else status.HTTP_409_CONFLICT
    return Response(
        {'success': result['is_reconciled'], 'message': 'Reconciliation complete.', 'data': result},
        status=http_status,
    )
