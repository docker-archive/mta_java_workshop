#!/bin/bash

repo_path="$(dirname `pwd`)"

# build tutorial images
cd $repo_path/task_2/java_app 
docker image build -t $DTR_HOST/frontend/java_web:1 .

cd $repo_path/task_3/java_app 
docker image build -t $DTR_HOST/frontend/java_web:2 .

cd $repo_path/task_2/database
docker image build -t $DTR_HOST/backend/database .

cd $repo_path/task_3/messageservice
docker image build -t $DTR_HOST/backend/messageservice .


cd $repo_path/task_3/worker
docker image build -t $DTR_HOST/backend/worker:1 .

cd $repo_path/task_5/worker
docker image build -t $DTR_HOST/backend/worker:2 .

# push images to Docker Trusted Registry
docker login -u frontend_user -p user1234 $DTR_HOST
docker image push $DTR_HOST/frontend/java_web:1
docker image push $DTR_HOST/frontend/java_web:2

docker login -u backend_user -p user1234 $DTR_HOST
docker image push $DTR_HOST/backend/database
docker image push $DTR_HOST/backend/messageservice
docker image push $DTR_HOST/backend/worker:1
docker image push $DTR_HOST/backend/worker:2
