# Deploy OAI CN with helm charts on Open Shift (Work In Progress)

## Prerequisites
- Assuming you are using Open Shift Server Version: 4.4.10, Kubernetes Version: v1.17.1+9d33dd3
- Assuming you have installed [helm v3.1.0](https://github.com/helm/helm/releases/tag/v3.1.0) on the cluster node from which you type helm commands.
- Assuming you have cloned the [openair-k8s](https://github.com/OPENAIRINTERFACE/openair-k8s) repo on the cluster node from which you type helm commands.
- Assuming SCTP protocol is [enabled on the cluster](https://docs.openshift.com/container-platform/4.4/networking/using-sctp.html#nw-sctp-enabling_using-sctp)
  
  You can check if SCTP is enabled by running a client/server [basic app](https://docs.openshift.com/container-platform/4.4/networking/using-sctp.html#nw-sctp-verifying_using-sctp)

### Use official cassandra image
Add cassandra helm chart to helm repo:
```bash
helm repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com
helm repo update
```

## Build Network functions images
For all network functions (HSS, MME, SPGW-C, SPGW-U) you have to build an image:
Please refer to:
1. MME: https://github.com/magma/magma
1. HSS: https://github.com/OPENAIRINTERFACE/openair-hss/blob/helm3.1-onap-sync-with-cn-split-repos/openshift
1. SPGW-C: https://github.com/lionelgo/openair-spgwc/tree/sanitize-leak/openshift
1. SPGW-U: https://github.com/lionelgo/openair-spgwu-tiny/tree/multi-spgwu/openshift

On francelab cluster be aware that certificates (/etc/rhsm/ca/redhat-uep.pem) are renewed every month, so you may have to redo the "pki-entitlement" phase every month.

## Deploy Cassandra
### Storage class
The envisionned storage for cassandra is nfs (provisioner example.com/nfs), storage class name is "managed-nfs-storage".

### Security context permissions
To be able to deploy cassandra on oc (step not required on k8s), logged as kubeadmin on oc:
```bash
oc adm policy add-scc-to-user anyuid -z default
# THIS IS THE COMMAND OF THE MONTH!
```
### Deployment
Work is in progress, please follow the described deployment sequence (cassandra, HSS, SPGWC, SPGWU, MME).

Logged as administrator of your namespace on oc (not kubeadmin):
```bash
helm install --set config.endpoint_snitch=GossipingPropertyFileSnitch,persistence.storageClass=managed-nfs-storage  cassandra incubator/cassandra
```
This will create 3 pods (namespace is 'oai-cn' here)

```bash
oai-cn          cassandra-0      1/1     Running     0          8m39s
oai-cn          cassandra-1      1/1     Running     0          7m   
oai-cn          cassandra-2      1/1     Running     0          5m13s
```

## Deploy HSS
Since the deployment uses multus for creating networks, the cluster role 'cluster-admin' is required, so you have to log on oc with a user having this role.

```bash
K8S_DIR="/path-to-your-openair-k8s-cloned-dir"
helm install hss $K8S_DIR/charts/oai-hss
```

## Deploy SPGW-C
Idem: Since the deployment uses multus for creating networks, the cluster role 'cluster-admin' is required, so you have to log on oc with a user having this role.

```bash
K8S_DIR="/path-to-your-openair-k8s-cloned-dir"
helm install spgwc $K8S_DIR/charts/oai-spgwc --set start.tcpdump="true"
```
## Deploy MME
Idem: Since the deployment uses multus for creating networks, the cluster role 'cluster-admin' is required, so you have to log on oc with a user having this role.

```bash
K8S_DIR="/path-to-your-openair-k8s-cloned-dir"
helm install mme $K8S_DIR/charts/magma-oai-mme  --set start.tcpdump="true"
```

## Deploy SPGW-U at EURECOM (eNB located at EURECOM should be in TAC = 1, 2, 3, 4)
Idem: Since the deployment uses multus for creating networks, the cluster role 'cluster-admin' is required, so you have to log on oc with a user having this role.

UE traffic from 209.99 TAC 1, 2 will be forwarded to gwu1.spgw.node.epc.mnc099.mcc208.3gppnetwork.org

UE traffic from 209.99 TAC 3, 4 will be forwarded to gwu2.spgw.node.epc.mnc099.mcc208.3gppnetwork.org

```bash
K8S_DIR="/path-to-your-openair-k8s-cloned-dir"
helm install spgwu1 $K8S_DIR/charts/oai-spgwu-tiny --set serviceAccount.name="oai-spgwu1-tiny-sa" --set lte.instance="0" --set lte.fqdn="gwu1.spgw.node.epc.mnc099.mcc208.3gppnetwork.org" --set lte.spgwIpOneIf="192.168.18.151" --set lte.netUeIp="192.168.21.0/24" --set start.tcpdump="false"
helm install spgwu2 $K8S_DIR/charts/oai-spgwu-tiny --set serviceAccount.name="oai-spgwu2-tiny-sa" --set lte.instance="1" --set lte.fqdn="gwu2.spgw.node.epc.mnc099.mcc208.3gppnetwork.org" --set lte.spgwIpOneIf="192.168.18.165" --set lte.netUeIp="192.168.21.0/24" --set start.tcpdump="false"
```

## Deploy a SPGW-U not at EURECOM (eNB should be in TAC = 5, 6, 7, 8, can be extended)
Idem: Since the deployment uses multus for creating networks, the cluster role 'cluster-admin' is required, so you have to log on oc with a user having this role.

UE traffic from 209.99 TAC 5, 6 will be forwarded to gwu3.spgw.node.epc.mnc099.mcc208.3gppnetwork.org

UE traffic from 209.99 TAC 7, 8 will be forwarded to gwu4.spgw.node.epc.mnc099.mcc208.3gppnetwork.org

```bash
helm install spgwu3 $K8S_DIR/charts/oai-spgwu-tiny --set serviceAccount.name="oai-spgwu3-tiny-sa" --set lte.instance="2" --set lte.fqdn="gwu3.spgw.node.epc.mnc099.mcc208.3gppnetwork.org" --set lte.spgwIpOneIf="192.168.18.168" --set lte.netUeIp="192.168.21.0/24" --set start.tcpdump="false"

helm install spgwu4 $K8S_DIR/charts/oai-spgwu-tiny --set serviceAccount.name="oai-spgwu4-tiny-sa" --set lte.instance="3" --set lte.fqdn="gwu4.spgw.node.epc.mnc099.mcc208.3gppnetwork.org" --set lte.spgwIpOneIf="192.168.18.170" --set lte.netUeIp="192.168.21.0/24" --set start.tcpdump="false"

```

## Un-deploy NFs at EURECOM
Upon your needs:

```
helm uninstall mme spgwc spgwu1 spgwu2
```

## Un-deploy NFs not at EURECOM
Upon your needs:

```
helm uninstall spgwu3 spgwu4
```


