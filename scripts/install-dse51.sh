#!/bin/bash

helm install dse51 -n "cass-operator" --set image.tag=5.1.20 ./helm-charts/datastax-dse
