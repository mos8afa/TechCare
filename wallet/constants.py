from decimal import Decimal

# ── Deposit limits ──────────────────────────────────────────
MIN_DEPOSIT_AMOUNT   = Decimal('10.00')    # EGP
MAX_DEPOSIT_AMOUNT   = Decimal('50000.00') # EGP per transaction

# ── Withdrawal limits ───────────────────────────────────────
MIN_WITHDRAW_AMOUNT  = Decimal('50.00')    # EGP
MAX_WITHDRAW_AMOUNT  = Decimal('20000.00') # EGP per transaction
DAILY_WITHDRAW_LIMIT = Decimal('30000.00') # EGP per calendar day

# ── Transfer limits ─────────────────────────────────────────
MIN_TRANSFER_AMOUNT  = Decimal('10.00')
MAX_TRANSFER_AMOUNT  = Decimal('10000.00')

# ── Platform fee ────────────────────────────────────────────
PLATFORM_FEE_PERCENT = Decimal('15.00')   # % deducted from provider earnings

# ── Ledger entry types ──────────────────────────────────────
LEDGER_CREDIT   = 'credit'
LEDGER_DEBIT    = 'debit'
LEDGER_FEE      = 'fee'
LEDGER_REFUND   = 'refund'
LEDGER_TRANSFER = 'transfer'

LEDGER_ENTRY_TYPES = (
    (LEDGER_CREDIT,   'Credit'),
    (LEDGER_DEBIT,    'Debit'),
    (LEDGER_FEE,      'Fee'),
    (LEDGER_REFUND,   'Refund'),
    (LEDGER_TRANSFER, 'Transfer'),
)

# ── Transaction type → ledger type mapping ──────────────────
TXN_TO_LEDGER = {
    'deposit':   LEDGER_CREDIT,
    'refund':    LEDGER_REFUND,
    'withdraw':  LEDGER_DEBIT,
    'payment':   LEDGER_DEBIT,
    'deduction': LEDGER_FEE,
    'transfer':  LEDGER_TRANSFER,
}

# ── API pagination ──────────────────────────────────────────
DEFAULT_PAGE_SIZE = 20
MAX_PAGE_SIZE     = 100

# ── Rate limiting (requests per minute) ────────────────────
DEPOSIT_RATE_LIMIT  = '10/min'
WITHDRAW_RATE_LIMIT = '5/min'
API_RATE_LIMIT      = '60/min'

# ── Idempotency window (seconds) ───────────────────────────
IDEMPOTENCY_WINDOW_SECONDS = 30
