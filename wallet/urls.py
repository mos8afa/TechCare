from django.urls import path
from . import views

urlpatterns = [
    path("", views.wallet_detail, name="wallet_detail"),
    path("deposit/", views.deposit_view, name="deposit"),
    path("withdraw/", views.withdraw_view, name="withdraw"),
    path("transfer/", views.transfer_view, name="transfer"),
]