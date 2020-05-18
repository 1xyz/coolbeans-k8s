Example: How to run a sample batch workload with coolbeans K8s service
======================================================================

This guide provides an example on how to run a contrived batch workload with kubernetes. 

- [Objectives](#objectives)
- [Requirements](#requirements)
- [Deploy producer job](#deploy-producer-job)
- [Deploy consumer job](#deploy-consumer-job)
- [Delete jobs](#delete-jobs)

Objectives
----------

- Deploy a producer kubernetes job that produces items to a tube.
- Deploy a consumer kubernetes job that consumes items from that tube, verifies the data and deletes (ACKs) the items.


Requirements
------------

- A coolbeans & beanstalkd service running on kubernetes.


Deploy producer job
-------------------

The producer job generates a configured number of JSON entries, and queues it to a tube called "workload".

A sample JSON entry looks like the entry below:

    {
        data: "<random-alpha-numeric-string of random size>",
        hash: "<sha 256 hash of the data field>"
    }


To run the producer:

    kubectl apply -f k8s/workload/producer.yaml


    kubectl -n coolbeans get jobs
    NAME              COMPLETIONS   DURATION   AGE
    produce-batch-0   0/1           2s         2s

    kubectl -n coolbeans get pods --watch
    ...
    produce-batch-0-fxqpp         1/1     Running   0          24s


You can follow the logs:

    kubectl logs -f produce-batch-0-fxqpp


Once the job is complete, run stats-tube workload to get the number of ready entries (current-jobs-ready) in the workload tube. 
In this specific case, the job added 20000 entries

    ./bin/yabean stats-tube workload
    StatsTube tube=workload
    (cmd-delete => 0)
    (cmd-pause-tube => 0)
    (current-jobs-buried => 0)
    (current-jobs-delayed => 0)
    (current-jobs-ready => 20000)
    (current-jobs-reserved => 0)
    (current-jobs-urgent => 0)
    (current-using => 0)
    (current-waiting => 0)
    (current-watching => 0)
    (name => workload)
    (pause => 0)
    (pause-time-left => 0)
    (total-jobs => 0)


Deploy consumer job
-------------------

The consumer job perform a reserve command of the workload tube. Once it reserves an entry, it de-serializes the bytes to JSON and verifies if the SHA-256 sum of the data value equals the hash value. Once success, it deletes the entry. On failure, it exits the job.

A sample JSON entry looks like the entry below:

    {
        data: "<random-alpha-numeric-string of random size>",
        hash: "<sha 256 hash of the data field>"
    }


To run the consumer:

    kubectl apply -f k8s/workload/consumer.yaml


    kubectl -n coolbeans get jobs
    NAME              COMPLETIONS   DURATION   AGE
    consume-batch-0   0/1           5s         5s

    kubectl -n coolbeans get pods --watch
    ...
    consume-batch-0-2pqht         1/1     Running     0          24s


You can follow the logs:

    kubectl logs -f consume-batch-0-2pqht


Once the job is complete, run stats-tube workload to check the number of ready entries (current-jobs-ready) in the queue is 0.

    ./bin/yabean stats-tube workload
    StatsTube tube=workload
    (cmd-delete => 0)
    (cmd-pause-tube => 0)
    (current-jobs-buried => 0)
    (current-jobs-delayed => 0)
    (current-jobs-ready => 0)
    (current-jobs-reserved => 0)
    (current-jobs-urgent => 0)
    (current-using => 0)
    (current-waiting => 1)
    (current-watching => 0)
    (name => workload)
    (pause => 0)
    (pause-time-left => 0)
    (total-jobs => 0)

Delete jobs
-----------

Delete the kubernetes jobs

    kubectl -n coolbeans delete job produce-batch-0
    job.batch "produce-batch-0" deleted
    
    kubectl -n coolbeans delete jobs.batch consume-batch-0
    job.batch "consume-batch-0" deleted
