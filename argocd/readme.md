# Notes

using quickstart guide from: https://argo-cd.readthedocs.io/en/stable/getting_started/

```shell
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl -n argocd set image deploy/argocd-applicationset-controller argocd-applicationset-controller=ghcr.io/jr64/argocd-applicationset:v0.4.0
```

```shell
export ARGOCD_OPTS='--port-forward-namespace argocd'
```

