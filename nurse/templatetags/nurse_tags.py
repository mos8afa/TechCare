from django import template

register = template.Library()


@register.filter
def sum_prices(services):
    """Return the sum of .price for a queryset of Service objects."""
    try:
        return sum(s.price for s in services)
    except Exception:
        return 0
