#!/bin/bash

# Load local cluster
kubectl config use-context docker-desktop

# Delete Openbalena PVCs in background
pvcs=$(kubectl get pvc --namespace openbalena | grep openbalena | cut -f1 -d ' ')
for i in $pvcs; do
  kubectl delete pvc $i --namespace openbalena &
done

# Allow openbalena pvs to be reclaimed
pvs=$(kubectl get pv | grep openbalena | cut -f1 -d ' ')
for i in $pvs; do
  kubectl patch pv $i --type json --patch='[ { "op": "remove", "path": "/spec/claimRef/uid" } ]'
  kubectl patch pv $i --type json --patch='[ { "op": "remove", "path": "/spec/claimRef/resourceVersion" } ]'
done

# Uninstall openbalena
helm uninstall openbalena --namespace openbalena --wait

# Delete certificate issuer
#kubectl delete -f $(dirname "$0")/cert-issuers/openbalena-cert-issuer.yaml

kubectl delete namespace openbalena