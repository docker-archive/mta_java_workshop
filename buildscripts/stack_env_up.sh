#!/bin/bash

set -e

echo "notice: this will fail if run on anything other than a master node"

echo Dockercon!!! | docker secret create mysql_root_password -

docker network create --driver=overlay front-tier
docker network create --driver=overlay back-tier
