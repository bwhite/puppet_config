import argparse
import shutil
import time
import glob


def run(master, slaves):
    root = 'puppet-%f' % time.time()
    shutil.copytree('puppet', root)

    for fn in glob.glob('%s/modules/hadoop/files/hadoop_conf/*' % root):
        with open(fn) as fp:
            data = fp.read()
        data2 = data.replace('{{master}}', master).replace('{{slaves}}', '\n'.join(slaves))
        if data != data2:
            print('Writing[%s]' % fn)
            with open(fn, 'w') as fp:
                fp.write(data2)
    fn = '%s/manifests/nodes.pp' % root
    with open(fn) as fp:
        data = fp.read()
        data = data.replace('{{master}}', "'%s'" % master).replace('{{slaves}}', ', '.join("'%s'" % x for x in slaves))
        print('Writing[%s]' % fn)
        with open(fn, 'w') as fp:
            fp.write(data)
    fn = '%s/puppet_client_setup.sh' % root
    with open(fn) as fp:
        data = fp.read()
        data = data.replace('{{master}}', "%s" % master)
        print('Writing[%s]' % fn)
        with open(fn, 'w') as fp:
            fp.write(data)
    fn = '%s/puppet.conf' % root
    with open(fn) as fp:
        data = fp.read()
        data = data.replace('{{master}}', "%s" % master)
        print('Writing[%s]' % fn)
        with open(fn, 'w') as fp:
            fp.write(data)

    

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Setup puppet dir")
    # Server port
    parser.add_argument('master')
    parser.add_argument('slaves', nargs='+')
    run(**vars(parser.parse_args()))
