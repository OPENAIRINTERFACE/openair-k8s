# OpenAirInterface on Kubernetes

openair-k8s allows building high-quality [OCI-compliant](https://www.opencontainers.org/) container images for the [OpenAirInterface](https://www.openairinterface.org) 4G/5G radio access (eNB/gNB) and core networks (EPC) and deploying these components on OpenShift or other enterprise-grade Kubernetes distributions.

Note: This is both experimental and work in progress.

## Building OAI Container Images
### Build Strategy
OpenAirInterface (OAI) components have many build-time dependencies, some of which need to be built from source. To ensure fast yet reproducible image builds, we create a common `oai-build-base` image that contains the build-time dependencies for all OAI components. Each component image is then built using the multistage build pattern: First build the OAI component using the `oai-build-base` image, then copy the component and its run-time dependencies into a fresh deployment image.

Images are built based on RHEL8 [Universal Base Images (UBI)](https://www.redhat.com/en/blog/introducing-red-hat-universal-base-image) to yield small images with curated, high-quality content.

### Prerequisites
As some of the required rpm packages for building OAI are not yet available via the UBI repos, images currently need to be built on a subscribed RHEL8 host, e.g. using the [free RHEL8 developer subscriptions](https://developers.redhat.com/articles/getting-red-hat-developer-subscription-what-rhel-users-need-know/). On the RHEL8 build host:
```sh
sudo subscription-manager register
sudo subscription-manager attach
sudo yum install -y git podman nmap-ncat
git clone http://github.com/OPENAIRINTERFACE/openair-k8s
cd openair-k8s
```

### Building
To build all OAI component images:
```sh
hack/build_images
```
To build selected OAI component images, e.g.:
```sh
hack/build_images oai-enb oai-ue
```
By default, OAI components are built using the stable git tag defined in the component's Dockerfile. To override this, specify an alternative git ref to build from, e.g.:
```sh
hack/build_images oai-enb:v1.0.0 oai-ue:master
```

### Pushing to a Registry
To push the OAI images to an external registry, e.g. oai-hss to quay.io:
```sh
podman login quay.io
podman push oai-hss:1.0.1 quay.io/my_organisation/oai-hss:1.0.1
```

### Cleaning
To delete all local OAI component images:
```sh
hack/clean_images
```
Add `--help` to these commands to see more options.

### Checking Dockerfiles
To run a linter on all Dockerfiles:
```sh
hack/check_dockerfiles
```

## Running OAI on Podman
### Prerequisites
OAI containers will run with host networking (```--net=host```) and communicate via the loopback ```127.0.1.1```. To ensure the services' names can be properly resolved, add the following to ```/etc/hosts```:
```
127.0.1.1	hss hss.openair4G.eur
127.0.1.1	mme mme.openair4G.eur
127.0.1.1	sgw sgw.openair4G.eur
```

### Running
To test the OAI container images on your local machine, you can run them in podman like this:
```sh
hack/run_oai_on_podman
```

### Cleaning
To delete the container instances created with above command, use:
```sh
hack/clean_oai_on_podman
```

## Running OAI on Kubernetes
### Prerequisites
Obviously, a running k8s cluster with `kubectl` set up correctly. This work is being developed and tested on OpenShift 4.2 ([try it here](https://try.openshift.com)). You also need `kustomize` installed:
```sh
curl -L https://github.com/kubernetes-sigs/kustomize/releases/download/v3.1.0/kustomize_3.1.0_linux_amd64 -o ~/bin/kustomize && chmod a+x ~/bin/kustomize
```

If necessary, generate new TLS certificates for the oai-hss and oai-mme services to match the namespace and cluster name you're deploying to, e.g.:
```sh
hack/generate_certs -p hss -d manifests/oai-hss/certs oai-hss.oai.svc.cluster.local
hack/generate_certs -p mme -d manifests/oai-mme/certs oai-mme.oai.svc.cluster.local
```

### Running
If your user has permissions to create namespaces on the k8s cluster, you can simply run:
```sh
hack/run_oai_on_k8s
```
... which internally calls:
```sh
kustomize build manifests | kubectl apply -f -
```
If you need to use a namespace assigned to you, e.g. `oai`, modify `manifests/kustomization.yaml` to delete the `00_namespace.yaml` resource and change the `namespace` field to your needs.

In order to run a single component, you have to point to the specific path where the manifests are located. For instnace, to run the MME on Kubernetes/OpenShift, please run:

```
kustomize build manifests/oai-mme | kubectl apply -f -
```

and to delete that component from running on the cluster, execute:

```
kustomize build manifests/oai-mme | kubectl delete -f -
```

### Cleaning
To remove all resources from the 'oai' namespace plus delete the namespace itself, run:
```sh
hack/clean_oai_on_k8s
```
