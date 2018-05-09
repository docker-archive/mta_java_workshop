#!/bin/bash

repo_path="$(dirname `pwd`)"

cd $repo_path/task_2/database
docker image build -t $DTR_HOST/backend/database .
docker image push $DTR_HOST/backend/database

cd $repo_path/task_2/java_app 
docker image build -t $DTR_HOST/frontend/java_web:1 .
docker image push $DTR_HOST/frontend/java_web:1

cd $repo_path/task_3/java_app 
docker image build -t $DTR_HOST/frontend/java_web:2 .
docker image push $DTR_HOST/frontend/java_web:2

cd $repo_path/task_3/messageservice
docker image build -t $DTR_HOST/backend/messageservice .
docker image push $DTR_HOST/backend/messageservice

cd $repo_path/task_3/worker
docker image build -t $DTR_HOST/backend/worker:1 .
docker image push $DTR_HOST/backend/worker

cd $repo_path/task_4/signup_client
docker image build -t $DTR_HOST/frontend/signup_client .
docker image push $DTR_HOST/frontend/signup_client

cd $repo_path/task_5/worker
docker image build -t $DTR_HOST/backend/worker:2 .
docker image push $DTR_HOST/backend/worker:2