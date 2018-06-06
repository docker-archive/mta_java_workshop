#!/usr/bin/env bash
DTR_HOST="${DTR_HOST?"DTR_HOST must be set"}"
USERNAME=${FE_USERNAME:-"frontend_user"}
PASSWORD=${FE_PASSWORD:-"user1234"}

#git clone https://github.com/dockersamples/mta_java_workshop.git
#cd mta_java_workshop/task_2

docker build -t ${DTR_HOST}/frontend/java_web $(pwd)/../task_2/java_app
docker login ${DTR_HOST} -u ${USERNAME} -p ${PASSWORD}
docker push ${DTR_HOST}/frontend/java_web

USERNAME=${BE_USERNAME:-"backend_user"}
PASSWORD=${BE_PASSWORD:-"user1234"}

docker build -t ${DTR_HOST}/backend/database $(pwd)/../task_2/database
docker login ${DTR_HOST} -u ${USERNAME} -p ${PASSWORD}
docker push ${DTR_HOST}/backend/database
