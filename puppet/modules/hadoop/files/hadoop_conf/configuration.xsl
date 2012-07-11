from __future__ import absolute_import

from celery.app.annotations import MapAnnotation, prepare
from celery.task import task
from celery.utils.imports import qualname

from celery.tests.utils import Case


@task()
def add(x, y):
    return x + y


@task()
def mul(x, y):
    return x * y


class MyAnnotation(object):
    foo = 65


class test_MapAnnotation(Case):

    def test_annotate(self):
        x = MapAnnotation({add.name: {'foo': 1}})
        self.assertDictEqual(x.annotate(add), {'foo': 1})
        self.assertIsNone(x.an