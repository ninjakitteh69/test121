#!/bin/bash
project=REFERENCE
env=${1}; shift
project_version=${1}; shift
source_repo_url=$(git config --get remote.origin.url | awk -F'/' '{print $NF}' | sed 's/\..*//')

if [ ! -f vars/${env,,}.yml ]; then
    echo "No corresponding environment file found for '${env,,}' environment"
    exit 1
fi

deploy_region=$(yq e ".region" vars/${env,,}.yml)
deploy_account=$(yq e ".account" vars/${env,,}.yml)
current_account=$(aws sts get-caller-identity | jq -r '.Account')
if [ "${deploy_account}" != "${current_account}" ]; then
    echo "Incorrect credentials for deploying '${env,,}' environment"
    exit 1
fi

extra_vars="project=${project} env=${env} project_version=${project_version} source_repo_url=${source_repo_url}"
ansible-playbook deploy.yml -e "${extra_vars}" "$@"
