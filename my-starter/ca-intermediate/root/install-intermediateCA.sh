#!/bin/bash


######### INTERMEDIATE CA ###########
# prep the intermediate ca dirs
cd /root/ca

mkdir certs crl newcerts private csr signed unsigned
chmod 700 private
touch index.txt
echo 1000 > serial
echo 1000 > ./crlnumber

# create the intermediate CA key 
openssl genrsa -aes256 -out private/intermediate.key.pem 4096
chmod 400 private/intermediate.key.pem

# create the intermediate cert
openssl req -config ./openssl.cnf \
      -new -sha256 \
      -key private/intermediate.key.pem \
      -out csr/intermediate.csr.pem
