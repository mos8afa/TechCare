from django.contrib import admin
from .models import BloodDonationRequest, DonorOffer

@admin.register(BloodDonationRequest)
class BloodDonationRequestAdmin(admin.ModelAdmin):
    list_display = (
        'id',
        'requester',
        'blood_type',
        'governorate',
        'status',
        'condition',
        'created_at'
    )
    list_filter = ('status', 'blood_type', 'governorate', 'condition')
    search_fields = ('requester__username', 'address', 'medical_condition')
    ordering = ('-created_at',)

    readonly_fields = ('created_at',)

    fieldsets = (
        ('Request Info', {
            'fields': (
                'requester',
                'blood_type',
                'governorate',
                'address',
                'medical_condition',
                'condition',
                'status'
            )
        }),
        ('Extra Info', {
            'fields': ('requester_done', 'created_at')
        }),
    )

@admin.register(DonorOffer)
class DonorOfferAdmin(admin.ModelAdmin):
    list_display = (
        'id',
        'request',
        'donor',
        'status',
        'created_at'
    )
    list_filter = ('status',)
    search_fields = ('donor__user__username', 'request__id')
    ordering = ('-created_at',)

    readonly_fields = ('created_at',)

    fieldsets = (
        ('Offer Info', {
            'fields': (
                'request',
                'donor',
                'status'
            )
        }),
        ('Extra Info', {
            'fields': ('donor_done', 'created_at')
        }),
    )