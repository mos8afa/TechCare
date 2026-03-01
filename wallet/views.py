from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth.decorators import login_required
from decimal import Decimal
from .models import Wallet, Transaction
from .services import deposit, withdraw, transfer

@login_required
def wallet_detail(request):
    wallet = get_object_or_404(Wallet, user=request.user)
    transactions = Transaction.objects.filter(wallet=wallet).order_by('-created_at')
    return render(request, "wallets/wallet_detail.html", {"wallet": wallet, "transactions": transactions})

@login_required
def deposit_view(request):
    wallet = get_object_or_404(Wallet, user=request.user)
    if request.method == "POST":
        amount = Decimal(request.POST.get("amount"))
        description = request.POST.get("description", "")
        deposit(wallet, amount, description)
        return redirect("wallet_detail")
    return render(request, "wallets/deposit.html")

@login_required
def withdraw_view(request):
    wallet = get_object_or_404(Wallet, user=request.user)
    if request.method == "POST":
        amount = Decimal(request.POST.get("amount"))
        description = request.POST.get("description", "")
        try:
            withdraw(wallet, amount, description)
        except ValueError as e:
            return render(request, "wallets/withdraw.html", {"error": str(e)})
        return redirect("wallet_detail")
    return render(request, "wallets/withdraw.html")

@login_required
def transfer_view(request):
    wallet = get_object_or_404(Wallet, user=request.user)
    if request.method == "POST":
        receiver_username = request.POST.get("receiver")
        amount = Decimal(request.POST.get("amount"))
        description = request.POST.get("description", "")
        from django.contrib.auth.models import User
        try:
            receiver_user = User.objects.get(username=receiver_username)
            receiver_wallet = Wallet.objects.get(user=receiver_user)
            transfer(wallet, receiver_wallet, amount, description)
        except User.DoesNotExist:
            return render(request, "wallets/transfer.html", {"error": "Receiver not found"})
        except Wallet.DoesNotExist:
            return render(request, "wallets/transfer.html", {"error": "Receiver wallet not found"})
        except ValueError as e:
            return render(request, "wallets/transfer.html", {"error": str(e)})
        return redirect("wallet_detail")
    return render(request, "wallets/transfer.html")