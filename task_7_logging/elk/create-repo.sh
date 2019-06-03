#!/usr/bin/env bash
# create repository and assign team access to it

set -e

# output colors
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
NORMAL=$(tput sgr0)

DTR_HOST=${DTR_HOST:-$1}
ADMIN_USER=${ADMIN_USER:-$2}
ADMIN_PASSWORD=${ADMIN_PASSWORD:-$3}
NAMESPACE=${4:-'backend'}
REPO=${5:-'journalbeat'}
TEAM=${6:-'services'}
DEBUG=${7:-false}

if [ -z "$DTR_HOST" ]; then
  echo "ERROR - DTR_HOST ENV param is empty or unset"
  exit 1
fi

CURL_OPTS=(-kLsS -u ${ADMIN_USER}:${ADMIN_PASSWORD} \
  -H 'Content-Type: application/json;charset=UTF-8' -H 'accept: application/json')

echo $GREEN "create repo '${NAMESPACE}/${REPO}'..." $NORMAL
RESPONSE=$( curl "${CURL_OPTS[@]}" -X POST https://${DTR_HOST}/api/v0/repositories/${NAMESPACE} \
  -d "{\"name\":\"${REPO}\",\"visibility\":\"public\",\"shortDescription\":\"${REPO}\",\"scanOnPush\":false}" )
if [[ "$DEBUG" == "true" ]]||[[ $DEBUG == 1 ]]; then
  echo $RESPONSE
fi

echo $GREEN "assign team '${TEAM}' to repo '${NAMESPACE}/${REPO}'..." $NORMAL
RESPONSE=$( curl "${CURL_OPTS[@]}" -X PUT https://${DTR_HOST}/api/v0/repositories/${NAMESPACE}/${REPO}/teamAccess/${TEAM} \
  -d '{"accessLevel":"read-write"}' )
if [[ "$DEBUG" == "true" ]]||[[ $DEBUG == 1 ]]; then
  echo $RESPONSE
fi
