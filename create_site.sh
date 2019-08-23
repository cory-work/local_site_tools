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
WWW_DIR=$BASE_DIR/www
ROOT_CERT_DIR=root_certs

# setup directories
sudo -u $SUDO_USER mkdir -p $WWW_DIR
sudo -u $SUDO_USER mkdir -p $CERT_DIR
sudo -u $SUDO_USER mkdir -p $BASE_DIR

# create new dnsmasq.conf for domain
echo Create new dnsmasq entry for $DOMAIN
sudo -u $SUDO_USER echo address=/${DOMAIN}/127.0.0.1 > /usr/local/etc/dnsmasq.d/${DOMAIN}.conf

# add new domain to /etc/resolver
echo Adding $DOMAIN to /etc/resolver
echo nameserver 127.0.0.1 > /etc/resolver/${DOMAIN}

echo "Generating cert for $DOMAIN"
sudo -u $SUDO_USER openssl genrsa -out $CERT_DIR/site.key 2048

rm -f $CERT_DIR/site.cnf
sudo -u $SUDO_USER cp /etc/ssl/openssl.cnf $CERT_DIR/site.cnf
echo "" >> $CERT_DIR/site.cnf
echo "[SAN]" >> $CERT_DIR/site.cnf
echo "subjectAltName=DNS:$DOMAIN,DNS:*.$DOMAIN" >> $CERT_DIR/site.cnf
sudo -u $SUDO_USER openssl req -new -sha256 -key $CERT_DIR/site.key -subj "/C=US/ST=UT/O=Adobe/CN=$DOMAIN" -reqexts SAN -config $CERT_DIR/site.cnf -out $CERT_DIR/site.csr
sudo -u $SUDO_USER openssl x509 -req -sha256 -in $CERT_DIR/site.csr -CA $ROOT_CERT_DIR/rootCA.crt -CAkey $ROOT_CERT_DIR/rootCA.key -CAcreateserial -out $CERT_DIR/site.crt -days 500 -extfile $CERT_DIR/site.cnf -extensions SAN

# add nginx config
NGINX_CONF_FILE=/usr/local/etc/nginx/servers/${DOMAIN}.conf
sudo -u $SUDO_USER cp nginx.template.conf $NGINX_CONF_FILE
perl -pi -e "s#<DOMAIN>#$DOMAIN#g" $NGINX_CONF_FILE
perl -pi -e "s#<WWW_DIR>#$WWW_DIR#g" $NGINX_CONF_FILE
perl -pi -e "s#<CERT_DIR>#$CERT_DIR#g" $NGINX_CONF_FILE

# add index.html
INDEX_HTML_FILE=$WWW_DIR/index.html
sudo -u $SUDO_USER cp index.template.html $INDEX_HTML_FILE
perl -pi -e "s#<DOMAIN>#$DOMAIN#g" $INDEX_HTML_FILE
perl -pi -e "s#<WWW_DIR>#$WWW_DIR#g" $INDEX_HTML_FILE


sudo -u $SUDO_USER brew services restart nginx
brew services restart dnsmasq

#flush cache
echo Flush DNS cache
killall -HUP mDNSResponder
killall mDNSResponderHelper
dscacheutil -flushcache
