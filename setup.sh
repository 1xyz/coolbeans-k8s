#!/bin/bash

if ! [ -x "$(command -v kubectl)" ]; then
  echo 'Error: kubectl not found in path.' >&2
  exit 1
fi

for f in k8s/cluster-node/*.yaml
do
  echo "kubectl apply -f $f"
  kubectl apply -f $f
done

echo "Apply proxy/deployment.yaml"
kubectl apply -f k8s/proxy/deployment.yaml