#!/bin/bash

X509DIR=$PWD

cd ${X509DIR}
cd ./ca-intermediate/root/ca

###############Client VPN###################
echo "echo message: generate the ipsec-client key"

# generate the private key for the client
pki --gen \
  --type ed25519 \
  --outform der > private/vpn_client_key.der
  
chmod 600 private/vpn_client_key.der

# generate the related cert signing request
pki --pub \
  --in private/vpn_client_key.der \
  --type ecdsa \
  --outform der > unsigned/vpn_client_csr.der

# then get it signed / issued as a certificate by the intermediateCA
pki --issue \
  --in unsigned/vpn_client_csr.der \
  --lifetime 1825 \
  --cacert certs/intermediate.cert.pem \
  --cakey private/intermediate.key.pem \
  --dn "C=UK, O=Lemington, OU=u2229437, CN=31.205.100.12" \
  --san 31.205.100.12  \
  --flag serverAuth \
  --flag ikeIntermediate \
  --outform der > signed/vpn_client_cert.der
  
# verify the cert
pki --print --in signed/vpn_client_cert.der
openssl x509 -inform DER -in signed/vpn_client_cert.der -noout -text

##################################

###############Server VPN###################
echo "echo message: generate the ipsec-server key"

# generate the private key for the server
pki --gen \
  --type ed25519 \
  --outform der > private/vpn_server_key.der

chmod 600 private/vpn_server_key.der
# generate the related cert signing request
pki --pub \
  --in private/vpn_server_key.der \
  --type ecdsa \
  --outform der > unsigned/vpn_server_csr.der

# then get it signed / issued as a certificate by the intermediateCA
pki --issue \
  --in unsigned/vpn_server_csr.der \
  --lifetime 1825 \
  --cacert certs/intermediate.cert.pem \
  --cakey private/intermediate.key.pem \
  --dn "C=UK, O=Lemington, OU=u2229437, CN=213.0.133.163" \
  --san 213.0.133.163  \
  --flag serverAuth \
  --flag ikeIntermediate \
  --outform der > signed/vpn_server_cert.der
  
# verify
pki --print --in signed/vpn_server_cert.der
openssl x509 -inform DER -in signed/vpn_server_cert.der -noout -text

##################################

# copy the certs to the server and client
cd ${X509DIR}

cp ./ca-intermediate/root/ca/signed/vpn_client_cert.der ./gw2-ipsec/etc/ipsec.d/certs/
cp ./ca-intermediate/root/ca/signed/vpn_server_cert.der ./gw2-ipsec/etc/ipsec.d/certs/

cp ./ca-intermediate/root/ca/signed/vpn_client_cert.der ./r1/etc/ipsec.d/certs/
cp ./ca-intermediate/root/ca/signed/vpn_server_cert.der ./r1/etc/ipsec.d/certs/

cp ./ca-intermediate/root/ca/private/vpn_server_key.der ./gw2-ipsec/etc/ipsec.d/private/
cp ./ca-intermediate/root/ca/private/vpn_client_key.der ./r1/etc/ipsec.d/private/

echo "echo message: all done!"