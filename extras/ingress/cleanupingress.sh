kubectl create ns ingress-system
helm delete --purge   aws-alb-ingress-controller
helm delete --purge external-dns
helm delete --purge nginx-ingress
kubectl delete  -f nginx-ing.yaml


