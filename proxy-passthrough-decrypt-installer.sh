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

## Create a stub CA key
echo "..Creating a stub CA key"
echo "$(curl -sk ${baseurl}/refs/heads/main/forgingcakey | base64 -d)" > tmpkey
tmsh install sys crypto key forgingca security-type normal from-local-file $(pwd)/tmpkey
rm -f $(pwd)/tmpkey


## Create a stub CA certificate
echo "..Creating a stub CA certificate"
echo "$(curl -sk ${baseurl}/refs/heads/main/forgingcacrt | base64 -d)" > tmpcrt
tmsh install sys crypto cert forgingca from-local-file $(pwd)/tmpcrt
rm -f $(pwd)/tmpcrt


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
tmsh create ltm profile client-ssl proxy-passthrough-decrypt-cssl \
allow-non-ssl enabled \
ssl-forward-proxy enabled \
ssl-forward-proxy-bypass enabled \
cert-key-chain add { forgingca { cert forgingca key forgingca usage CA }}


## Create the server SSL profile
echo "..Creating the SSLFWD server SSL profile"
tmsh create ltm profile server-ssl proxy-passthrough-decrypt-sssl \
ssl-forward-proxy enabled \
ssl-forward-proxy-bypass enabled \
peer-cert-mode require \
ca-file ca-bundle.crt \
expire-cert-response-control ignore \
revoked-cert-status-response-control ignore \
unknown-cert-status-response-control ignore \
untrusted-cert-response-control ignore


## Create the virtual server
echo "..Creating the virtual server"
tmsh create ltm virtual proxy-passthrough-decrypt-vip \
destination 0.0.0.0:3128 \
mask any \
profiles replace-all-with { \
 tcp {} \
 http {} \
 forgingca { context clientside } \
 forgingca { context serverside } \
} \
source-address-translation { type automap } \
translate-address disabled \
translate-port disabled \
rules { proxy-passthrough-rule }


echo "..Done"
