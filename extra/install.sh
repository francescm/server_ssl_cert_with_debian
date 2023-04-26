#!/bin/bash


if [ "$#" -eq 0 ]; then
        echo "Usage: sh install.sh key_file"
        exit 0
fi


sudo apt-get install -y acl ssl-cert
sudo chmod 640 $1
sudo chown root:Debian-exim $1
sudo setfacl -m g:ssl-cert:r $1
sudo setfacl -m g:Debian-exim:x /etc/ssl/private
sudo mv -v $1 /etc/ssl/private
