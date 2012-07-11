# -*- coding: utf-8 -*-
"""
    celery.task.http
    ~~~~~~~~~~~~~~~~

    Webhook task implementation.

"""
from __future__ import absolute_import

import anyjson
import sys
import urllib2

from urllib import urlencode
from urlparse import urlparse
try:
    from urlparse import parse_qsl
except ImportError:  # pragma: no cover
    from cgi import parse_qsl  # noqa

from celery import __version__ as celery_version
from celery.utils.log import get_task_logger
from .base import Task as BaseTask

GET_METHODS = frozenset(['GET', 'HEAD'])
logger = get_task_logger(__name__)


class InvalidResponseError(Exception):
    """The remote server gave an invalid response."""


class RemoteExecuteError(Exception):
    """The remote task gave a custom error."""


class UnknownStatusError(InvalidResponseError):
    """The remote server gave an unknown status."""


def maybe_utf8(value):
    """Encode to utf-8, only if the value is Unicode."""
    if isinstance(value, unicode):
        return value.encode('utf-8')
    return value


if sys.version_info[0] == 3:  # pragma: no cover

    def utf8dict(tup):
        if not isinstance(tup, dict):
            return dict(tup)
        return tup
else:

    def utf8dict(tup):  # noqa
        """With a dict's items() tuple return a new dict with any utf-8
        keys/values encoded."""
        return dict((key.encode('utf-8'), maybe_utf8(value))
                        for key, value in tup)


def extract_response(raw_response, loads=anyjson.loads):
    """Extract the response text from a raw JSON response."""
    if not raw_response:
        raise InvalidResponseError('Empty response')
    try:
        payload = loads(raw_response)
    except ValueError, exc:
        raise InvalidResponseError, InvalidResponseError(
                str(exc)), sys.exc_info()[2]

    status = payload['status']
    if status == 'success':
        return payload['retval']
    elif status == 'failure':
        raise RemoteExecuteError(payload.get('reason'))
    else:
        raise UnknownStatusError(str(status))


class MutableURL(object):
    """Object wrapping a Uniform Resource Locator.

    Supports editing the query parameter list.
    You can convert the object back to a string, the query will be
    properly urlencoded.

    Examples

        >>> url = URL('http://www.google.com:6580/foo/bar?x=3&y=4#foo')
        >>> url.query
        {'x': '3', 'y': '4'}
        >>> str(url)
        'http://www.google.com:6580/foo/bar?y=4&x=3#foo'
        >>> url.query['x'] = 10
        >>> url.query.update({'George': 'Costanza'})
        >>> str(url)
        'http://www.google.com:6580/foo/bar?y=4&x=10&George=Costanza#foo'

    """
    def __init__(self, url):
        self.parts = urlparse(url)
        self.query = dict(parse_qsl(self.parts[4]))

    def __str__(self):
        scheme, netloc, path, params, query, fragment = self.parts
        query = urlencode(utf8dict(self.query.items()))
        components = [scheme + '://', netloc, path or '/',
                      ';%s' % params   if params   else '',
                      '?%s' % query    