#!/bin/bash

while read -r DOCKER_NODE_DATA;
do
    DOCKER_NODE=$(echo "$DOCKER_NODE_DATA" | awk -F'|' '{print $1}')

    echo $DOCKER_NODE
    docker container run \
    --detach \
    --rm \
    --name sysctl-mod-"${DOCKER_NODE}" \
    --privileged \
    --env=constraint:node=="${DOCKER_NODE}" \
    --volume /etc:/etc:rw \
    --volume /dev:/dev:rw \
    --volume /sys:/sys:rw \
    --volume /var/log:/var/log:rw \
    ubuntu sysctl -w vm.max_map_count=262144

done < <(for eachNode in $(docker node ls --format '{{.ID}}'); 
         do 
            docker node inspect "${eachNode}" --format '{{.Description.Hostname}}|{{index .Spec.Labels "com.docker.ucp.orchestrator.kubernetes"}}|{{index .Spec.Labels "com.docker.ucp.orchestrator.swarm"}}';
         done
        )