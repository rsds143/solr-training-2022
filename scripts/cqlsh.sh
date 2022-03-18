#!/bin/sh

CASS_USER=$(kubectl get secret -n cass-operator solrtraining-superuser -o=jsonpath="{.data.username}"| base64 --decode)
CASS_PASS=$(kubectl get secret -n cass-operator solrtraining-superuser -o=jsonpath="{.data.password}" | base64 --decode)
kubectl exec -ti -n cass-operator solrtraining-dc1-default-sts-0 -c cassandra -- sh -c "cqlsh -u '$CASS_USER' -p '$CASS_PASS'"
