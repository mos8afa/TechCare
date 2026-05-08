from django.urls import path
from drf_spectacular.views import SpectacularAPIView, SpectacularSwaggerView, SpectacularRedocView

from . import views
from . import api_views
from . import admin_views

app_name = "wallet"

urlpatterns = [

    # ── Web views ──────────────────────────────────────────────
    path("",               views.wallet_dashboard,   name="dashboard"),
    path("transactions/",  views.transaction_list,   name="transactions"),
    path("deposit/",       views.deposit_view,       name="deposit"),
    path("withdraw/",      views.withdraw_view,      name="withdraw"),
    path("notifications/", views.notifications_view, name="notifications"),
    path("cards/",         views.saved_cards_view,   name="saved_cards"),

    # Dev / test helpers (guard with DEBUG check in production)
    path("fake/deposit/",  views.fake_deposit_view,  name="fake_deposit"),
    path("fake/withdraw/", views.fake_withdraw_view, name="fake_withdraw"),

    # ── Admin dashboard (staff only) ───────────────────────────
    path("admin-dashboard/",                    admin_views.admin_wallet_dashboard,    name="admin_dashboard"),
    path("admin-dashboard/user/<int:user_id>/", admin_views.admin_wallet_detail,       name="admin_wallet_detail"),
    path("admin-dashboard/providers/",          admin_views.admin_provider_visibility, name="admin_provider_visibility"),

    # ── REST API (JWT-authenticated, Flutter-ready) ────────────
    path("api/me/",                    api_views.api_wallet_me,               name="api_me"),
    path("api/transactions/",          api_views.api_transactions,            name="api_transactions"),
    path("api/ledger/",                api_views.api_ledger,                  name="api_ledger"),
    path("api/deposit/",               api_views.api_deposit,                 name="api_deposit"),
    path("api/withdraw/",              api_views.api_withdraw,                name="api_withdraw"),
    path("api/cards/",                 api_views.api_saved_cards,             name="api_cards"),
    path("api/cards/<uuid:card_id>/",  api_views.api_delete_card,             name="api_delete_card"),
    path("api/notifications/",         api_views.api_notifications,           name="api_notifications"),
    path("api/notifications/read/",    api_views.api_mark_notifications_read, name="api_notifications_read"),

    # ── Analytics ──────────────────────────────────────────────
    path("api/analytics/",         api_views.api_analytics_dashboard, name="api_analytics"),
    path("api/analytics/monthly/", api_views.api_analytics_monthly,   name="api_analytics_monthly"),
    path("api/analytics/weekly/",  api_views.api_analytics_weekly,    name="api_analytics_weekly"),

    # ── Admin utilities ────────────────────────────────────────
    path("api/reconcile/", api_views.api_reconcile, name="api_reconcile"),

    # ── API Documentation (drf-spectacular) ───────────────────
    path("api/schema/",  SpectacularAPIView.as_view(),                                     name="api_schema"),
    path("api/docs/",    SpectacularSwaggerView.as_view(url_name="wallet:api_schema"),     name="api_swagger"),
    path("api/redoc/",   SpectacularRedocView.as_view(url_name="wallet:api_schema"),       name="api_redoc"),
]
