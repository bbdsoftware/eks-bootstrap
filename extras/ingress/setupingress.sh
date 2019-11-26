kubectl create ns ingress-system
helm upgrade --install incubator/aws-alb-ingress-controller --name alb-ingress-controller --set nameOverride=alb-ingress-controller --set fullnameOverride=alb-ingress-controller --namespace ingress-system -f values-alb-ingress
helm upgrade --install stable/external-dns --name external-dns --set nameOverride=external-dns --set fullnameOverride=external-dns --namespace ingress-system -f values-external-dns.yaml
helm upgrade --install stable/nginx-ingress --name nginx-ingress --set nameOverride=nginx-ingress --set fullnameOverride=nginx-ingress --namespace ingress-system -f values-nginx-ingress.yaml
kubectl apply  -f nginx-ing.yaml


