#!/bin/bash

baseurl="https://raw.githubusercontent.com/kevingstewart/project-proxy-passthrough-decrypt"

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
rule=$(curl -sk ${baseurl}/refs/heads/main/proxy-passthrough-rule | awk '{printf "%s\\n", $0}' | sed -e 's/\"/\\"/g;s/\x27/\\'"'"'/g;s/\\x20/\\\\x20/g;s/\\d/\\\\d/g')
data="{\"name\":\"proxy-passthrough-rule\",\"apiAnonymous\":\"${rule}\"}"
curl -sk \
-u ${BIGUSER} \
-H "Content-Type: application/json" \
-d "${data}" \
https://localhost/mgmt/tm/ltm/rule -o /dev/null


## Create the client SSL profile
echo "..Creating the SSLFWD client SSL profile"
tmsh create ltm profile client-ssl proxy-passthrough-decrypt-cssl allow-non-ssl enabled ssl-forward-proxy enabled ssl-forward-proxy-bypass enabled cert-key-chain add { forgingca { cert forgingca key forgingca usage CA }}


## Create the server SSL profile
echo "..Creating the SSLFWD server SSL profile"
tmsh create ltm profile server-ssl proxy-passthrough-decrypt-sssl ca-file ca-bundle.crt expire-cert-response-control ignore peer-cert-mode require revoked-cert-status-response-control ignore ssl-forward-proxy enabled ssl-forward-proxy-bypass enabled unknown-cert-status-response-control ignore untrusted-cert-response-control ignore


## Create the virtual server
echo "..Creating the virtual server"



