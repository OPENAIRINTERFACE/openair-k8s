# Deploy OAI CN with helm charts on Open Shift (Work In Progress)

## Prerequisites
- Assuming you are using Open Shift Server Version: 4.4.10, Kubernetes Version: v1.17.1+9d33dd3
- Assuming you have installed helm v3.1.0", GitCommit:"b29d20baf09943e134c2fa5e1e1cab3bf93315fa

### Use official cassandra image
Add cassandra helm chart to helm repo:
```bash
helm repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com
helm repo update
```

# Build Network functions images
For all network functions (HSS, MME, SPGW-C, SPGW-U) you have to build an image:
Please refer to:
1. MME: https://github.com/OPENAIRINTERFACE/openair-mme/blob/helm3.1-onap-sync-with-cn-split-repos/openshift
1. HSS: https://github.com/OPENAIRINTERFACE/openair-hss/blob/helm3.1-onap-sync-with-cn-split-repos/openshift
1. SPGW-C: https://github.com/OPENAIRINTERFACE/openair-spgwc/tree/helm3.1-onap-sync-with-cn-split-repos/openshift
1. SPGW-U: https://github.com/OPENAIRINTERFACE/openair-spgwu-tiny/tree/helm3.1-onap-sync-with-cn-split-repos/openshift

# Deploy Cassandra
## Storage class
The envisionned storage for cassandra is nfs (provisioner example.com/nfs), storage class name is "managed-nfs-storage".

## Security context permissions
To be able to deploy cassandra on oc (step not required on k8s), logged as kubeadmin on oc:
```bash
oc adm policy add-scc-to-user anyuid -z default
# THIS IS THE COMMAND OF THE MONTH!
```
## Deployment
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

# Deploy HSS
Since the deployment uses multus for creating networks, the cluster role 'cluster-admin' is required, so you have to log on oc with a user having this role.

```bash
helm install hss /path-to-your-openait-k8s-cloned-dir/charts/oai-hss
```

# Deploy SPGW-C
Idem: Since the deployment uses multus for creating networks, the cluster role 'cluster-admin' is required, so you have to log on oc with a user having this role.

```bash
helm install spgwc /path-to-your-openait-k8s-cloned-dir/charts/oai-spgwc
```
# Deploy SPGW-U
Idem: Since the deployment uses multus for creating networks, the cluster role 'cluster-admin' is required, so you have to log on oc with a user having this role.

```bash
helm install spgwu /path-to-your-openait-k8s-cloned-dir/charts/oai-spgwu-tiny
```

# Deploy MME
Idem: Since the deployment uses multus for creating networks, the cluster role 'cluster-admin' is required, so you have to log on oc with a user having this role.

```bash
helm install mme /path-to-your-openait-k8s-cloned-dir/charts/oai-mme



