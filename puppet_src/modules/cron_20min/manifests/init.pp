class cron_20min {
    $first = fqdn_rand(20)
    $second = fqdn_rand(20) + 20
    $third = fqdn_rand(20) + 40
    cron { "cron.puppet.onetime":
        command => "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/bin:/usr/local/bin puppet agent -t --server {{pmaster}} &> /tmp/puppet.log",
        user => "root",
        minute => [ $first, $second , $third],
  }
}