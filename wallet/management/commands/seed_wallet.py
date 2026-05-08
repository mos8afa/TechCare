"""
wallet/management/commands/seed_wallet.py
─────────────────────────────────────────
Management command to seed fake wallet data for testing.

Usage:
    python manage.py seed_wallet
    python manage.py seed_wallet --username john_doe
    python manage.py seed_wallet --all
    python manage.py seed_wallet --reset
"""
from decimal import Decimal
from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model
from wallet.models import Wallet, SavedCard, Transaction, Notification
from wallet.services import process_deposit, charge_wallet

User = get_user_model()

# All deposits first, then payments — so balance is always sufficient
FAKE_TRANSACTIONS = [
    # deposits
    ("deposit", Decimal("1000.00"), "Top-up: Visa Card ending in 4242",        "VISA-4242"),
    ("deposit", Decimal("500.00"),  "Top-up: Mastercard ending in 8821",        "MC-8821"),
    ("deposit", Decimal("2000.00"), "Top-up: Visa Card ending in 4242",         "VISA-4242"),
    # payments
    ("payment", Decimal("450.00"),  "Payment: Dr. Ahmed Salem - Consultation",  "BK-9912"),
    ("payment", Decimal("210.00"),  "Order: CarePoint Pharmacy - Prescription", "RX-8821"),
    ("payment", Decimal("300.00"),  "Home Visit: Nurse Sarah - Nursing Service","NV-1234"),
    ("payment", Decimal("15.00"),   "Platform Service Fee - Booking #BK-9912",  "FEE-9912"),
    ("payment", Decimal("600.00"),  "Payment: Dr. Mariam Ezzat - Consultation", "BK-5566"),
]

FAKE_CARDS = [
    {"card_type": "visa",       "last4": "4242", "expiry": "12/26", "is_default": True},
    {"card_type": "mastercard", "last4": "8821", "expiry": "09/25", "is_default": False},
]


class Command(BaseCommand):
    help = "Seed fake wallet data for testing"

    def add_arguments(self, parser):
        parser.add_argument("--username", type=str,    help="Seed wallet for a specific user")
        parser.add_argument("--all",      action="store_true", help="Seed wallets for all users")
        parser.add_argument("--reset",    action="store_true", help="Clear existing wallet data before seeding")

    def handle(self, *args, **options):
        if options["username"]:
            users = User.objects.filter(username=options["username"])
            if not users.exists():
                self.stderr.write(self.style.ERROR(f"User '{options['username']}' not found."))
                return
        else:
            users = User.objects.all()

        for user in users:
            self._seed_user(user, reset=options.get("reset", False))

        self.stdout.write(self.style.SUCCESS(f"\nDone. Seeded wallets for {users.count()} user(s)."))

    def _seed_user(self, user, reset=False):
        wallet, _ = Wallet.objects.get_or_create(user=user)

        if reset:
            from django.db import connection
            Transaction.objects.filter(wallet=wallet).delete()
            # Use raw delete to bypass LedgerEntry immutability guard (seed only)
            with connection.cursor() as cursor:
                cursor.execute("DELETE FROM wallet_ledgerentry WHERE wallet_id = %s", [str(wallet.pk)])
            Notification.objects.filter(wallet=wallet).delete()
            SavedCard.objects.filter(wallet=wallet).delete()
            wallet.balance = Decimal("0.00")
            wallet.save()
            self.stdout.write(f"  Reset {user.username}")
        elif wallet.transactions.exists():
            self.stdout.write(f"  Skipping {user.username} — already has data (use --reset to overwrite)")
            return

        self.stdout.write(f"  Seeding {user.username} ({user.role or 'no role'})...")

        for tx_type, amount, desc, ref in FAKE_TRANSACTIONS:
            try:
                if tx_type == "deposit":
                    process_deposit(wallet, amount, description=desc, reference=ref, skip_validation=True)
                elif tx_type == "payment":
                    charge_wallet(wallet, amount, description=desc, reference=ref)
            except Exception as e:
                self.stdout.write(self.style.WARNING(f"    Skipped: {desc} — {e}"))

        # Saved cards
        if not wallet.saved_cards.exists():
            holder = f"{user.first_name} {user.last_name}".strip() or user.username
            for card_data in FAKE_CARDS:
                SavedCard.objects.create(wallet=wallet, cardholder_name=holder, **card_data)

        wallet.refresh_from_db()
        self.stdout.write(self.style.SUCCESS(
            f"    Balance: {wallet.balance} EGP | Txns: {wallet.transactions.count()} | Cards: {wallet.saved_cards.count()}"
        ))
