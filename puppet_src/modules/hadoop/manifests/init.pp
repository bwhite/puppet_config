class hadoop {
    file { "/etc/apt/sources.list.d/cloudera.list":
        owner => root,
        group => root,
        mode => 664,
        source => "puppet:///hadoop/cloudera.list"
    }
    exec { "update_apt":
        command => "apt-get update && wget -nc http://archive.cloudera.com/debian/archive.key -O /root/cloudera.key && sudo apt-key add /root/cloudera.key && apt-get update",
        path => "/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin",
        creates => "/root/cloudera.key"
    }
}

class install_java_apt {
    exec { "install_java":
        command => "apt-get update && curl https://raw.github.com/flexiondotorg/oab-java6/master/oab-java.sh > /root/oab-java.sh && bash /root/oab-java.sh && apt-get update",
        path => "/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin",
        creates => "/root/oab-java.sh",
        timeout => 600
    }
}

class install_java {
    $hadoop_pkgs = ["sun-java6-jdk", "sun-java6-jre", "ant"]
        package { $hadoop_pkgs: ensure => "installed",
    }
}

class hadoop_master_format {
  exec { "format_namenode":
    command => "sudo -u hdfs hadoop namenode -format",
    path => "/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin",
    creates => "/var/lib/hadoop-0.20/cache/hadoop/dfs/name/"
  }
}

class hadoop_psuedo {
  $hadoop_pkgs = ["hadoop-0.20-conf-pseudo"]
  package { $hadoop_pkgs: ensure => "installed",
  }
}

class hadoop_base {
 $hadoop_pkgs = $lsbdistcodename ? {
          precise => ["hadoop-0.20", "hadoop-hbase", "hadoop-zookeeper", "hadoop-hbase-thrift"],
          default => ["hadoop-0.20", "hadoop-hbase", "hadoop-zookeeper", "hadoop-0.20-native", "hadoop-hbase-thrift"],
        }
  package { $hadoop_pkgs: ensure => "installed",}
}

class hadoop_slave {
  $hadoop_pkgs = ["hadoop-0.20-tasktracker", "hadoop-0.20-datanode"]
  package { $hadoop_pkgs: ensure => "installed",
  }

  # Setup config
  file { "/etc/hadoop/conf":
  source => "puppet:///hadoop/hadoop_conf",
    recurse => true,
    purge => true
  }
}

class hadoop_slave_start {
  service { ["hadoop-0.20-datanode", "hadoop-0.20-tasktracker"]:
    ensure => "running",
    enable => "true",
  }
}

class hadoop_master($hadoop_master, $hadoop_slaves) {
  $hadoop_pkgs = ["hadoop-0.20-tasktracker", "hadoop-0.20-datanode", "hadoop-0.20-jobtracker", "hadoop-0.20-namenode", "hadoop-0.20-secondarynamenode", "hadoop-hbase-master", "hadoop-hbase-regionserver"]
  package { $hadoop_pkgs: ensure => "installed",
  }

  # Setup config
  file { "/etc/hadoop/conf":
  source => "puppet:///hadoop/hadoop_conf",
    recurse => true,
    purge => true
  }
  exec { "create_hdfs_path":
        command => "mkdir -p /var/lib/hadoop-0.20/cache/hadoop/dfs && chown hdfs:hdfs -R /var/lib/hadoop-0.20/cache/hadoop/dfs",
        path => "/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin",
        creates => "/var/lib/hadoop-0.20/cache/hadoop/dfs"
  }

  file { "/etc/hosts":
      owner   => root,
      group   => root,
      mode    => 644,
      content => template("hadoop/hosts.erb"),
  }

  file { "/etc/hadoop/conf/mapred-site.xml":
      owner   => root,
      group   => root,
      mode    => 644,
      content => template("hadoop/mapred-site.xml.erb"),
  }

  file { "/etc/hadoop/conf/core-site.xml":
      owner   => root,
      group   => root,
      mode    => 644,
      content => template("hadoop/core-site.xml.erb"),
  }

  file { "/etc/hadoop/conf/masters":
      owner   => root,
      group   => root,
      mode    => 644,
      content => template("hadoop/masters.erb"),
  }

  file { "/etc/hadoop/conf/slaves":
      owner   => root,
      group   => root,
      mode    => 644,
      content => template("hadoop/slaves.erb"),
  }


  file { "/etc/hbase/conf/hbase-site.xml":
      owner   => root,
      group   => root,
      mode    => 644,
      content => template("hadoop/hbase-site.xml.erb"),
  }
}

class hadoop_master_start {
  service { ["hadoop-0.20-datanode", "hadoop-0.20-namenode", "hadoop-0.20-tasktracker", "hadoop-0.20-jobtracker", "hadoop-0.20-secondarynamenode", "hadoop-hbase-master", "hadoop-hbase-thrift"]:
    ensure => "running",
    enable => "true",
  }

  service { ["hadoop-hbase-regionserver"]:
    ensure => "stopped",
    enable => "false",
  }
 
}

class install_thrift {
  exec {'thrift':
      command => 'wget -nc https://dist.apache.org/repos/dist/release/thrift/0.8.0/thrift-0.8.0.tar.gz && tar -xzf thrift-0.8.0.tar.gz && cd thrift-0.8.0 && ./configure --prefix /usr && make && make install',
      path => ['/usr/local/bin', '/opt/local/bin', '/usr/bin', '/usr/sbin', '/bin', '/sbin'],
      unless => 'which thrift',
      logoutput => true,
      timeout => 6000
  }
}

class build_hadoopy_hbase {
  exec {'build hadoopy hbase':
      cwd => '/root/src/hadoopy-hbase/java/',
      command => 'bash build.sh',
      path => ['/usr/local/bin', '/opt/local/bin', '/usr/bin', '/usr/sbin', '/bin', '/sbin'],
      unless => 'test -e /usr/lib/hadoop/lib/hadoopy_hbase.jar',
      logoutput => true,
      timeout => 6000
  }
}
