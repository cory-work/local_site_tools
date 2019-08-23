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

#/bin/bash

TARGET=root_certs
mkdir -p $TARGET

printf "#Generating Root CA key\n"
openssl genrsa -des3 -out $TARGET/rootCA.key.orig 2048

printf "\n#Removing passphrase\n"
openssl rsa -in $TARGET/rootCA.key.orig -out $TARGET/rootCA.key
rm rootCA.key.orig

printf "\n#Generating Root CA cert\n"
openssl req -x509 -new -nodes -key $TARGET/rootCA.key -sha256 -days 1024 -out $TARGET/rootCA.crt -config rootCA.conf

printf "\n#Done\n\n#To import this certificate to keychain, run: \n\tsudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain $TARGET/rootCA.crt\n"

