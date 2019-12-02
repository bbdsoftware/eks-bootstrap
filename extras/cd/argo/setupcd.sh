helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm upgrade argocd  argo/argo-cd    --set nameOverride=nargocd  --set fullnameOverride=argocd --namespace argo-cd -f values-argo.yaml  --install
kubectl apply -f argo-ingress.yaml