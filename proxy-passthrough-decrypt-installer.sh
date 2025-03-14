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
rule=$(curl -sk $(${baseurl}/refs/heads/main/

## Create the client SSL profile
echo "..Creating the SSLFWD client SSL profile"

## Create the server SSL profile
echo "..Creating the SSLFWD server SSL profile"

## Create the virtual server
echo "..Creating the virtual server"

