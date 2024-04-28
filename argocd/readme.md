# Notes

This is installing argo-cd using the community provided chart from here: https://github.com/argoproj/argo-helm/tree/main/charts/argo-cd

```shell
helm repo add argo-cd https://argoproj.github.io/argo-helm
helm repo update
# install CRDs outside of chart
kubectl apply -k "https://github.com/argoproj/argo-cd/manifests/crds?ref=v2.10.8"
kubectl create ns argocd
helm upgrade --install -n argocd argo-cd argo-cd/argo-cd -f argocd/values.yaml
```


```shell
export ARGOCD_OPTS='--port-forward-namespace argocd'
```
