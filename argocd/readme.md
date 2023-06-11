# Notes

using quickstart guide from: https://argo-cd.readthedocs.io/en/stable/getting_started/

```shell
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
```

```shell
export ARGOCD_OPTS='--port-forward-namespace argocd'
```
