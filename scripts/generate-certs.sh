#!/bin/sh
#
# Script to generate new self-signed device and CA certs for meza

if [ -z "$1" ]; then
	echo
	echo "ERROR: Must pass one argument to this script: Common Name"
	echo "Common Name should be the domain name used for this server"
	exit 1
fi

if [ "$(whoami)" != "root" ]; then
	echo "Try running this script with sudo: \"sudo bash generate-certs.sh\""
	exit 1
fi

keydir=/etc/pki/tls/private
certdir=/etc/pki/tls/certs

ca_key="$keydir/meza-ca.key"
ca_cert="$certdir/meza-ca.crt"

device_csr="/tmp/meza.csr"

device_key="$keydir/meza.key"
device_cert="$certdir/meza.crt"

ca_subj="/C=US/ST=TX/L=Houston/O=EnterpriseMediaWiki/CN=enterprisemediawiki.org"
device_subj="/C=US/ST=TX/L=Houston/O=EnterpriseMediaWiki/CN=$1"

timestamp=$(date "+%Y%m%d%H%M%S")

# Move any existing certs and keys
for FILE in "$ca_key" "$ca_cert" "$device_key" "$device_cert"
do
	if [ -f "$FILE" ]; then
		echo "Moving $FILE to $FILE.$timestamp"
		mv "$FILE" "$FILE.$timestamp"
	fi
done

# Remove any preexisting CSR
if [ -f "$device_csr" ]; then
	rm "$device_csr"
fi

echo
echo "Generate CA key"
openssl genrsa -out "$ca_key" 2048

echo
echo "Generate CA Certificate"
openssl req -x509 -new -nodes -key "$ca_key" -sha256 -days 1024 -subj "$ca_subj" -out "$ca_cert"

echo
echo "Generate device key"
openssl genrsa -out "$device_key" 2048

echo
echo "Generate Certificate Signing Request"
# openssl req -new -key "$device_key" -subj "$device_subj" -out "$device_csr"
openssl req -new -key "$device_key" -sha256 -nodes -subj "$device_subj" > "$device_csr"

echo
echo "Create certificate meza.crt signed by meza-ca.crt"
openssl x509 -req -in "$device_csr" -CA "$ca_cert" -CAkey "$ca_key" -CAcreateserial -out "$device_cert" -days 500 -sha256

# Remove the certificate signing request
rm "$device_csr"

echo
echo "Complete generating meza self-signed cert"
