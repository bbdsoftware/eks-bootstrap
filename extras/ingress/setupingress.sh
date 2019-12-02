helm repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com/
helm repo update
kubectl create ns ingress-system
helm upgrade aws-alb-ingress-controller incubator/aws-alb-ingress-controller    --set nameOverride=alb-ingress-controller  --set fullnameOverride=alb-ingress-controller --namespace ingress-system  -f values-alb-ingress.yaml  --install
helm upgrade external-dns               stable/external-dns     --set nameOverride=external-dns  --set fullnameOverride=external-dns --namespace ingress-system -f values-external-dns.yaml  --install
helm upgrade nginx-ingress              stable/nginx-ingress    --set nameOverride=nginx-ingress  --set fullnameOverride=nginx-ingress --namespace ingress-system -f values-nginx-ingress.yaml  --install
kubectl apply  -f alb-nginx-controller.yaml


