#!/bin/bash

# Load local cluster
kubectl config use-context docker-desktop

# Create namespaces
kubectl create namespace openbalena

# Install / update helm chart dependencies
helm repo add haproxy-ingress https://haproxy-ingress.github.io/charts
helm repo update haproxy-ingress
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update grafana
helm repo add stakater https://stakater.github.io/stakater-charts
helm repo update stakater

# Optionally generate open-balena config
if [ "$1" == "generate-config" ]; then
    echo "Generating openbalena config..."
    if [[ ( -z "$2" || -z "$3" || -z "$4" || -z "$5" ) ]]; then
      echo "You must specify four parameters after \"generate-config\": hostname, certificate email address, superuser password and database password"
      exit 1
    fi
    rm -rf $(dirname "$0")/../open-balena/config
    sed -i 's#| fold -w "${1:-32}" | head -n 1#2>/dev/null | head -c ${1:-32}#g' $(dirname "$0")/../open-balena/scripts/make-env
    $(dirname "$0")/../open-balena/scripts/quickstart -U balena@$2 -P $4 -d $2
    sed -i 's#2>/dev/null | head -c ${1:-32}#| fold -w "${1:-32}" | head -n 1#g' $(dirname "$0")/../open-balena/scripts/make-env
    echo "export OPENBALENA_DB_USERNAME=docker" >> $(dirname "$0")/../open-balena/config/activate
    echo "export OPENBALENA_DB_PASSWORD=$5" >> $(dirname "$0")/../open-balena/config/activate
    echo "export OPENBALENA_CERT_EMAIL=$3" >> $(dirname "$0")/../open-balena/config/activate
else
    if [ ! -f "$(dirname "$0")/../open-balena/config/activate" ]; then
        echo "You must specify \"generate-config\" when no existing config exists"
        exit 1
    fi
fi

# Configure helm values
source "$(dirname "$0")/../open-balena/config/activate";
envsubst < "$(dirname "$0")/../config/values.template.yaml" > "$(dirname "$0")/../config/values.yaml"

# Prepare certs for helm deployment
CERTS_DIR=$(dirname "$0")/../open-balena/config/certs
HELM_CERTS_DIR=$(dirname "$0")/../helm/certs
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

# Install openbalena
helm install openbalena $(dirname "$0")/../helm -f $(dirname "$0")/../config/values.yaml -n openbalena --dependency-update --wait \
    --set issuers.acme.email=$OPENBALENA_CERT_EMAIL