#!/bin/bash

######### ROOT CA ##########
# prep the ca dirs

cd /root/ca/

mkdir -p certs crl newcerts private unsigned signed
chmod 700 private
touch index.txt
echo 1000 > serial

# create the root ca key 
openssl genrsa -aes256 -out private/ca.key.pem 4096
chmod 400 private/ca.key.pem

# create the root cert
openssl req -config ./openssl.cnf \
      -key private/ca.key.pem \
      -new -x509 \
      -days 7300 \
      -sha256 \
      -extensions v3_ca \
      -out certs/ca.cert.pem
#chmod 444 certs/ca.cert.pem

# verify the root cert
openssl x509 -noout -text -in certs/ca.cert.pem