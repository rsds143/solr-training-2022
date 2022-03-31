#!/bin/sh

kubectl exec -ti -n cass-operator dse51-datastax-dse-0 -c datastax-dse -- sh -c -- cqlsh
