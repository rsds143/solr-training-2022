#!/bin/sh

#Installs cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.7.1/cert-manager.yaml
# use helm to install cass-operator
helm repo add k8ssandra https://helm.k8ssandra.io/stable
helm install cass-operator k8ssandra/cass-operator -n cass-operator --create-namespace
