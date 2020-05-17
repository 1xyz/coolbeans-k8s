Troubleshooting
===============

### How do I upgrade the coolbeans queuing service?

The example uses a [rolling update strategy for statefulset](https://kubernetes.io/docs/tutorials/stateful-application/basic-stateful-set/#updating-statefulsets). 

Here are the steps:

Edit [k8s/cluster-node/3-statefulset.yaml](../k8s/cluster-node/3-statefulset.yaml)

- change the spec.containers.image value to the desired image. 

Here is an example where we upgrade the image in the [statefulset.yaml](k8s/cluster-node/3-statefulset.yaml)


    spec:
        ...
        ...
        container:   
        - name: cluster-node
          image: 1xyz/coolbeans:master-59560c3 <-- change this image
          imagePullPolicy: Always

In the example above will change the image to 1xyz/coolbeans:master-59560c3. 

- Ensure that the spec.updateStrategy.rollingUpdate.updatePartition value equal to the number of server replicas.

In the example the value of spec.updateStrategy.rollingUpdate.updatePartition is set to 3.


    spec:
        ...
        replicas: 3
        updateStrategy:
         type: RollingUpdate
         rollingUpdate:
           partition: 3 <-- the partition should equal the number of replicas


The partition value controls how many instances of the cluster are updated. Only instances with an index greater than the updatePartition value are updated (zero-indexed). Therefore, by setting it equal to replicas, none should update once the statefulset is applied.

- Apply the statefulset

Apply the stateful set.

    kubectl apply -f k8s/cluster-node/3-statefulset.yaml

As mentioned before you should see no changes in the pods.

- Change the partition value to 2 and reapply the stateful set

```
    spec:
        ...
        replicas: 3
        updateStrategy:
         type: RollingUpdate
         rollingUpdate:
           partition: 2 <-- change this to 2 will trigger a rollout of pod coolbeans-2
```

followed by 

    kubectl apply -f k8s/cluster-node/3-statefulset.yaml

Wait until the coolbeans cluster is healthy again (30s to a few minutes) then decrease updatePartition and upgrade again. Continue until updatePartition is 0. At this point, you may update the updatePartition configuration back to replica count. Your server upgrade is complete.

This is similar to the [upgrade approach](https://www.consul.io/docs/k8s/operations/upgrading#upgrading-consul-servers) used in consul.
