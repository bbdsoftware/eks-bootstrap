helm repo add argo https://argoproj.github.io/argo-helm
helm update
helm upgrade argocd --install  -f values.yaml  --namespace argo-cd argo/argo-cd
kubectl apply -f ingress.yaml