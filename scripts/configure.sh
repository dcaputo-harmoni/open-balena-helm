#!/bin/bash -e

CONFIG_DIR=$(dirname "$0")/../config
OPENBALENA_DIR=$(dirname "$0")/../open-balena

echo "==> Creating Openbalena Helm configuration..."
source "${OPENBALENA_DIR}/config/activate";
envsubst < "${CONFIG_DIR}/values.template.yaml" > "${CONFIG_DIR}/values.yaml"