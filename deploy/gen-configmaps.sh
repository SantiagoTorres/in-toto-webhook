#!/usr/bin/env bash

print_usage() {
  echo "gen-configmaps.sh expects one arg- path to the in-toto keys dir, ending with a slash"
}

# Defaults
NAME=in-toto
NAMESPACE=in-toto
KEYS_PATH=${1:-}
OS="`uname`"

# TODO doesn't work
[[ -z ${KEYS_PATH} ]] && [[ ${KEYS_PATH} == */ ]] && {
  print_usage
  exit 1
}

# Generate cert secret
kubectl -n ${NAMESPACE} create configmap \
    ${NAME}-configmap \
    --from-file=${KEYS_PATH} \
    --dry-run -o yaml > ./webhook-configmap.yaml
