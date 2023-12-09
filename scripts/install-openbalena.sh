#!/bin/bash

hostname=openbalena.localhost

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

# Optionally regenerate open-balena config
if [ "$1" == "regenerate-config" ]; then
    echo "Regenerating openbalena config from scratch..."
    if [[ ( -z "$2" || -z "$3" ) ]]; then
      echo "You must specify two parameters after \"regenerate-config\": superuser-password and database-password"
      exit 1
    fi
    rm -rf $(dirname "$0")/../open-balena/config
    sed -i 's#| fold -w "${1:-32}" | head -n 1#2>/dev/null | head -c ${1:-32}#g' $(dirname "$0")/../open-balena/scripts/make-env
    $(dirname "$0")/../open-balena/scripts/quickstart -U balena@harmoni.io -P $2 -d $hostname
    sed -i 's#2>/dev/null | head -c ${1:-32}#| fold -w "${1:-32}" | head -n 1#g' $(dirname "$0")/../open-balena/scripts/make-env
    echo "export OPENBALENA_DB_USERNAME=docker" >> $(dirname "$0")/../open-balena/config/activate
    echo "export OPENBALENA_DB_PASSWORD=$3" >> $(dirname "$0")/../open-balena/config/activate
    $(dirname "$0")/configure.sh
else
    echo "Loading environment variables from existing openbalena config and creating secrets"
    if [ ! -d "$(dirname "$0")/../open-balena/config" ]; then
        echo "You must specify \"regenerate-config\" when no existing config exists"
        exit 1
    fi
    $(dirname "$0")/configure.sh
fi

# Install openbalena
helm install openbalena $(dirname "$0")/../helm -f $(dirname "$0")/../config/values.yaml -n openbalena --dependency-update --wait \
    --set global.hostname=$hostname \
    --set ingress.annotations."cert-manager\.io/issuer"=openbalena-certificate-issuer

# Install openbalena cert issuer
#kubectl apply -f $(dirname "$0")/cert-issuers/openbalena-cert-issuer.yaml