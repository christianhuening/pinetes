
To run the sidero metal control plane on rPI4 use this tutorial: https://www.sidero.dev/v0.6/guides/sidero-on-rpi4/


Then for server nodes use this tutorial for rPI4s:
https://www.sidero.dev/v0.6/guides/rpi4-as-servers/ 
Note: This is rather intricate to install and has to be done for every single rPI4 sadly. Not really the best solution




Initialize the sidero cluster

```bash
export SIDERO_CONTROLLER_MANAGER_HOST_NETWORK=true
export SIDERO_CONTROLLER_MANAGER_DEPLOYMENT_STRATEGY=Recreate
export SIDERO_CONTROLLER_MANAGER_API_ENDPOINT=192.168.178.73
export SIDERO_CONTROLLER_MANAGER_SIDEROLINK_ENDPOINT=192.168.178.73
clusterctl init -b talos -c talos -i sidero
```