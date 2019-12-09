kubectl create ns logging-system
helm upgrade fluentd-cloudwatch  incubator/fluentd-cloudwatch    --set nameOverride=fluentd-cloudwatch  --set fullnameOverride=fluentd-cloudwatch --namespace logging-system -f values-logging.yaml  --install




