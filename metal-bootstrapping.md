https://github.com/ipxe/pipxe

## Install tinkerbell

from within tinkerbell/charts/tinkerbell, run

```shell
helm dependency build stack/
trusted_proxies=$(kubectl get nodes -o jsonpath='{.items[*].spec.podCIDR}' | tr ' ' ',')
helm upgrade --install stack-release stack/ --create-namespace --namespace tink-system --wait --set "boots.trustedProxies=${trusted_proxies}" --set "hegel.trustedProxies=${trusted_proxies}" --set "stack.kubevip.enabled=false"
```

We disable `kubevip` because metalLB is used as Load Balancer and working just fine.

### Enable flatcar image

Basically follow this guide: https://tinkerbell.org/examples/flatcar-container-linux/
But build the image for multiarch:
`docker buildx build --platform linux/arm/v7,linux/arm64/v8,linux/amd64 -t $TINKERBELL_HOST_IP/flatcar-install .`