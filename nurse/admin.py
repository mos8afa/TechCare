from django.contrib import admin
from .models import Service, NurseRequest


@admin.register(Service)
class ServiceAdmin(admin.ModelAdmin):
    list_display = ("id", "name", "price", "nurse")
    search_fields = ("name",)
    list_filter = ("nurse",)


@admin.register(NurseRequest)
class NurseRequestAdmin(admin.ModelAdmin):
    list_display = ("id", "patient", "nurse", "date", "time", "status", "net_income")
    list_filter = ("status", "governrate")
    search_fields = ("patient__user__username", "nurse__user__username")