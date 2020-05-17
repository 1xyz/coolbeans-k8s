How to run Coolbeans in Kubernetes
==================================

This repository provides a sample setup and examples to run coolbeans queuing service on kubernetes.

- [Quick setup](#quick-setup)
- [Detailed step by step setup](doc/Guide.md)


Quick setup
-----------

Run setup.sh 

    $ ./setup.sh

The above script applies k8s yaml files to create

- A three pod stateful set that provides a replicated coolbeans queue.

- A beanstalkd proxy service, with two replica pods, that proxies your request to the coolbeans queue.

Verify that all pods are up & running

    $ kubectl -n coolbeans get pods --watch

    NAME                          READY   STATUS              RESTARTS   AGE
    beanstalkd-7565987d88-f7qs6   1/1     Running             0          18s
    beanstalkd-7565987d88-wlbpb   1/1     Running             0          18s
    coolbeans-0                   1/1     Running             0          19s
    coolbeans-1                   1/1     Running             0          19s
    coolbeans-2                   1/1     Running             0          24s


If you prefer to see a detailed step by step review check out [guide]((doc/Guide.md)).

Next steps
----------

- Deploy a simple demo app that uses the deployed coolbeans queuing service.

Shutdown this setup
-------------------

To shutdown 

    $ ./shutdown.sh

Verify that all resources are removed

    $ kubectl get namespace coolbeans

    Error from server (NotFound): namespaces "coolbeans" not found

Ensure that the cloud provider has removed the storage that backs the persistent volume.