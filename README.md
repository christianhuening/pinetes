# pinetes

This is about installing a k8s cluster on a set of raspberry pies with k3s and cilium

## steps

1. get pis (v4 8GB)
2. install them with Ubuntu Server 64bit
3. install docker
4. update packages and everything
5. `sudo apt install -y docker.io`
6. `sudo sed -i '$ s/$/ cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1 swapaccount=1/' /boot/firmware/cmdline.txt` 
7. activate vxlan (only on newer ubuntus): `sudo apt install linux-modules-extra-raspi`
8. reboot machine for good measure: `sudo reboot`  
9. (from: https://docs.cilium.io/en/v1.11/gettingstarted/k3s/): install k3s without flannel: `curl -sfL https://get.k3s.io | INSTALL_K3S_CHANNEL=latest INSTALL_K3S_EXEC='--flannel-backend=none --disable-network-policy --write-kubeconfig-mode "0644" --resolv-conf /run/systemd/resolve/resolv.conf' sh -` 
(resolv.conf bit was from [here](https://github.com/k3s-io/k3s/issues/4087#issuecomment-929374460), since coredns wouldn't get ready. More also [here](https://github.com/coredns/coredns/blob/master/plugin/loop/README.md#troubleshooting-loops-in-kubernetes-clusters))
7. install cilium:
   ```bash
   curl -L --remote-name-all https://github.com/cilium/cilium-cli/releases/latest/download/cilium-linux-arm64.tar.gz{,.sha256sum}
   sha256sum --check cilium-linux-arm64.tar.gz.sha256sum
   sudo tar xzvfC cilium-linux-arm64.tar.gz /usr/local/bin
   rm cilium-linux-arm64.tar.gz{,.sha256sum}
   ln -s /etc/rancher/k3s/k3s.yaml .kube/config
   cilium install
   ```
 8. fetch Kubeconfig: 
    ```shell
    scp ubuntu@node-0001.pinetes:/etc/rancher/k3s/k3s.yaml ./pinetes-kubeconfig
    gsed -i 's/127.0.0.1/node-0001.pinetes/g' pinetes-kubeconfig
    
   
   
 ## cleanup
 
 1. /usr/local/bin/k3s-uninstall.sh
