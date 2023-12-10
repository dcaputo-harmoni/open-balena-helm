# open-balena-helm
OpenBalena Kubernetes Helm repository

Requirements:

Docker w/ kubernetes enabled
Install docker
Settings -> Kubernetes -> Enable Kubernetes

kubectl
https://kubernetes.io/docs/tasks/tools/

helm
https://helm.sh/docs/intro/install/


Installation:

git clone https://github.com/dcaputo-harmoni/open-balena-helm.git
git submodule update --init --recursive

Forward *.openbalena.yourdomain.com to the public IP address of your docker host

Run scripts/install-cert-manager.sh
Run scripts/install-openbalena.sh regenerate-config <admin password> <db password>
