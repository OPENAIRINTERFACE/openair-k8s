# We're using the RHEL8 UBI base image from the Red Hat private registry, thus
# the build host must be registered and have a valid subscription.
ARG REGISTRY=registry.redhat.io
FROM $REGISTRY/ubi8/ubi

ARG GIT_TAG=latest
LABEL name="oai-build-base" \
      version="${GIT_TAG}.el8" \
      io.k8s.description="Image containing all build dependencies for openairinterface5g and openair-cn."

WORKDIR /root
RUN yum -y install --enablerepo="codeready-builder-for-rhel-8-x86_64-rpms" \
        git make cmake gcc gcc-c++ autoconf automake bc bison flex libtool patch \
        atlas-devel \
        blas \
        blas-devel \
        boost \
        boost-devel \
        bzip2-devel \
        check \
        check-devel \
        elfutils-libelf-devel \
        gflags-devel \
        glog-devel \
        gmp-devel \
        gnutls-devel \
        guile-devel \
        kernel-devel \
        kernel-headers \
        lapack \
        lapack-devel \
        libasan \
        libconfig-devel \
        libevent-devel \
        libffi-devel \
        libgcrypt-devel \
        libidn-devel \
        libidn2-devel  \
        libtool \
        libusb-devel \
        libusbx-devel \
        libxml2-devel \
        libXpm-devel \
        libxslt-devel \
        libyaml-devel \
        lksctp-tools \
        lksctp-tools-devel \
        lz4-devel \
        mariadb-devel \
        nettle-devel \
        openssh-clients \
        openssh-server \
        openssl \
        openssl-devel \
        pkgconfig \
        protobuf \
        protobuf-c \
        protobuf-c-compiler \
        protobuf-c-devel \
        psmisc \
        python2 \
        python2-docutils \
        python2-requests \
        vim-common \
        xz-devel \
        zlib-devel \
    && yum install -y http://download-ib01.fedoraproject.org/pub/epel/7/x86_64/Packages/x/xforms-1.2.4-5.el7.x86_64.rpm \
    && yum install -y http://download-ib01.fedoraproject.org/pub/epel/7/x86_64/Packages/x/xforms-devel-1.2.4-5.el7.x86_64.rpm \
    && yum clean all -y \
    && rm -rf /var/cache/yum \
    && pip2 install --user mako pexpect

# RUN git clone https://gist.github.com/2190472.git /opt/ssh

RUN if [ "$EURECOM_PROXY" == true ]; then git config --global http.proxy http://:@proxy.eurecom.fr:8080; fi

# build packages not present in RHEL/EPEL repos
COPY patches patches/
COPY scripts scripts/
RUN scripts/build_missing_packages
