#!/bin/bash
# install necessary packages
#cp /etc/apt/sources.list /etc/apt/sources.list.bak
#cat /etc/apt/sources.list.bak | sed 's/#deb/deb/g' > /etc/apt/sources.list
apt-get update
apt-get install -y libopenssl-ruby rdoc libopenssl-ruby1.8 libreadline-ruby1.8 libruby1.8 rdoc1.8 ruby1.8
# Install facter (used by puppet to determine system config)
wget -N http://downloads.puppetlabs.com/facter/facter-1.6.9.tar.gz
tar -xzf facter-1.6.9.tar.gz
cd facter-1.6.9
ruby1.8 install.rb
cd ..
# Install puppet
wget -N http://downloads.puppetlabs.com/puppet/puppet-2.7.14.tar.gz
tar -xzf puppet-2.7.14.tar.gz
cd puppet-2.7.14
ruby1.8 install.rb