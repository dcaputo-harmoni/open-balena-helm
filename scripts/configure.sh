#!/bin/bash -e

CONFIG_DIR=$(dirname "$0")/../config
OPENBALENA_DIR=$(dirname "$0")/../open-balena
CERTS_DIR=${OPENBALENA_DIR}/config/certs
HELM_CERTS_DIR=$(dirname "$0")/../helm/certs

echo "==> Creating Openbalena Helm configuration..."
source "${OPENBALENA_DIR}/config/activate";
envsubst < "${CONFIG_DIR}/values.template.yaml" > "${CONFIG_DIR}/values.yaml"

# Copy certs into helm folder
mkdir -p ${HELM_CERTS_DIR}
cp ${CERTS_DIR}/root/ca.crt ${HELM_CERTS_DIR}/root-ca.crt
more -1000 +/"-----BEGIN CERTIFICATE-----" $CERTS_DIR/root/issued/\*.$OPENBALENA_HOST_NAME.crt | sed '1,4d' > ${HELM_CERTS_DIR}/root-cert.crt
cp ${CERTS_DIR}/root/private/\*.${OPENBALENA_HOST_NAME}.key ${HELM_CERTS_DIR}/root-cert.key
cp ${CERTS_DIR}/api/api.${OPENBALENA_HOST_NAME}.crt ${HELM_CERTS_DIR}/api-cert.crt
cp ${CERTS_DIR}/api/api.${OPENBALENA_HOST_NAME}.pem ${HELM_CERTS_DIR}/api-cert.key
cp ${CERTS_DIR}/vpn/ca.crt ${HELM_CERTS_DIR}/vpn-ca.crt
more -1000 +/"-----BEGIN CERTIFICATE-----" $CERTS_DIR/vpn/issued/vpn.$OPENBALENA_HOST_NAME.crt | sed '1,4d' > ${HELM_CERTS_DIR}/vpn-cert.crt
cp ${CERTS_DIR}/vpn/private/vpn.${OPENBALENA_HOST_NAME}.key ${HELM_CERTS_DIR}/vpn-cert.key
cp ${CERTS_DIR}/vpn/dh.pem ${HELM_CERTS_DIR}/vpn-dh.pem