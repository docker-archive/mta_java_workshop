#!/usr/bin/env bash

set -e

# output colors
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
NORMAL=$(tput sgr0)

DTR_HOST=${DTR_HOST:-$1}
ADMIN_USER=${ADMIN_USER:-"admin"}
ADMIN_PASSWORD=${ADMIN_PASSWORD:-"admin1234"}
DEBUG=${4:-false}

if [ -z "$DTR_HOST" ]; then
  echo "ERROR - DTR_HOST ENV param is empty or unset"
  exit 1
fi

CURL_CMD="curl -k -s -u ${ADMIN_USER}:${ADMIN_PASSWORD} https://${DTR_HOST}"
CURL_HEADERS=(-H 'Content-Type: application/json;charset=UTF-8' -H 'accept: application/json')

post(){
  URI=$1
  if [ "$2" != "" ]; then
    DATA="-d ${2}"
  fi

  RESPONSE=$(${CURL_CMD}${URI} -X POST ${DATA} "${CURL_HEADERS[@]}")
  if [[ "$DEBUG" == "true" ]]||[[ $DEBUG == 1 ]]; then
    echo $RESPONSE
  fi
}

put(){
  URI=$1
  if [ "$2" != "" ]; then
    DATA="-d ${2}"
  fi

  RESPONSE=$(${CURL_CMD}${URI} -X PUT "${DATA}" "${CURL_HEADERS[@]}")
  if [[ "$DEBUG" == "true" ]]||[[ $DEBUG == 1 ]]; then
    echo $RESPONSE
  fi
}

create_user(){
  USERNAME=$1
  PASSWORD=${2:-"user1234"}
  echo $GREEN "Creating user $USERNAME" $NORMAL
  post /enzi/v0/accounts '{"isAdmin":false,"isActive":true,"username":"'${USERNAME}'","password":"'${PASSWORD}'","fullName":"'${USERNAME}'","name":"'${USERNAME}'","type":"user"}'
}

create_org(){
  ORG=$1
  USER=$2
  TEAM=$3
  echo $GREEN "Creating org $ORG and $TEAM with user $USER" $NORMAL
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
  echo $GREEN "Creating repo ${ORG}/${REPO} for team ${TEAM}" $NORMAL
  post /api/v0/repositories/${ORG} "{\"name\":\"${REPO}\",\"visibility\":\"public\",\"shortDescription\":\"${REPO}\",\"scanOnPush\":true}"
  put /api/v0/repositories/${ORG}/${REPO}/teamAccess/${TEAM} '{"accessLevel":"read-write"}'
}

create_user gitlab
create_org ci gitlab build
create_repo java_app_build ci build
