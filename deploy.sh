#!/bin/bash

export KUBE_NAMESPACE=${KUBE_NAMESPACE}

export KUBE_SERVER=https://kube-api-notprod.notprod.acp.homeoffice.gov.uk

if [[ ${ENVIRONMENT} == "pr" ]] ; then
    echo "deploy smoke tests to pr namespace, using PTTG_IP_PR drone secret"
    export KUBE_TOKEN=${PTTG_IP_PR}
    export KUBE_SERVER=https://kube-api-prod.prod.acp.homeoffice.gov.uk
elif [[ ${ENVIRONMENT} == "test" ]] ; then
    echo "deploy smoke tests to test namespace, using PTTG_IP_TEST drone secret"
    export KUBE_TOKEN=${PTTG_IP_TEST}
else
    echo "deploy smoke tests to dev namespace, using PTTG_IP_DEV drone secret"
    export KUBE_TOKEN=${PTTG_IP_DEV}
fi

if [[ -z ${KUBE_TOKEN} ]] ; then
    echo "Failed to find a value for KUBE_TOKEN - exiting"
    exit -1
fi

if [ "${ENVIRONMENT}" == "pr" ] ; then
    export DNS_PREFIX=
else
    export DNS_PREFIX=${ENVIRONMENT}.notprod.
fi

echo
echo "Deploying pttg-ip-smoke-tests to ${ENVIRONMENT}"
echo

cd kd

kd --insecure-skip-tls-verify --replace -f job.yaml
