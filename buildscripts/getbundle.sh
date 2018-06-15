#!/bin/bash
UCP_HOST=${UCP_HOST:-$1}

ADMIN_USER=${2:-admin}
ADMIN_PASS=${3:-admin1234}
PAYLOAD="{\"username\": \"$ADMIN_USER\", \"password\": \"$ADMIN_PASS\"}"
TOKEN=$(curl -s --insecure  -d "$PAYLOAD" -X POST https://"$UCP_HOST"/auth/login  | jq -r ".auth_token")

curl -s -k -H "Authorization: Bearer $TOKEN" https://"$UCP_HOST"/api/clientbundle > $(pwd)/bundle.zip
mkdir -p bundle
cd bundle
unzip ../bundle.zip
cd -