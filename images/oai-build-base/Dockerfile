# We're using the RHEL8 UBI base image from the Red Hat private registry, thus
# the build host must be registered and have a valid subscription.
FROM registry.redhat.io/ubi8/ubi
LABEL name="oai-build-base" \
      version="v1.0.3" \
      io.k8s.description="Image containing all build dependencies for openairinterface5g and openair-cn."

ARG GIT_TAG=latest

WORKDIR /root

RUN yum install --enablerepo=codeready-builder-for-rhel-8-x86_64-rpms -y \
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
    && pip2 install --user mako pexpect

# RUN git clone https://gist.github.com/2190472.git /opt/ssh

# build packages not present in RHEL/EPEL repos
COPY patches patches/
COPY ./build_missing_packages .
RUN chmod +x build_missing_packages && ./build_missing_packages