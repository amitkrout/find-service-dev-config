#!/bin/sh
oc apply -f 01-operator
oc new-project dev-environment
oc new-project stage-environment
oc new-project cicd-environment
oc apply -f $HOME/Downloads/QUAYIO_USERNAME-secret.yml
oc create secret generic regcred --from-file=.dockerconfigjson=$HOME/Downloads/QUAYIO_USERNAME-auth.json --type=kubernetes.io/dockerconfigjson
oc apply -f 02-serviceaccount
oc adm policy add-scc-to-user privileged -z demo-sa
oc adm policy add-role-to-user edit -z demo-sa
oc create rolebinding demo-sa-admin-dev --clusterrole=admin --serviceaccount=cicd-environment:demo-sa --namespace=dev-environment
oc create rolebinding demo-sa-admin-stage --clusterrole=admin --serviceaccount=cicd-environment:demo-sa --namespace=stage-environment
oc apply -f 03-templatesandbindings
oc apply -f 04-interceptor
oc apply -f 05-ci
oc apply -f 06-cd
oc apply -f 07-eventlisteners
oc apply -f 08-routes
oc create secret generic github-auth --from-file=$HOME/Downloads/token
