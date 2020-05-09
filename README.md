How to run Coolbeans in Kubernetes
==================================

This example walks through the steps on how to run coolbeans in a Kubernetes setup.

Assumptions
-----------

- You have a running kubernetes or a minikube cluster available to you.


Steps
-----

### Ensure that kubectl is pointing to the correct context

    kubectl config get-contexts

    CURRENT   NAME                                              CLUSTER                                           AUTHINFO                                          NAMESPACE
    *         gke_xyz-dev-274318_us-central1-c_test-cluster-2   gke_xyz-dev-274318_us-central1-c_test-cluster-2   gke_xyz-dev-274318_us-central1-c_test-cluster-2
              minikube                                          minikube                                          minikube

### Create a namespace

    kubectl apply -f namespace.yaml


Verify the namespace `coolbeans` is created

    kubectl get namespaces 

    NAME              STATUS   AGE
    coolbeans         Active   97m



### Apply the configuration map

    kubectl apply -f coolbeans-configmap.yaml

Verify the configmap `coolbeans-config` is created

    kubectl -n coolbeans get configmaps
    NAME               DATA   AGE
    coolbeans-config   6      81m


### Create the service 

    kubectl apply -f coolbeans-service.yaml


Verify the service `coolbeans` is created

    kubectl -n coolbeans get service

    NAME        TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)               AGE
    coolbeans   ClusterIP   None         <none>        11000/TCP,21000/TCP   99m


### Create a stateful set (three node cluster)

    kubectl -n coolbeans  apply -f coolbeans-statefulset.yaml

Verify the stateful set is created

    kubectl -n coolbeans get statefulsets

    NAME        READY   AGE
    coolbeans   3/3     16m


Verify that you have three pods up & running

    kubectl -n coolbeans get pods

    NAME                         READY   STATUS    RESTARTS   AGE
    coolbeans-0                  1/1     Running   0          16m
    coolbeans-1                  1/1     Running   0          16m
    coolbeans-2                  1/1     Running   0          16m

Verify that the service endpoints are updated

    kubectl -n coolbeans get ep

    NAME        ENDPOINTS                                                        AGE
    coolbeans   10.24.0.13:11000,10.24.1.13:11000,10.24.2.13:11000 + 3 more...   103m


### Deploy beanstalkd proxy

    kubectl -n coolbeans  apply -f beanstalk-deployment.yaml

    




















