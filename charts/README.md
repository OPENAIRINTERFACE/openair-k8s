# Deploy OAI CN with helm charts on Open Shift (Work In Progress)

## Prerequisites
- Assuming you are using Open Shift Server Version: 4.9.X, Kubernetes Version: v1.17.1+9d33dd3
- Assuming you have installed [helm v3.1.0](https://github.com/helm/helm/releases/tag/v3.1.0) on the cluster node from which you type helm commands.
- Assuming you have cloned the [openair-k8s](https://github.com/OPENAIRINTERFACE/openair-k8s) repo on the cluster node from which you type helm commands.
- Assuming SCTP protocol is [enabled on the cluster](https://docs.openshift.com/container-platform/4.4/networking/using-sctp.html#nw-sctp-enabling_using-sctp)
  
  You can check if SCTP is enabled by running a client/server [basic app](https://docs.openshift.com/container-platform/4.4/networking/using-sctp.html#nw-sctp-verifying_using-sctp)

## Build Network functions images
For all network functions (HSS, MME, SPGW-C, SPGW-U) you have to build an image:
Please refer to:
1. MME: https://github.com/magma/magma
1. HSS: https://github.com/OPENAIRINTERFACE/openair-hss/blob/helm3.1-onap-sync-with-cn-split-repos/openshift
1. SPGW-C: https://github.com/lionelgo/openair-spgwc/tree/multi-spgwu/openshift
1. SPGW-U: https://github.com/lionelgo/openair-spgwu-tiny/tree/multi-spgwu/openshift

On francelab cluster be aware that certificates (/etc/rhsm/ca/redhat-uep.pem) are renewed every month, so you may have to redo the "pki-entitlement" phase every month 
(only required if you want to install some packages inside the image)

## Deploy Cassandra
### Storage class
The envisionned storage for cassandra is nfs (provisioner example.com/nfs), storage class name is "nfs-client" (on our cluster).

### Deployment
Work is in progress, please follow the described deployment sequence (cassandra, HSS, SPGWC, SPGWU, MME).

``` bash
oc new-project oai4g
```

Logged as administrator of your namespace on oc (not kubeadmin):
```bash
helm install cassandra cassandra/
```

This will create 3 pods (namespace is 'oai4g' here)

```bash
oai4g          cassandra-0      1/1     Running     0          8m39s
oai4g          cassandra-1      1/1     Running     0          7m   
oai4g          cassandra-2      1/1     Running     0          5m13s
```

Cassandra service name is `cassandra` username is `cassandra` and password `cassandra`

## Deploy HSS
Since the deployment uses multus for creating network, your account should have enough permission to create multus objects

```bash
K8S_DIR="/path-to-your-openair-k8s-cloned-dir"
helm install oai-hss $K8S_DIR/charts/oai-hss
```

## Deploy SPGW-C
Since the deployment uses multus for creating network, your account should have enough permission to create multus objects

```bash
K8S_DIR="/path-to-your-openair-k8s-cloned-dir"
helm install oai-spgwc $K8S_DIR/charts/oai-spgwc
```

## Deploy MME
Since the deployment uses multus for creating network, your account should have enough permission to create multus objects

```bash
K8S_DIR="/path-to-your-openair-k8s-cloned-dir"
helm install magma-mme $K8S_DIR/charts/magma-oai-mme 
```

## Deploy SPGW-U
Since the deployment uses multus for creating network, your account should have enough permission to create multus objects

```bash
K8S_DIR="/path-to-your-openair-k8s-cloned-dir"
helm install oai-spgwu-tiny $K8S_DIR/charts/oai-spgwu-tiny --set serviceAccount.name="oai-spgwu1-tiny-sa" --set lte.instance="0" --set lte.fqdn="gwu1.spgw.node.epc.mnc099.mcc208.3gppnetwork.org" --set lte.spgwIpOneIf="192.168.18.151" --set lte.netUeIp="192.168.21.0/24"
```

## Un-deploy NFs
Upon your needs:

```
helm uninstall magma-mme oai-spgwc oai-spgwu-tiny
```

When un-deploy cassandra the helm charts don't really remove cassandra pvc so you need to manually remove it

oc delete pvc cassandra-0 cassandra-1 cassandra-2
