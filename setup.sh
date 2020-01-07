#!/bin/sh
QUAYIO_USERNAME=$1
GITHUB_REPO=$2

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     SED_OPTIONS="-i";;
    Darwin*)    SED_OPTIONS="-i \"\"";;
    *)          echo "unknown OS ${unameOut}"; exit 1;;
esac

if [[ $# -ne 2 ]]; then
    echo 'usage: ./setup.sh <quayio-username> <github repo>'
    exit 1
fi

IFS='/' # assumes orgname/repo
read -ra seg <<< "${GITHUB_REPO}"

if [[ ${#seg[@]} -ne 2 ]]; then
  echo 'github repo must be of the form orgname/repo'
fi

ORGNAME=${seg[0]}
APPNAME=${seg[1]}
PULL_SECRET_NAME="${QUAYIO_USERNAME}-pull-secret"
IMAGE_REPO="quay.io/${QUAYIO_USERNAME}/${APPNAME}"
GITHUB_REPO="${ORGNAME}/${APPNAME}"
GITHUB_STAGE_REPO="${ORGNAME}/${APPNAME}-stage-config"

FILENAME="$HOME/Downloads/${QUAYIO_USERNAME}-auth.json"
if [ ! -f "${FILENAME}" ]; then
    echo "${FILENAME} does not exist"
    exit 1
fi

FILENAME="$HOME/Downloads/${QUAYIO_USERNAME}-secret.yml"
if [ ! -f "${FILENAME}" ]; then
    echo "${FILENAME} does not exist"
    exit 1
fi

sed $SED_OPTIONS "s|REPLACE_IMAGE|${IMAGE_REPO}|g" deploy/*.yaml pipelines/**/*.yaml
sed $SED_OPTIONS "s|PULL_SECRET_NAME|${PULL_SECRET_NAME}|g" pipelines/02-serviceaccount/serviceaccount.yaml deploy/*.yaml
sed $SED_OPTIONS "s|QUAYIO_USERNAME|${QUAYIO_USERNAME}|g" pipelines/bootstrap.sh
sed $SED_OPTIONS "s|DOCKER_CONFIG_NAME|${DOCKER_CONFIG_NAME}|g" pipelines/bootstrap.sh
sed $SED_OPTIONS "s|GITHUB_REPO|${GITHUB_REPO}|g" pipelines/07-eventlisteners/cicd-event-listener.yaml
sed $SED_OPTIONS "s|GITHUB_STAGE_REPO|${GITHUB_STAGE_REPO}|g" pipelines/07-eventlisteners/cicd-event-listener.yaml pipelines/argocd/argo-app.yaml
