
X509DIR=$PWD

##########vpn SERVER ####################
# prep the server dirs
cd ${X509DIR}
cd ./gw2-ipsec/etc/ipsec.d

mkdir -p private certs reqs

# generate the server key 
# Set the server/client certificate expiration time to one year,
# So 2048 encryption can be safely used.
openssl genrsa -aes256 -out ./private/ipsec-server.key.pem 2048
chmod 400 ./private/ipsec-server.key.pem

# generate the server cert
openssl req -config ./openssl.cnf \
      -key ./private/ipsec-server.key.pem \
      -new -sha256 \
      -out ./certs/ipsec-server.csr.pem

# generate the client key 
# Set the server/client certificate expiration time to one year,
# So 2048 encryption can be safely used.
openssl genrsa -aes256 -out ./private/ipsec-client.key.pem 2048
chmod 400 /private/ipsec-client.key.pem

# generate the client cert
openssl req -config ./openssl.cnf \
      -key ./private/ipsec-client.key.pem \
      -new -sha256 \
      -out ./certs/ipsec-client.csr.pem

######### INTERMDEDIATE CA SIGNS SERVER/CLIENT CSR #################
# send the server cert csr to the intermediate ca
cd ${X509DIR}
cp ./gw2-ipsec/etc/ipsec.d/certs/ipsec-server.csr.pem ./ca-intermediate/root/ca/unsigned/
cp ./gw2-ipsec/etc/ipsec.d/certs/ipsec-client.csr.pem ./ca-intermediate/root/ca/unsigned/

# get the ipsec cert signed by the intermediate cert
cd ./ca-intermediate/root/ca/
openssl ca -config ./openssl.cnf \
      -extensions server_cert \
      -days 375 \
      -notext -md sha256 \
      -in unsigned/ipsec-server.csr.pem \
      -out signed/ipsec-server.cert.pem
chmod 444 signed/ipsec-server.cert.pem
openssl ca -config ./openssl.cnf \
      -extensions server_cert \
      -days 375 \
      -notext -md sha256 \
      -in unsigned/ipsec-client.csr.pem \
      -out signed/ipsec-client.cert.pem
chmod 444 signed/ipsec-client.cert.pem

# verify the cert
openssl x509 -noout -text -in signed/ipsec-server.cert.pem
openssl verify -CAfile ./certs/ca-chain.cert.pem \
      ./signed/ipsec-server.cert.pem 
openssl x509 -noout -text -in signed/ipsec-client.cert.pem
openssl verify -CAfile ./certs/ca-chain.cert.pem \
      ./signed/ipsec-client.cert.pem 

# return it to the server and client
cd ${X509DIR}
cp ./ca-intermediate/root/ca/signed/ipsec-server.cert.pem ./gw2-ipsec/etc/ipsec.d/certs/
cp ./ca-intermediate/root/ca/signed/ipsec-client.cert.pem ./gw2-ipsec/etc/ipsec.d/certs/
cp ./ca-intermediate/root/ca/signed/ipsec-client.cert.pem ./r1/etc/ipsec.d/certs/

cp ./ca-intermediate/root/ca/certs/ca-chain.cert.pem ./gw2-ipsec/etc/ipsec.d/cacerts/
cp ./ca-intermediate/root/ca/certs/ca-chain.cert.pem ./r1/etc/ipsec.d/cacerts/