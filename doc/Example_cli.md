Example: How to use a beanstalkd tools with the coolbeans K8s service
=====================================================================

This guide provides an example CLI on how to connect with coolbeans beanstalkd on kubernetes.

- [Objectives](#objectives)
- [Requirements](#requirements)
- [Setup port forwarding](#setup-port-forwarding)
- [Run a beanstalkd cli](#run-a-beanstalkd-cli)

Objectives
----------

- Setup port forwarding from the kubernetes cluster to your machine.
- Setup and run a beanstalkd CLI tool to talk to the cluster.


Requirements
------------

- A coolbeans & beanstalkd service running on kubernetes.


Setup port forwarding
---------------------

We will use kubernetes [port forwarding](https://kubernetes.io/docs/tasks/access-application-cluster/port-forward-access-application-cluster/) to forward requests to the tcp port of the beanstalkd service


### Verify the beanstalkd's proxy service is running

Query via kubectl to get the port address of the beanstalkd proxy

    kubectl -n coolbeans get service beanstalkd

    NAME         TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)     AGE
    beanstalkd   ClusterIP   10.244.14.6   <none>        11300/TCP   13m


### Setup port forwarding 

Use kubectl port-forward using the service  resource name to port forward to.

    kubectl -n coolbeans port-forward service/beanstalkd 11300:11300

    Forwarding from 127.0.0.1:11300 -> 11300
    Forwarding from [::1]:11300 -> 11300
    Handling connection for 11300
    Handling connection for 11300


Run a beanstalkd cli
--------------------

Checkout [beanstalkd's community page](https://github.com/beanstalkd/beanstalkd/wiki/Tools) for some tools

Example: We picked yabean since we are familiar with it,

### Download & unzip yabean

Download, and unzip the yabean CLI for the OS/arch https://github.com/1xyz/yabean/releases

    wget https://github.com/1xyz/yabean/releases/download/v0.1.4/yabean_0.1.4_darwin_amd64.tar.gz
    Saving to: ‘yabean_0.1.4_darwin_amd64.tar.gz’

    tar xvf yabean_0.1.4_darwin_amd64.tar.gz
    x LICENSE
    x README.md
    x yabean

### Run a few sample commands

Run some put(s)

    ./yabean put --tube "tube01" --body "hello world"
    c.Put() returned id = 1

    ./yabean put --tube "tube01" --body "你好"
    c.Put() returned id = 2

    ./yabean put --tube "tube01" --body "नमस्ते"
    c.Put() returned id = 3


Reserve a job & delete the reserved job

    ./yabean reserve --tube "tube01"  --string --del
    reserved job id=1 body=11
    body = hello world


Reserve a job and allow a TTL to timeout, the job can be reserved again after ttr

    ./yabean reserve --tube "tube01"  --string
    reserved job id=2 body=6
    body = 你好
    INFO[0000] job allowed to timeout without delete, bury or release actions

Reserve a job & bury the deleted job

    ./yabean reserve --tube "tube01"  --string --bury
    reserved job id=3 body=18
    body = नमते
    buried job 3, pri = 1024


View the tube stats, check out current-jobs-reserved & current-jobs-buried are 1

    ./yabean stats-tube tube01
    StatsTube tube=tube01
    (cmd-delete => 0)
    (cmd-pause-tube => 0)
    (current-jobs-buried => 1)   
    (current-jobs-delayed => 0)
    (current-jobs-ready => 1)
    (current-jobs-reserved => 1)
    (current-jobs-urgent => 0)
    (current-using => 0)
    (current-waiting => 0)
    (current-watching => 0)
    (name => tube01)
    (pause => 0)
    (pause-time-left => 0)
    (total-jobs => 0)


Kick the buried job

    ./yabean kick 3
    job with id = 3 Kicked.

View the tube stats again check out current-jobs-ready is 2, job id 2 moved from reserved to ready (after ttr timeout) and job id 3 got kicked to ready again

    ./yabean stats-tube tube01
    StatsTube tube=tube01
    (cmd-delete => 0)
    (cmd-pause-tube => 0)
    (current-jobs-buried => 0)
    (current-jobs-delayed => 0)
    (current-jobs-ready => 2)
    (current-jobs-reserved => 0)
    (current-jobs-urgent => 0)
    (current-using => 0)
    (current-waiting => 0)
    (current-watching => 0)
    (name => tube01)
    (pause => 0)
    (pause-time-left => 0)
    (total-jobs => 0)

Run a UX program
----------------

I also liked using the [Aurora UI](https://github.com/xuri/aurora)

    wget https://github.com/xuri/aurora/releases/download/2.2/aurora_darwin_amd64_v2.2.tar.gz
    aurora_darwin_amd64_v2.2.tar.gz

    tar xvf aurora_darwin_amd64_v2.2.tar.gz
    x aurora

    ./aurora

- This opens the browser window to http://127.0.0.1:3000/

- Click on the Add Server and add a server at Host = localhost and Port = 11300

- Visit http://127.0.0.1:3000/server?server=localhost:11300 

- Explore further