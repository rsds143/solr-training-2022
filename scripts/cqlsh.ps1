$RAW_CASS_USER = kubectl get secret solrtraining-superuser -o=jsonpath="{.data.username}"
$CASS_USER = [Text.Encoding]::Utf8.GetString([Convert]::FromBase64String($RAW_CASS_USER))
$RAW_CASS_PASS=kubectl get secret solrtraining-superuser -o=jsonpath="{.data.password}"
$CASS_PASS = [Text.Encoding]::Utf8.GetString([Convert]::FromBase64String($RAW_CASS_PASS))
kubectl exec -ti solrtraining-dc1-default-sts-0 -c cassandra -- sh -c "cqlsh -u '$CASS_USER' -p '$CASS_PASS'"