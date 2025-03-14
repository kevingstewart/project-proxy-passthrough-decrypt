#!/bin/bash

baseurl=""

if [[ -z "${BIGUSER}" ]]
then
    echo 
    echo "The user:pass must be set in an environment variable. Exiting."
    echo "   export BIGUSER='admin:password'"
    echo 
    exit 1
fi

## Create a stub CA certificate
echo "..Creating a stub CA certificate"

## Create a stub CA key
echo "..Creating a stub CA key"

## Create the iRule
echo "..Creating the iRule"
rule=$(curl -sk $(${baseurl}/refs/heads/main/proxy-passthrough-rule | awk '{printf "%s\\n", $0}' | sed -e 's/\"/\\"/g;s/\x27/\\'"'"'/g')
data="{\"name\":\"proxy-passthrough-rule\",\"apiAnonymous\":\"${rule}\"}"
curl -sk \
-u ${BIGUSER} \
-H "Content-Type: application/json" \
-d "${data}" \
https://localhost/mgmt/tm/ltm/rule -o /dev/null

## Create the client SSL profile
echo "..Creating the SSLFWD client SSL profile"

## Create the server SSL profile
echo "..Creating the SSLFWD server SSL profile"

## Create the virtual server
echo "..Creating the virtual server"

