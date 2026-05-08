from rest_framework import status
from rest_framework.response import Response


def success_response(data=None, message: str = '', http_status: int = status.HTTP_200_OK) -> Response:
    return Response(
        {'success': True,  'message': message, 'data': data},
        status=http_status,
    )


def created_response(data=None, message: str = 'Created successfully.') -> Response:
    return Response(
        {'success': True,  'message': message, 'data': data},
        status=status.HTTP_201_CREATED,
    )


def error_response(message: str, data=None, http_status: int = status.HTTP_400_BAD_REQUEST) -> Response:
    return Response(
        {'success': False, 'message': message, 'data': data},
        status=http_status,
    )


def not_found_response(message: str = 'Not found.') -> Response:
    return Response(
        {'success': False, 'message': message, 'data': None},
        status=status.HTTP_404_NOT_FOUND,
    )


def forbidden_response(message: str = 'Permission denied.') -> Response:
    return Response(
        {'success': False, 'message': message, 'data': None},
        status=status.HTTP_403_FORBIDDEN,
    )


def no_content_response(message: str = 'Deleted.') -> Response:
    return Response(
        {'success': True, 'message': message, 'data': None},
        status=status.HTTP_204_NO_CONTENT,
    )
