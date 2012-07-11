# -*- coding: utf-8 -*-
"""
    celery.task
    ~~~~~~~~~~~

    This is the old task module, it should not be used anymore.

"""
from __future__ import absolute_import

from celery._state import current_app, current_task as current
from celery.__compat__ import MagicModule, recreate_module
from celery.local import Proxy


class module(MagicModule):

    def __call__(self, *args, **kwargs):
        return self.