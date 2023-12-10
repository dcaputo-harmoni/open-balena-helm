#!/bin/bash

# Load local cluster
kubectl config use-context docker-desktop

# Uninstall cert-manager
helm uninstall cert-manager -n cert-manager --wait