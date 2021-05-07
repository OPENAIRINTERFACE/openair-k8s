# Deploy OAI CN with helm charts on Open Shift in the scope of 5geve project

## Prerequisites
- Assuming you are using Open Shift Server Version: 4.4.10, Kubernetes Version: v1.17.1+9d33dd3
- Assuming you have installed [helm v3.1.0](https://github.com/helm/helm/releases/tag/v3.1.0) on the cluster node from which you type helm commands.
- Assuming you have cloned the [openair-k8s](https://github.com/OPENAIRINTERFACE/openair-k8s) repo on the cluster node from which you type helm commands.
- Assuming SCTP protocol is [enabled on the cluster](https://docs.openshift.com/container-platform/4.4/networking/using-sctp.html#nw-sctp-enabling_using-sctp)
  
  You can check if SCTP is enabled by running a client/server [basic app](https://docs.openshift.com/container-platform/4.4/networking/using-sctp.html#nw-sctp-verifying_using-sctp)


## Build Network functions images

In the context of 5geve project the network function HSS is common for all 4G CN deployments, it is already setup and should not be deployed or re-deployed.

For all network functions (MME, SPGW-C, SPGW-U) you have to build an image:
Please refer to:
1. MME: https://github.com/magma/magma
2. SPGW-C: https://github.com/lionelgo/openair-spgwc/tree/sanitize-leak/openshift
3. SPGW-U: https://github.com/lionelgo/openair-spgwu-tiny/tree/multi-spgwu/openshift

On francelab cluster be aware that certificates (/etc/rhsm/ca/redhat-uep.pem) are renewed every month, so you may have to redo the "pki-entitlement" phase every month.


## Deploy SPGW-C
Idem: Since the deployment uses multus for creating networks, the cluster role 'cluster-admin' is required, so you have to log on oc with a user having this role.

```bash
K8S_DIR="/path-to-your-openair-k8s-cloned-dir"
helm install spgwc $K8S_DIR/charts/oai-spgwc --set start.tcpdump="true"
```

## Deploy SPGW-U at EURECOM (eNB located in 192.168.18.0 network at EURECOM should be in TAC = 1, 2, 3, 4)
Idem: Since the deployment uses multus for creating networks, the cluster role 'cluster-admin' is required, so you have to log on oc with a user having this role.

UE traffic from 209.99 TAC 1, 2, 3, 4 will be forwarded to gwu1.spgw.node.epc.mnc099.mcc208.3gppnetwork.org


```bash
K8S_DIR="/path-to-your-openair-k8s-cloned-dir"
helm install spgwu1 $K8S_DIR/charts/oai-spgwu-tiny --set lte.instance="0" --set lte.fqdn="gwu1.spgw.node.epc.mnc099.mcc208.3gppnetwork.org" --set lte.spgwIpOneIf="192.168.18.170" --set lte.netUeIp="192.168.21.0/24" --set start.tcpdump="false"
```

## Optional: Deploy a SPGW-U not at EURECOM (eNB should be in TAC = 5, 6, 7, 8, can be extended)
Idem: Since the deployment uses multus for creating networks, the cluster role 'cluster-admin' is required, so you have to log on oc with a user having this role.

UE traffic from 209.99 TAC 5, 6, 7, 8 will be forwarded to gwu2.spgw.node.epc.mnc099.mcc208.3gppnetwork.org


```bash
helm install spgwu2 $K8S_DIR/charts/oai-spgwu-tiny  --set lte.instance="1" --set lte.fqdn="gwu2.spgw.node.epc.mnc099.mcc208.3gppnetwork.org" --set lte.spgwIpOneIf="192.168.18.161" --set lte.netUeIp="192.168.21.0/24" --set start.tcpdump="false"

```

## Deploy MME
Idem: Since the deployment uses multus for creating networks, the cluster role 'cluster-admin' is required, so you have to log on oc with a user having this role.

```bash
K8S_DIR="/path-to-your-openair-k8s-cloned-dir"
helm install mme $K8S_DIR/charts/magma-oai-mme  --set start.tcpdump="true"
```


## Un-deploy NFs at EURECOM
Upon your needs:

```
helm uninstall mme spgwc spgwu1 
```

## Un-deploy NFs not at EURECOM
Upon your needs:

```
helm uninstall spgwu2
```


