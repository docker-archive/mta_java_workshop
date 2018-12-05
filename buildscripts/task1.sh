#!/usr/bin/env bash

set -e

if [ -z "$DTR_HOST" ]; then
  echo "ERROR - DTR_HOST ENV param is empty or unset"
  exit 1
fi

DTR_HOST=${DTR_HOST:-$1}
ADMIN_USER=${ADMIN_USER:-"admin"}
ADMIN_PASSWORD=${ADMIN_PASSWORD:-"admin1234"}

CURL_CMD="curl -k -s -u ${ADMIN_USER}:${ADMIN_PASSWORD} https://${DTR_HOST}"
CURL_HEADER="Content-Type: application/json;charset=UTF-8"

post(){
  URI=$1
  if [ "$2" != "" ]; then
    DATA="-d ${2}"
  fi

  RESPONSE=$(${CURL_CMD}${URI} -X POST ${DATA} -H "${CURL_HEADER}")
}

put(){
  URI=$1
  if [ "$2" != "" ]; then
    DATA="-d ${2}"
  fi

  RESPONSE=$(${CURL_CMD}${URI} -X PUT "${DATA}" -H "${CURL_HEADER}")
}

create_user(){
  USERNAME=$1
  PASSWORD=${2:-"user1234"}
  echo Creating user $USERNAME
  post /enzi/v0/accounts '{"isAdmin":false,"isActive":true,"username":"'${USERNAME}'","password":"'${PASSWORD}'","fullName":"'${USERNAME}'","name":"'${USERNAME}'","type":"user"}'
}

create_org(){
  ORG=$1
  USER=$2
  TEAM=$3
  echo Creating org $ORG and $TEAM with user $USER
  post /enzi/v0/accounts '{"name":"'${ORG}'","isOrg":true}'
  put /enzi/v0/accounts/${ORG}/members/admin '{"isAdmin":true,"isPublic":true}'
  put /enzi/v0/accounts/${ORG}/members/${USER} '{"isAdmin":false,"isPublic":true}'
  post /enzi/v0/accounts/${ORG}/teams '{"type":"managed","name":"'${TEAM}'"}'
  put /enzi/v0/accounts/${ORG}/teams/${TEAM}/members/${USER}
}

create_repo(){
  REPO=$1
  ORG=$2
  TEAM=$3
  echo Creating repo ${ORG}/${REPO} for team ${TEAM}
  post /api/v0/repositories/${ORG} "{\"name\":\"${REPO}\",\"visibility\":\"public\",\"shortDescription\":\"${REPO}\",\"scanOnPush\":false}"
  put /api/v0/repositories/${ORG}/${REPO}/teamAccess/${TEAM} '{"accessLevel":"read-write"}'
}

create_user frontend_user
create_org frontend frontend_user web
create_repo java_web frontend web
create_repo signup_client frontend web


create_user backend_user
create_org backend backend_user services
create_repo database backend services
create_repo messageservice backend services
create_repo worker backend services
