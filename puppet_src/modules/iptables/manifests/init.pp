class iptables($whitelist) {
  package { "iptables-persistent": ensure => "installed" }

  file { "/etc/iptables/rules.v4":
      owner   => root,
      group   => root,
      mode    => 700,
      content => template("iptables/iptables.rules.erb"),
      require => Package['iptables-persistent']
  }
}