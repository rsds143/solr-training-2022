#!/usr/bin/env

#Installs cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.7.1/cert-manager.yaml
#Installs cass-operator which rights to every namespace
kubectl apply -k github.com/k8ssandra/cass-operator/config/deployments/cluster?ref=v1.10.1
