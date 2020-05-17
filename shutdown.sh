#!/bin/bash

if ! [ -x "$(command -v kubectl)" ]; then
  echo 'Error: kubectl not found in path.' >&2
  exit 1
fi

echo "delete beanstalkd-proxy"
kubectl -n coolbeans delete deployment beanstalkd
kubectl -n coolbeans delete service beanstalkd

echo "delete coolbeans"
kubectl -n coolbeans delete statefulset coolbeans
kubectl -n coolbeans delete service coolbeans
kubectl -n coolbeans delete configmap coolbeans-config

echo "delete namespace"
kubectl -n coolbeans delete namespace coolbeans