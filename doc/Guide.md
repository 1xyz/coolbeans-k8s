How to run Coolbeans in Kubernetes - A step by step guide
==========================================================

This repository provides an example setup to run coolbeans on kubernetes.

- [Objectives](#objectives)
- [Requirements](#requirements)
- [Deploy coolbeans](#deploy-coolbeans-cluster)
- [Deploy beanstalkd proxy](#deploy-beanstalkd-proxy)

Objectives
----------

- Walk through the steps on how to setup a three node coolbeans cluster in kubernetes.
- Deploy a beanstalkd proxy service that connects with these pods
- Deploy a sample producer & consumer that uses the coolbeans cluster.

Requirements
------------

- You have a running kubernetes cluster or a minikube setup available to you.

- Ensure that kubectl is pointing to the correct context

```
    $ kubectl config get-contexts

    CURRENT   NAME                                              CLUSTER                                           
    *         gke_xyz-dev-274318_us-central1-c_test-cluster-2   gke_xyz-dev-274318_us-central1-c_test-cluster-2
              minikube                                          minikube                                        
```

Deploy coolbeans cluster
------------------------

Following are steps to setup a three node coolbeans cluster in the namespace coolbeans.

### Create coolbeans namespace

    kubectl apply -f k8s/cluster-node/0-namespace.yaml

Verify the namespace `coolbeans` is created

    kubectl get namespaces 

    NAME              STATUS   AGE
    coolbeans         Active   1m

### Apply the configuration map

    kubectl apply -f k8s/cluster-node/1-configmap.yaml

Verify the configmap `coolbeans-config` is created

    kubectl -n coolbeans get configmaps
    NAME               DATA   AGE
    coolbeans-config   6      1m

### Create the coolbeans service 

    kubectl apply -f k8s/cluster-node/2-service.yaml

Verify the service `coolbeans` is created

    kubectl -n coolbeans get service

    NAME        TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)               AGE
    coolbeans   ClusterIP   None         <none>        11000/TCP,21000/TCP   1m

### Create a stateful set

    kubectl apply -f k8s/cluster-node/3-statefulset.yaml

Verify the stateful set is created

    kubectl -n coolbeans get statefulsets

    NAME        READY   AGE
    coolbeans   3/3     3m

Verify that you have three pods up & running

    kubectl -n coolbeans get pods

    NAME                         READY   STATUS    RESTARTS   AGE
    coolbeans-0                  1/1     Running   0          3m
    coolbeans-1                  1/1     Running   0          3m
    coolbeans-2                  1/1     Running   0          3m

Verify that a persistent volume & and persistent volume claims are created.

    kubectl -n coolbeans get pv

    NAME                                       ...   CLAIM                        ....
    pvc-613a4b02-97bd-11ea-b5d7-42010a8000c1         coolbeans/data-coolbeans-0   ....
    pvc-613ee9ef-97bd-11ea-b5d7-42010a8000c1         coolbeans/data-coolbeans-1   ....
    pvc-6147fec0-97bd-11ea-b5d7-42010a8000c1         coolbeans/data-coolbeans-2   ....


    kubectl -n coolbeans get pvc

    NAME               STATUS   VOLUME                                     CAPACITY ...
    data-coolbeans-0   Bound    pvc-613a4b02-97bd-11ea-b5d7-42010a8000c1   1Gi      ...
    data-coolbeans-1   Bound    pvc-613ee9ef-97bd-11ea-b5d7-42010a8000c1   1Gi      ...
    data-coolbeans-2   Bound    pvc-6147fec0-97bd-11ea-b5d7-42010a8000c1   1Gi      ...

### Deploy beanstalkd proxy

    kubectl -n coolbeans  apply -f beanstalk-deployment.yaml

Deploy beanstalkd proxy
-----------------------

Deploy the beanstalkd proxy & service.

    kubectl apply -f k8s/proxy/deployment.yaml

    service/beanstalkd created
    deployment.apps/beanstalkd unchanged

Check if the server and endpoints  

    kubectl -n coolbeans get service beanstalkd

    NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)     AGE
    beanstalkd   ClusterIP   10.6.2.8     <none>        11300/TCP   24s

    kubectl -n coolbeans get ep beanstalkd

    NAME         ENDPOINTS                         AGE
    beanstalkd   10.8.0.25:11300,10.8.1.20:11300   68s



