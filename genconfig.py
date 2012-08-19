import argparse
import shutil
import time
import glob


def run(masters, slaves, pmaster):
    if pmaster is None:
        pmaster = masters[0]
    root = 'puppet'
    shutil.rmtree(root, ignore_errors=True)
    shutil.copytree('puppet_src', root)

    fn = '%s/manifests/nodes.pp' % root
    with open(fn) as fp:
        data = fp.read()
        data = data.replace('{{slaves}}', ', '.join("'%s'" % x for x in slaves)).replace('{{masters}}', ', '.join("'%s'" % x for x in masters))
        print('Writing[%s]' % fn)
        with open(fn, 'w') as fp:
            fp.write(data)

    for fn in ['%s/puppet_client_setup.sh' % root, '%s/puppet.conf' % root, '%s/modules/cron_20min/manifests/init.pp' % root]:
        with open(fn) as fp:
            data = fp.read()
            data = data.replace('{{pmaster}}', "%s" % pmaster)
            print('Writing[%s]' % fn)
            with open(fn, 'w') as fp:
                fp.write(data)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Setup puppet dir")
    # Server port
    parser.add_argument('masters', help="Hadoop master (JobTracker, NameNode, TaskTracker, DataNode)", nargs='+', default=())
    parser.add_argument('--slaves', nargs='+', help="Hadoop slaves (TaskTracker, DataNode)", default=())
    parser.add_argument('--pmaster', help="Puppet master server (if unspecified, master is used)")
    run(**vars(parser.parse_args()))
