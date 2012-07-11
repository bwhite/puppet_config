class picarus_pre {
  exec {'pip install -q argparse':
      path => ['/usr/local/bin', '/opt/local/bin', '/usr/bin', '/usr/sbin', '/bin', '/sbin'],
      unless => 'python -c "import argparse"',
  }
  package {
      "unittest2":
          ensure => latest,     
          provider => pip;
      "pil":
          ensure => latest,     
          provider => pip;
      "thrift":  # TODO(brandyn): This belongs in the hadoop module
          ensure => latest,     
          provider => pip;
      "cython":
          ensure => "0.16",
          provider => pip;
      "numpy":
          ensure => "1.6.2",
          provider => pip;
      "scipy":
          ensure => "0.10.1",
          provider => pip,
          require => Package["numpy"];
      "scikit-learn":
          ensure => "0.11",
          provider => pip,
          require => Package["numpy", "scipy"];
  }
}


class picarus {
  $b = "git+https://github.com/bwhite/"

  exec {'wget http://downloads.sourceforge.net/project/opencvlibrary/opencv-unix/2.4.2/OpenCV-2.4.2.tar.bz2 && tar -xjf OpenCV-2.4.2.tar.bz2 && mkdir OpenCV-2.4.2/build && cd OpenCV-2.4.2/build && cmake -D BUILD_TESTS=OFF -D BUILD_PERF_TESTS=OFF .. && make -j4 && make install':
      path => ['/usr/local/bin', '/opt/local/bin', '/usr/bin', '/usr/sbin', '/bin', '/sbin'],
      unless => 'python -c "import cv2"',
      logoutput => true,
      timeout => 3600
  }

  package {
      "image_server":
          ensure => latest,     
          provider => pip,
          source => "${b}image_server.git";
      "static_server":
          ensure => latest,     
          provider => pip,
          source => "${b}static_server.git";
      "imfeat":
          ensure => latest,     
          provider => pip,
          source => "${b}imfeat.git";
      "impoint":
          ensure => latest,     
          provider => pip,
          source => "${b}impoint.git";
      "distpy":
          ensure => latest,     
          provider => pip,
          source => "${b}distpy.git";
      "kernels":
          ensure => latest,     
          provider => pip,
          source => "${b}kernels.git";
      "keyframe":
          ensure => latest,     
          provider => pip,
          source => "${b}keyframe.git";
      "viderator":
          ensure => latest,     
          provider => pip,
          source => "${b}viderator.git";
      "vidfeat":
          ensure => latest,     
          provider => pip,
          source => "${b}vidfeat.git";
      "hadoopy":
          ensure => latest,     
          provider => pip,
          source => "${b}hadoopy.git";
      "hadoopy_hbase":
          ensure => latest,     
          provider => pip,
          source => "${b}hadoopy_hbase.git";
      "hadoopy_flow":
          ensure => latest,     
          provider => pip,
          source => "${b}hadoopy_flow.git";
      "picarus":
          ensure => latest,     
          provider => pip,
          source => "${b}picarus.git";
      "vision_data":
          ensure => latest,     
          provider => pip,
          source => "${b}vision_data.git";
  }
}