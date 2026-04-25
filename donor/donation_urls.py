from django.urls import path
from . import views

app_name = 'donation'

urlpatterns = [
    # Any user — submit & manage their own requests
    path('request/create/',                    views.create_blood_request,  name='create_request'),
    path('request/my/',                        views.my_blood_requests,     name='my_requests'),
    path('request/<int:request_id>/offers/',   views.request_offers,        name='request_offers'),
    path('request/<int:request_id>/cancel/',   views.cancel_blood_request,  name='cancel_request'),
    path('offer/<int:offer_id>/accept/',       views.accept_offer,          name='accept_offer'),
    path('offer/<int:offer_id>/requester-done/', views.requester_mark_done, name='requester_done'),

    # Donor — browse & offer
    path('available/',                         views.available_requests,    name='available_requests'),
    path('request/<int:request_id>/offer/',    views.offer_to_donate,       name='offer_to_donate'),
    path('my-offers/',                         views.my_offers,             name='my_offers'),
    path('offer/<int:offer_id>/donor-done/',   views.donor_mark_done,       name='donor_done'),
]
