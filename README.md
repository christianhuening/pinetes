# Pinetes

This is about installing a k8s cluster on a set of raspberry pies with k3s or talos and cilium

## Talos Setup

0. Install Talos on rPI4: <https://www.talos.dev/v1.7/talos-guides/install/single-board-computers/rpi_generic/>
1. Install `talosctl`: `curl -sL https://talos.dev/install | sh`
2. Generate secrets: `talosctl gen secrets`
3. Generate configuration: `talosctl gen config pinetes https://192.168.178.73:6443 --with-secrets ./secrets.yaml --install-disk /dev/mmcblk0 --config-patch @patch.yaml`
4. Initialize the cluster control plane by running `talosctl apply-config --insecure  -n 192.168.178.73 -e 192.168.178.73 --file controlplane.yaml`
5. Initialize the worker nodes:

    ```shell
    #talosctl apply-config --insecure  -n 192.168.178.70 -e 192.168.178.70 --file worker.yaml
    talosctl apply-config --insecure  -n 192.168.178.71 -e 192.168.178.71 --file worker.yaml
    talosctl apply-config --insecure  -n 192.168.178.72 -e 192.168.178.72 --file worker.yaml
    ```

6. Init etcd: `talosctl bootstrap -e 192.168.178.73 --talosconfig ./talosconfig -n 192.168.178.73`

7. Get Kubeconfig: `talosctl kubeconfig --nodes <IP or Hostname>`
8. Install Cilium CNI with Transparent Link Encryption:

  ```shell
  helm upgrade --install \
    cilium \
    cilium/cilium \
    --version 1.15.5 \
    --namespace kube-system \
    --set ipam.mode=kubernetes \
    --set=kubeProxyReplacement=true \
    --set ipv6.enabled=false \
    --set=encryption.enabled=true \
    --set=encryption.type=wireguard \
    --set=encryption.nodeEncryption=true \
    --set=securityContext.capabilities.ciliumAgent="{CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}" \
    --set=securityContext.capabilities.cleanCiliumState="{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}" \
    --set=cgroup.autoMount.enabled=false \
    --set=cgroup.hostRoot=/sys/fs/cgroup \
    --set=k8sServiceHost=localhost \
    --set=k8sServicePort=7445
  ```

## K3s Setup

1. get Pi's (v4 8GB)
2. install them with Ubuntu Server 64bit
3. set new hostname: `hostnamectl set-hostname node-000X.pinetes`
4. update packages and everything: `sudo apt update && sudo apt upgrade -y`
5. (optional) install wireguard for cilium transparent link encryption: `sudo apt install wireguard`

for an initial install, proceed here:

1. (from: <https://docs.cilium.io/en/stable/installation/k3s/>): install k3s without flannel and kube-proxy: `curl -sfL https://get.k3s.io | INSTALL_K3S_CHANNEL=latest K3S_NODE_NAME=192.168.178.73 INSTALL_K3S_EXEC='--disable=servicelb --disable=traefik --flannel-backend=none --disable-network-policy --disable-kube-proxy --write-kubeconfig-mode "0644" --resolv-conf /run/systemd/resolve/resolv.conf --cluster-cidr=10.42.0.0/16,2001:cafe:42::/56 --service-cidr=10.43.0.0/16,2001:cafe:43::/112' sh -`
(resolv.conf bit was from [here](https://github.com/k3s-io/k3s/issues/4087#issuecomment-929374460), since coredns wouldn't get ready. More also [here](https://github.com/coredns/coredns/blob/master/plugin/loop/README.md#troubleshooting-loops-in-kubernetes-clusters))
(note that we disable the k3s klipper LB in favour of later installing metalLB)
(note that this creates a single-stack IPv6 cluster)

2. fetch Kubeconfig:

    ```shell
    scp ubuntu@192.168.178.73:/etc/rancher/k3s/k3s.yaml ./pinetes-kubeconfig
    gsed -i 's/127.0.0.1/192.168.178.73/g' pinetes-kubeconfig && chmod 600 pinetes-kubeconfig
    ```

for worker nodes here:
2. Add Worker Nodes: Repeat steps 1-8 and then run the following:

   1. Fetch the Join token from node-0001: `sudo cat /var/lib/rancher/k3s/server/node-token` and save it as NODE_TOKEN
   2. `curl -sfL https://get.k3s.io | INSTALL_K3S_CHANNEL=latest K3S_URL='https://192.168.178.73:6443' K3S_TOKEN=${NODE_TOKEN} sh -`

   3. Install Cilium: `cilium install --helm-set=kubeProxyReplacement=strict  --set ipv6.enabled=true --helm-set=k8sServiceHost=192.168.178.73 --helm-set=k8sServicePort=6443 --set encryption.enabled=true --set encryption.type=wireguard --set encryption.nodeEncryption=true`
   Note that the k8sServiceHost and Port params are needed because we don't have kube-proxy installed and hence the k8s service in the cluster is disfunctional until Cilium is up and running

## Extensions

### Install MetalLB

1. `helm repo add metallb https://metallb.github.io/metallb`
2. `k create ns metallb-system`
3. `helm install --wait -n metallb-system metallb metallb/metallb`
4. `k apply -f metallb/pool.yaml`

### Install Cert-Manager + DuckDNS

1. install cert-manager:

```bash
helm repo add jetstack https://charts.jetstack.io
helm repo update
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.2/cert-manager.crds.yaml
helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.14.2
```

2. Register at DuckDNS.org and fetch the Token shown after login
2. Install duckdns webhook wby using the DuckDNS Token

```shell
helm install cert-manager-webhook-duckdns --namespace cert-manager --set duckdns.token='TOKEN_DUCKDNS' --set clusterIssuer.production.create=true --set clusterIssuer.staging.create=true --set clusterIssuer.email='MYMAIL' --set logLevel=2 ./deploy/cert-manager-webhook-duckdns
```

Deploy an Ingress with an annotation of `cert-manager.io/cluster-issuer: cert-manager-webhook-duckdns-production`

### Install traefik

1. `helm install -f ./traefik/myvalues.yaml --create-namespace -n traefik traefik traefik/traefik`

### Install ArgoCD

```shell
helm repo add argo-cd https://argoproj.github.io/argo-helm
helm repo update
# install CRDs outside of chart
kubectl apply -k "https://github.com/argoproj/argo-cd/manifests/crds?ref=v2.10.8"
kubectl create ns argocd
helm upgrade --install --create-namespace -n argocd argo-cd argo-cd/argo-cd -f argocd/values.yaml
```

### Install linkerd with argocd

```shell
helm upgrade --install linkerd-buoyant \
  --create-namespace \
  --namespace linkerd-buoyant \
  --set buoyantCloudEnabled=false \
  --set license=$BUOYANT_LICENSE \
  linkerd-buoyant/linkerd-buoyant
```

## Clean Up

To uninstall K3s from a server node, run:

```shell
/usr/local/bin/k3s-uninstall.sh
```

To uninstall K3s from an agent node, run:

```shell
sudo ip link delete cilium_host
sudo ip link delete cilium_net
sudo ip link delete cilium_vxlan
sudo iptables-save | grep -iv cilium | iptables-restore
sudo ip6tables-save | grep -iv cilium | ip6tables-restore
/usr/local/bin/k3s-agent-uninstall.sh
```
