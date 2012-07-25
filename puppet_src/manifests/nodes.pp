class standard_install {
  $pkgs = [ "libavcodec-dev", "libswscale-dev", "libavformat-dev", "gfortran", "ffmpeg", "libfftw3-dev", "python-dev", "build-essential", "git-core", "cmake", "libjpeg62-dev", "libpng12-dev", "libblas-dev", "liblapack-dev", "emacs23-nox", "dtach", "curl", "python-pip", "python-setuptools" , "lynx"]
  package { $pkgs: ensure => "installed" }
}

class pip_install {
  package {
      "pip":
          ensure => latest,     
          provider => pip;
      "distribute":
          ensure => latest,     
          provider => pip;
  }
}


# Hadoop Master
# Also need to update
# /etc/puppet/modules/hadoop/files/hadoop_conf/masters
# /etc/puppet/modules/hadoop/files/hadoop_conf/core-site.xml
# /etc/puppet/modules/hadoop/files/hadoop_conf/mapred-site.xml
node {{master}} {
  stage { [b0, b1, a0, a1, a2, a3]:}
  Stage[b0] -> Stage[b1] -> Stage[main] -> Stage[a0] -> Stage[a1] -> Stage[a2] -> Stage[a3]
  class {standard_install: stage => b0}
  class {hadoop: stage => b0}
  class {pip_install: stage => b1}
  class {picarus: stage => a0}
  class {picarus_pre: stage => b1}
  class {install_java_apt: stage => main}
  class {install_java: stage => a0}
  class {hadoop_master: stage => a1}
  class {hadoop_base: stage => a1}
  class {hadoop_master_format: stage => a2}
  class {hadoop_master_start: stage => a3}
  class {cron_20min: stage => a3}
}

# Hadoop Slaves
# Also need to update
# /etc/puppet/modules/hadoop/files/hadoop_conf/slaves
node {{slaves}} {
  stage { [b0, b1, a0, a1, a2, a3]:}
  Stage[b0] -> Stage[b1] -> Stage[main] -> Stage[a0] -> Stage[a1] -> Stage[a2] -> Stage[a3]
  class {standard_install: stage => b0}
  class {hadoop: stage => b0}
  class {pip_install: stage => b1}
  class {picarus: stage => a0}
  class {picarus_pre: stage => main}
  class {install_java_apt: stage => b1}
  class {install_java: stage => a0}
  class {hadoop_slave: stage => a1}
  class {hadoop_base: stage => a1}
  class {hadoop_slave_start: stage => a3}
  class {cron_20min: stage => a3}
}
