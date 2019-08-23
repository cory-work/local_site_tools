# Copyright (c) 2019 Adobe
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

#! /bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

if [ -z "$1" ]
then
	echo please provide a domain
	exit 1
fi

# Common vars
DOMAIN=$1
BASE_DIR=`eval echo "~$SUDO_USER"/sites/$DOMAIN`
CERT_DIR=$BASE_DIR/certs
LOG_DIR=$BASE_DIR/log
WWW_DIR=$BASE_DIR/www
ROOT_CERT_DIR=root_certs

rm -rf BASE_DIR $WWW_DIR
rm /usr/local/etc/dnsmasq.d/${DOMAIN}.conf
rm /etc/resolver/${DOMAIN}
rm /usr/local/etc/nginx/servers/${DOMAIN}.conf

sudo -u $SUDO_USER brew services restart nginx
brew services restart dnsmasq

#flush cache
echo Flush DNS cache
killall -HUP mDNSResponder
killall mDNSResponderHelper
dscacheutil -flushcache
