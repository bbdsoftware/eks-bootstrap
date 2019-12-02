helm delete --purge aws-alb-ingress-controller
helm delete --purge external-dns
helm delete --purge nginx-ingress
kubectl delete  -f alb-nginx-controller.yaml
kubectl delete ns ingress-system


