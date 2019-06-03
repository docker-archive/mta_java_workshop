#!/usr/bin/env bash
# set log-driver in daemon.json on remote hosts using PDSH utility

set -e

# output colors
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
NORMAL=$(tput sgr0)

# hostlist must be a comma separated list of hosts or IP addresses
HOSTLIST=${HOSTLIST:-$1}
LINUX_USER=${2:-'ubuntu'}
SSH_KEY=${3:-"$HOME/.ssh/id_rsa"}
DEBUG=${4:-false}

# set SSH settings for PDSH
export PDSH_SSH_ARGS_APPEND="-i ${SSH_KEY} -l ${LINUX_USER}"

echo $GREEN "set 'log-driver' on hosts '${HOSTLIST}'..." $NORMAL
# CONFIG='{\"storage-driver\": \"overlay2\", \"log-driver\": \"journald\", \"log-opts\": {\"tag\": \"{{.ImageName}}|{{.Name}}|{{.ID}}\"}}'
CONFIG='{\"storage-driver\": \"overlay2\", \"log-driver\": \"journald\", \"log-opts\": {\"tag\": \"{{.ImageName}}\"}}'
pdsh -w $HOSTLIST "echo $CONFIG | sudo tee /etc/docker/daemon.json"

if [[ "$DEBUG" == "true" ]]||[[ $DEBUG == 1 ]]; then
  pdsh -w $HOSTLIST "sudo cat /etc/docker/daemon.json"
fi
