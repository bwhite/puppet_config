class zeromq {
  exec {"zeromq":
      command => 'wget http://download.zeromq.org/zeromq-3.2.0-rc1.tar.gz && tar -xzf zeromq-3.2.0-rc1.tar.gz && cd zeromq-3.2.0 && ./configure --prefix=/usr && make && make install',
      path => ['/usr/local/bin', '/opt/local/bin', '/usr/bin', '/usr/sbin', '/bin', '/sbin'],
      unless => 'test -e /usr/lib/libzmq.so.3.0.0',
  }
  package {
      "pyzmq":
          ensure => latest,
          provider => pip,
          require => Exec["zeromq"],
          source => "git+https://github.com/zeromq/pyzmq.git";
  }
}