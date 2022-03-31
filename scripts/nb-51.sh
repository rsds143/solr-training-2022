#!/bin/sh

kubectl run -i --tty --rm debug -n cass-operator --image=openjdk --restart=Never -- bash -c "curl -L -o /root/nb.jar https://github.com/nosqlbench/nosqlbench/releases/download/nosqlbench-4.15.90/nb.jar && java -jar /root/nb.jar cql-iot host=dse51-datastax-dse-0.dse51-datastax-dse.cass-operator.svc.cluster.local"
