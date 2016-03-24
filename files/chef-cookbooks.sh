#!/usr/bin/env bash
sudo rm -rf /var/chef/cookbooks
sudo mkdir -p /var/chef/cookbooks
for DEP in apt apt-chef yum yum-chef      ; do curl -sL https://supermarket.chef.io/cookbooks/${DEP}/download | sudo tar xzC /var/chef/cookbooks; done
for DEP in chef-ingredient fancy_execute  ; do curl -sL https://supermarket.chef.io/cookbooks/${DEP}/download | sudo tar xzC /var/chef/cookbooks; done
for DEP in hostsfile packagecloud         ; do curl -sL https://supermarket.chef.io/cookbooks/${DEP}/download | sudo tar xzC /var/chef/cookbooks; done
for DEP in supermarket-omnibus-cookbook   ; do curl -sL https://supermarket.chef.io/cookbooks/${DEP}/download | sudo tar xzC /var/chef/cookbooks; done
sudo chown -R root:root /var/chef/cookbooks
echo Finished

