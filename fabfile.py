from fabric.api import run, sudo, put, get, env
from fabric.context_managers import cd, settings
import time
import os
import contextlib


@contextlib.contextmanager
def mkdir(prefix):
    work_dir = '%s-%f' % (prefix, time.time())
    run('mkdir %s' % work_dir)
    try:
        with cd(work_dir):
            yield
    finally:
        sudo('rm -r %s' % work_dir)


def setup():
    put('puppet/puppet_client_setup.sh', '.')
    sudo('bash puppet_client_setup.sh')


def agent():
    sudo('puppet agent --onetime --verbose --ignorecache --no-daemonize --no-usecacheonfailure --no-splay')


def rmcerts():
    for host in env['hosts']:
        print('You should execute this on the puppet master "sudo puppet cert clean %s"' % host)
    sudo('rm -f /etc/puppet/ssl/certs/*.pem')


def hadoopy_test():
    with cd('/root/src/hadoopy/tests'):
        sudo('python fetch_data.py')
        run('python test_with_hadoop.py')


def addadmin(user):
    sudo('adduser %s --ingroup sudo --ingroup admin' % user)


def adduser(user):
    sudo('adduser %s' % user)
