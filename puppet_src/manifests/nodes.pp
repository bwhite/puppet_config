class standard_install {
  $pkgs = [ "libavcodec-dev", "libswscale-dev", "libavformat-dev", "gfortran", "ffmpeg", "libfftw3-dev", "python-dev", "build-essential", "git-core", "cmake", "libjpeg62-dev", "libpng12-dev", "libblas-dev", "liblapack-dev", "emacs23-nox", "dtach", "curl", "lynx", "wine", "libboost-all-dev", "libssl-dev"]
  package { $pkgs: ensure => "installed" }
}

class python_distribute {
  exec {'wget -nc http://python-distribute.org/distribute_setup.py && python distribute_setup.py && rm distribute_setup.py':
      path => ['/usr/local/bin', '/opt/local/bin', '/usr/bin', '/usr/sbin', '/bin', '/sbin'],
      unless => 'python -c "import setuptools"',
      logoutput => true,
      timeout => 3600
  }
}

class python_pip {
  exec {'wget -nc --no-check-certificate https://raw.github.com/pypa/pip/master/contrib/get-pip.py && python get-pip.py && rm get-pip.py':
      path => ['/usr/local/bin', '/opt/local/bin', '/usr/bin', '/usr/sbin', '/bin', '/sbin'],
      unless => 'python -c "import pip"',
      logoutput => true,
      timeout => 3600
  }
}

class root_dir_readable {
  exec {'chmod 755 /root':
      path => ['/usr/local/bin', '/opt/local/bin', '/usr/bin', '/usr/sbin', '/bin', '/sbin'],
      logoutput => true,
  }
}

# Hadoop Master
# Also need to update
# /etc/puppet/modules/hadoop/files/hadoop_conf/masters
# /etc/puppet/modules/hadoop/files/hadoop_conf/core-site.xml
# /etc/puppet/modules/hadoop/files/hadoop_conf/mapred-site.xml
node {{master}} {
  stage { [b0, b1, a0, a1, a2, a3, a4]:}
  Stage[b0] -> Stage[b1] -> Stage[main] -> Stage[a0] -> Stage[a1] -> Stage[a2] -> Stage[a3] -> Stage[a4]
  class {standard_install: stage => b0}
  class {root_dir_readable: stage => b0}
  class {hadoop: stage => b0}
  class {python_pip: stage => b1}
  class {python_distribute: stage => b0}
  class {picarus: stage => a0}
  class {picarus_pre: stage => main}
  class {install_java_apt: stage => b1}
  class {install_java: stage => a0}
  class {install_thrift: stage => a0}
  class {hadoop_master: stage => a1}
  class {hadoop_base: stage => a1}
  class {hadoop_master_format: stage => a2}
  class {hadoop_master_start: stage => a3}
  class {zeromq: stage => a3}
  class {build_hadoopy_hbase: stage => a4}
  class {cron_20min: stage => a4}
}

# Hadoop Slaves
# Also need to update
# /etc/puppet/modules/hadoop/files/hadoop_conf/slaves
node {{slaves}} {
  stage { [b0, b1, a0, a1, a2, a3]:}
  Stage[b0] -> Stage[b1] -> Stage[main] -> Stage[a0] -> Stage[a1] -> Stage[a2] -> Stage[a3]
  class {standard_install: stage => b0}
  class {root_dir_readable: stage => b0}
  class {hadoop: stage => b0}
  class {python_pip: stage => b0}
  class {python_distribute: stage => b0}
  class {picarus: stage => a0}
  class {picarus_pre: stage => main}
  class {install_java_apt: stage => b1}
  class {install_java: stage => a0}
  class {hadoop_slave: stage => a1}
  class {hadoop_base: stage => a1}
  class {hadoop_slave_start: stage => a3}
  class {zeromq: stage => a3}
  class {cron_20min: stage => a3}
}
