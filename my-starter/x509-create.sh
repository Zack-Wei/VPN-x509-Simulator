#!/bin/bash

#  my-starter
#   |
#   +--x509-sign.sh (this script)
#   |
#   +--ca-root
#   |   |
#   |   +--root/ca
#   |       |
#   |       +--openssl.cnf (config for a root ca)
#   |       |
#   |       \--(various dirs, certs and keys)
#   |    
#   +--ca-intermediate
#   |   |
#   |   +--root/ca
#   |       |
#   |       +--openssl.cnf (config for a root ca)
#   |       |
#   |       \--(various dirs, certs and keys)
#   |    
#   \--server-web
#       |
#       +--root/ca
#           |
#           +--openssl.cnf (config for a server)
#           |
#           \--(various certs and keys)
# 

X509DIR=$PWD

######### ROOT CA ##########
# prep the ca dirs
cd ./ca-root/root/ca

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

# verify the root cert
openssl x509 -noout -text -in certs/ca.cert.pem

######### INTERMEDIATE CA ###########
# prep the intermediate ca dirs
cd $X509DIR

cd ./ca-intermediate/root/ca

mkdir certs crl newcerts private csr signed unsigned
chmod 700 private
touch index.txt
echo 1000 > serial
echo 1000 > ./crlnumber

# create the intermediate CA key "intermediate_secret"
openssl genrsa -aes256 -out private/intermediate.key.pem 4096
chmod 400 private/intermediate.key.pem

# create the intermediate cert
openssl req -config ./openssl.cnf \
      -new -sha256 \
      -key private/intermediate.key.pem \
      -out csr/intermediate.csr.pem


########## ROOT CA SIGNS INTERMEDIATE CA ##############
# send the intermediate cert csr to the root ca
cd ${X509DIR}
cp ./ca-intermediate/root/ca/csr/intermediate.csr.pem ./ca-root/root/ca/unsigned/

# get the intermdiate cert signed by the root cert
cd ./ca-root/root/ca
openssl ca -config ./openssl.cnf \
      -extensions v3_intermediate_ca \
      -days 3650 -notext -md sha256 \
      -in unsigned/intermediate.csr.pem \
      -out signed/intermediate.cert.pem
chmod 444 signed/intermediate.cert.pem

# verify the intermediate cert
openssl x509 -noout -text -in signed/intermediate.cert.pem
      
# verify against root cert      
openssl verify -CAfile certs/ca.cert.pem \
      signed/intermediate.cert.pem      

# return it to the intermediate ca
cd ${X509DIR}
cp ./ca-root/root/ca/signed/intermediate.cert.pem ./ca-intermediate/root/ca/certs/
chmod 444 ./ca-intermediate/root/ca/certs/intermediate.cert.pem

#When the browser verifies the intermediate certificate
#It will also verify whether its upper-level certificate is reliable
#Create a certificate chain, and merge the root cert and intermediate cert together
#So that the browser can verify them together
cd ${X509DIR}
cat ./ca-intermediate/root/ca/certs/intermediate.cert.pem \
      ./ca-root/root/ca/certs/ca.cert.pem > ./ca-intermediate/root/ca/certs/ca-chain.cert.pem
chmod 444 ./ca-intermediate/root/ca/certs/ca-chain.cert.pem

########## SERVER ####################
# prep the server dirs
cd ${X509DIR}
cd ./server-web/root/ca

# generate the server key 
# Set the server/client certificate expiration time to one year,
# So 2048 encryption can be safely used.
openssl genrsa -aes256 -out server.key.pem 2048
chmod 400 server.key.pem

# generate the server cert
openssl req -config ./openssl.cnf \
      -key server.key.pem \
      -new -sha256 \
      -out server.csr.pem


######### INTERMDEDIATE CA SIGNS SERVER CSR #################
# send the server cert csr to the intermediate ca
cd ${X509DIR}
cp ./server-web/root/ca/server.csr.pem ./ca-intermediate/root/ca/unsigned/

# get the server cert signed by the intermediate cert
cd ./ca-intermediate/root/ca/
openssl ca -config ./openssl.cnf \
      -extensions server_cert \
      -days 375 \
      -notext -md sha256 \
      -in unsigned/server.csr.pem \
      -out signed/server.cert.pem
chmod 444 signed/server.cert.pem

# verify the cert
openssl x509 -noout -text -in signed/server.cert.pem
openssl verify -CAfile ./certs/ca-chain.cert.pem \
      ./signed/server.cert.pem 
 
# return it to the server and example client
cd ${X509DIR}
cp ./ca-intermediate/root/ca/signed/server.cert.pem ./server-web/root/ca/
cp ./ca-intermediate/root/ca/certs/ca-chain.cert.pem ./server-web/root/ca/
chmod 444 ./server-web/root/ca/server.cert.pem

cp ./ca-intermediate/root/ca/certs/ca-chain.cert.pem ./remote-user-1/root/
cp ./ca-intermediate/root/ca/certs/ca-chain.cert.pem ./remote-user-2/root/


