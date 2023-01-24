# Pinetes

This is about installing a k8s cluster on a set of raspberry pies with k3s and cilium

## steps

1. get Pi's (v4 8GB)
2. install them with Ubuntu Server 64bit
3. set new hostname: `hostnamectl set-hostname node-000X.pinetes`
3. install docker: `sudo apt install -y docker.io`
4. update packages and everything: `sudo apt update & sudo apt upgrade -y`
6. `sudo sed -i '$ s/$/ cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1 swapaccount=1/' /boot/firmware/cmdline.txt`
7. activate vxlan (only on newer ubuntus, if `modprobe vxlan` returns error): `sudo apt install linux-modules-extra-raspi`
8. reboot machine for good measure: `sudo reboot`

for an initial install, proceed here:
1. (from: https://docs.cilium.io/en/v1.11/gettingstarted/k3s/): install k3s without flannel: `curl -sfL https://get.k3s.io | INSTALL_K3S_CHANNEL=latest K3S_NODE_NAME=master-0001.pinetes INSTALL_K3S_EXEC='--disable servicelb --flannel-backend=vxlan --disable-network-policy --write-kubeconfig-mode "0644" --resolv-conf /run/systemd/resolve/resolv.conf' sh -`
(resolv.conf bit was from [here](https://github.com/k3s-io/k3s/issues/4087#issuecomment-929374460), since coredns wouldn't get ready. More also [here](https://github.com/coredns/coredns/blob/master/plugin/loop/README.md#troubleshooting-loops-in-kubernetes-clusters))
(note that we disable the k3s klipper LB in favour of later installing metalLB)
2. fetch Kubeconfig:
    ```shell
    scp ubuntu@master-0001.pinetes:/etc/rancher/k3s/k3s.yaml ./pinetes-kubeconfig
    gsed -i 's/127.0.0.1/master-0001.pinetes/g' pinetes-kubeconfig
    ```

for worker nodes here:
1. Add Worker Nodes: Repeat steps 1-8 and then run the following:
   1. Fetch the Join token from node-0001: `cat /var/lib/rancher/k3s/server/node-token` and save it as NODE_TOKEN
   2. `curl -sfL https://get.k3s.io | INSTALL_K3S_CHANNEL=latest K3S_URL='https://master-0001.pinetes:6443' K3S_TOKEN=${NODE_TOKEN} sh -`


## Install MetalLB

1. `helm repo add metallb https://metallb.github.io/metallb`
2. `k create ns metallb-system`
3. `helm install --wait -n metallb-system metallb metallb/metallb`
4. `k apply -f metallb/pool.yaml`



## Install linkerd with argocd

Guide: <https://linkerd.io/2.12/tasks/gitops/>

## Clean Up

To uninstall K3s from a server node, run:

`/usr/local/bin/k3s-uninstall.sh`

To uninstall K3s from an agent node, run:

`/usr/local/bin/k3s-agent-uninstall.sh`