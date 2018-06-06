#!/bin/bash

echo Dockercon!!! | docker secret create mysql_root_password -

docker network create --driver=overlay front-tier
docker network create --driver=overlay back-tier
