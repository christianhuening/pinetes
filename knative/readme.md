linkerd install | kubectl apply -f -
kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.7.1/serving-crds.yaml
kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.7.1/serving-core.yaml
# kourier ingress
kubectl apply -f https://github.com/knative/net-kourier/releases/download/knative-v1.7.0/kourier.yaml
# patch knative config to use kourier ingress by default
kubectl patch configmap/config-network \
  --namespace knative-serving \
  --type merge \
  --patch '{"data":{"ingress-class":"kourier.ingress.networking.knative.dev"}}'
# setup DNS
kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.7.1/serving-default-domain.yaml
