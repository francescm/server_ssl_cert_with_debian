#!/bin/bash

if [ -z "$2" ]
then
  echo "Usage: ${0} cert_id_number cert_name"
  exit 2
fi
CERT_ID=$1
CERT_NAME=$2

COLLECT_URL="https://cert-manager.com/api/ssl/v1/collect/${CERT_ID}/x509CO"
COLLECT_CA_URL="https://cert-manager.com/customer/GARR/ssl?action=download&sslId=${CERT_ID}&format=x509IOR"

CERT_FILE="./certs/${CERT_NAME}_${CERT_ID}.pem"
TMP_CERT_FILE="./tmp_${CERT_NAME}_${CERT_ID}.pem"
TMP_CA_CERT_FILE="./tmp_ca_${CERT_NAME}_${CERT_ID}.pem"

echo $COLLECT_URL

curl $COLLECT_URL -X GET --config .config -s -o $TMP_CERT_FILE
curl $COLLECT_CA_URL -X GET --config .config -s -o $TMP_CA_CERT_FILE

sh bagcerts.sh $TMP_CERT_FILE $TMP_CA_CERT_FILE  > $CERT_FILE

rm $TMP_CERT_FILE
rm $TMP_CA_CERT_FILE

