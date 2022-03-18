#!/bin/sh

CASS_USER=$(kubectl get secret -n cass-operator solrtraining-superuser -o=jsonpath="{.data.username}"| base64 --decode)
CASS_PASS=$(kubectl get secret -n cass-operator solrtraining-superuser -o=jsonpath="{.data.password}" | base64 --decode)

kubectl run -i --tty --rm debug -n cass-operator --image=openjdk --restart=Never -- bash -c "curl -L -o /root/nb.jar https://github.com/nosqlbench/nosqlbench/releases/download/nosqlbench-4.15.90/nb.jar && java -jar /root/nb.jar cql-iot host=solrtraining-dc1-service username=$CASS_USER password=$CASS_PASS"
