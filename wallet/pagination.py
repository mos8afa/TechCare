from rest_framework.pagination import PageNumberPagination
from rest_framework.response import Response
from wallet.constants import DEFAULT_PAGE_SIZE, MAX_PAGE_SIZE


class WalletPageNumberPagination(PageNumberPagination):
    page_size             = DEFAULT_PAGE_SIZE
    page_size_query_param = 'page_size'
    max_page_size         = MAX_PAGE_SIZE
    page_query_param      = 'page'

    def get_paginated_response(self, data):
        return Response({
            'success': True,
            'message': '',
            'data': data,
            'pagination': {
                'count':     self.page.paginator.count,
                'total_pages': self.page.paginator.num_pages,
                'current_page': self.page.number,
                'next':      self.get_next_link(),
                'previous':  self.get_previous_link(),
                'page_size': self.get_page_size(self.request),
            },
        })

    def get_paginated_response_schema(self, schema):
        return {
            'type': 'object',
            'properties': {
                'success':    {'type': 'boolean'},
                'message':    {'type': 'string'},
                'data':       schema,
                'pagination': {
                    'type': 'object',
                    'properties': {
                        'count':        {'type': 'integer'},
                        'total_pages':  {'type': 'integer'},
                        'current_page': {'type': 'integer'},
                        'next':         {'type': 'string', 'nullable': True},
                        'previous':     {'type': 'string', 'nullable': True},
                        'page_size':    {'type': 'integer'},
                    },
                },
            },
        }
