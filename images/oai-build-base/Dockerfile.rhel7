# We're using the RHEL7 UBI base image from the Red Hat private registry, thus
# the build host must be registered and have a valid subscription.
ARG REGISTRY=registry.redhat.io
FROM $REGISTRY/ubi7/ubi

ARG GIT_TAG=latest
LABEL name="oai-build-base" \
      version="${GIT_TAG}.el7" \
      io.k8s.description="Image containing all build dependencies for openairinterface5g and openair-cn."

WORKDIR /root
RUN yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
    && yum install -y --enablerepo="rhel-7-server-optional-rpms" --enablerepo="rhel-server-rhscl-7-rpms" \
        git make cmake3 gcc gcc-c++ autoconf automake bc bison flex libtool patch devtoolset-7 \
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
        psmisc \
        python-pip \
        python2 \
        python2-docutils \
        python2-requests \
        unzip \
        vim-common \
        xforms-devel \
        xz-devel \
        zlib-devel \
    && yum clean all -y \
    && rm -rf /var/cache/yum \
    && pip install --user mako pexpect

# RUN git clone https://gist.github.com/2190472.git /opt/ssh

RUN if [ "$EURECOM_PROXY" == true ]; then git config --global http.proxy http://:@proxy.eurecom.fr:8080; fi

# build packages not present in RHEL/EPEL repos
# using gcc 7.3.1, because libfolly doesn't build with RHEL7's gcc 4.8.5
COPY patches patches/
COPY scripts scripts/
RUN scl enable devtoolset-7 scripts/build_missing_packages
