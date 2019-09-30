#!/bin/bash

set -euo pipefail

TURBOSTAT_DURATION=${TURBOSTAT_DURATION:-30}
HWLAT_DURATION=${HWLAT_DURATION:-120}
RTEVAL_DURATION=${RTEVAL_DURATION:-120}

info() { echo -e "\E[34m\n== $@ ==\E[00m"; }

info "CPU info"
lscpu

info "Checking CPU C-states (${TURBOSTAT_DURATION}s)"
if [ -c /dev/cpu/0/msr ]; then
    turbostat -n 1 -i "${TURBOSTAT_DURATION}"
else
    echo "No /dev/cpu/0/msr, did you forget to run container as '--privileged'?"
fi

info "Checking CPU frequencies"
cat /proc/cpuinfo | grep MHz

info "Checking hardware/firmware-induced latency (${HWLAT_DURATION}s)"
hwlatdetect --duration="${HWLAT_DURATION}"

info "Kernel info"
if [ -f /boot/grub2/grubenv ]; then
  echo "default kernel:      $(grubby --default-kernel | sed 's|/boot/vmlinuz-||')"
else
  echo "default kernel:      (inaccessible)"
fi
echo "current kernel:      $(uname -r)"
if uname -v | grep -q PREEMPT; then
  echo "has PREEMPT patch:   true"
else
  echo "has PREEMPT patch:   false"
fi
echo "kernel params:       $(cat /proc/cmdline)"
echo "tuned version:       $(tuned -v)"
if [ -s /etc/tuned/active_profile ]; then
  echo "tuned act. profile:  $(cat /etc/tuned/active_profile)"
else
  echo "tuned act. profile:  (inaccessible)"
fi

info "Testing the system's rt-capability under load (setup time + ${RTEVAL_DURATION}s)"
rteval -V
rteval -v -d "${RTEVAL_DURATION}"
