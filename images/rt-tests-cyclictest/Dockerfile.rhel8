ARG REGISTRY=registry.redhat.io
FROM $REGISTRY/ubi8/ubi

RUN REPOLIST=rhel-8-for-x86_64-rt-rpms \
    PKGLIST="rt-tests" \
    && yum -y install --enablerepo ${REPOLIST} ${PKGLIST} \
    && yum -y clean all \
    && rm -rf /var/cache/yum

ARG CORES=1
ARG CORE_LIST=2
ARG DURATION=1m

ENV CORES="${CORES}"
ENV CORE_LIST="${CORE_LIST}"
ENV DURATION="${DURATION}"
USER root

ENTRYPOINT ["/bin/bash"]
CMD ["-c", "taskset -c ${CORE_LIST} cyclictest -q -D ${DURATION} -p 99 -t ${CORES} -h 30 -m -a ${CORE_LIST}"]

