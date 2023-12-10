#!/bin/bash

# Load local cluster
kubectl config use-context docker-desktop

# Create namespaces
kubectl create namespace cert-manager

# Install / update helm chart dependencies
helm repo add jetstack https://charts.jetstack.io
helm repo update jetstack

helm install cert-manager jetstack/cert-manager -n cert-manager --wait \
  --version 1.11.1 \
  --set installCRDs=true
