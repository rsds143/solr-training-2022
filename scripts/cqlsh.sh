#!/bin/sh

CASS_USER=$(kubectl get secret solrtraining-superuser -o=jsonpath="{.data.username}"| base64 --decode)
CASS_PASS=$(kubectl get secret solrtraining-superuser -o=jsonpath="{.data.password}" | base64 --decode)
kubectl exec -ti solrtraining-dc1-default-sts-0 -c cassandra -- sh -c "cqlsh -u '$CASS_USER' -p '$CASS_PASS'"