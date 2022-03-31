#Datastax DSE chart

This is a chart that makes use of our vanilla docker-images so it's easier to integrate with out DSE docker image.
The major downside to this is it's very specific to the version of DSE and so requires you to override an entire configuration
yaml instead of just passing in parameters.

## DSE HELM CHART
This chart installs a DSE cluster onto Kubernetes using the official [DataStax Docker Images](https://hub.docker.com/r/datastax/dse-server/)

## Prerequisites

Kubernetes version 1.11+
Persistent Volumes for nodes

## Install Chart with specific DSE Version
By default, this Chart will create a DSE cluster running DSE 6.0.4. If you want to change the DSE version during installation you can use `image.tag={value}` argument or you can edit the `values.yaml`

For example:
Install DSE 6.7.0 to the namespace dse

```bash
helm install --namespace "dse" -n "dse" --set image.tag=6.7.0 datastax-dse
```

## Install Chart with specific cluster size
By default, this Chart will create a DSE cluster with 5 nodes. If you want to change the cluster size during installation, you can use `--set cassandra.replicas={value}` argument or you can edit the `values.yaml` 

For example:
Set cluster size to 3 

```bash
helm install --namespace "dse" -n "dse" --set cassandra.replicas=3 datastax-dse
```



## Configuration

The following table lists the configurable parameters of the DataStax-DSE chart and their default values.

| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
| `repository`                         | `dse` docker image repository                    | `datastax/dse-server`                                                |
| `image.tag`                          | `dse` docker image tag   | `6.0.4`   |
| `image.args`                   | Image pull policy                          |  `IfNotPresent`    |
| `image.args`                  | Workload to deploy  not set = `cassandra`, analytics = `-k`, search = `-s`, graph =`-g`  | `not set`   |
| `service.ports`                   | Native Transport Port                                | `9042`                                                     |
| `cassandra.num_tokens`                  | (Vnodes) Number of token ranges to assign per node | `32`                                                      |
| `cassandra.seeds`                   | The number of seed nodes used to bootstrap new clients joining the cluster.                            | `2` |
| `cassandra.replicas`                | The number of nodes in the cluster.             | `3`                                                        |
| `cassandra.cluster_name`                | The name of the cluster.                        | `DSE Cluster`                                                |
| `cassandra.dc`                     | DC Name                                | `DC1`                                                      |
| `cassandra.rack`                   | Rack Name                                | `RACK1`                                                     |
| `cassandra.concurrent_compactors`             | The number of concurrent compaction processes allowed to run simultaneously on a node.                                | `2`                                             |
| `cassandra.compaction_throughput_mb_per_sec`               | Throttles compaction to the specified Mb/second.                                | `16`                                                    |
| `cassandra. memtable_allocation_type `   | The method Cassandra uses to allocate and manage memtable memory.                                | `heap_buffers`                                                     |
| `cassandra.memtable_cleanup_threshold     | Ratio used for automatic memtable flush                                | `0.40`                                                     |
| `cassandra.memtable_flush_writers`                 | The number of memtable flush writer threads              | `2`                                                      |
| `cassandra.memtable_heap_space_in_mb`                   | The amount of on-heap memory allocated for memtables                               | `512`                                                    |
| `cassandra.memtable_offheap_space_in_mb`                    | Total amount of off-heap memory allocated for memtables   | `512`                                                       |
| `cassandra.stream_throughput_outbound_megabits_per_sec`                   | Throttle for the throughput of all outbound streaming file transfers on a node  | `200`                                                       |
| `cassandra.inter_dc_stream_throughput_outbound_megabits_per_sec`                      | Throttle for all streaming file transfers between datacenters | `200`                                                       |
| `cassandra.phi_convict_threshold`        | Adjusts the sensitivity of the failure detector on an exponential scale. | `8`|
| `cassandra.jvm.heap_size`                   | DSE heap size                         |  `2G`    |
| `dse.max_solr_concurrent_per_core`                   |  Arguments                          |  `2`    |
| `dse.back_pressure_threshold_per_core`                   | The maximum number of queued partitions during search index rebuilding and reindexing                          |  `1000`    |
| `storage.cassandra.data.size`                   |  Arguments                         |  `15Gi`    |
| `storage.cassandra.logs.enable`                   |  Arguments                          |  `false`    |
| `storage.cassandra.logs.size`                   |  Arguments                          |  `10Gi`    |
| `storage.spark.enable`                   |  Arguments                          |  `false`    |
| `storage.spark.data.size`                   |  Arguments                          |  `15Gi`    |
| `storage.spark.logs.size`                   |  Arguments                          |  `10Gi`    |
| `storage.dsefs.enable`                   |  Arguments                          |  `false`    |
| `storage.dsefs.size`                   |  Arguments                          |  `10Gi`    |
| `resources.cpu`                   | CPU allocated to the Container                          |  `1000m`    |
| `resources.mem`                   | Memory allocated to the Container                          |  `4Gi`    |
| `nodeSelector`                   |  Arguments                          |  ``    |
| `tolerations`                   |  Arguments                          |  ``    |
| `affinity`                   |  Arguments                          |  ``    |

### Specify each parameter using the --set key=value,key=value argument to helm install.

## Scale Your DSE Cluster
When you want to scale the size of your DSE cluster, you would use the helm upgrade command
For example: 

```bash
helm upgrade --set cassandra.replicas=5 dse datastax-dse
```

When you scale be sure to pass the values previously passed with helm install.
For example: if you passed tag: 6.7.0 for your DSE version and a 3GB heap

```bash
helm upgrade --set cassandra.replicas=5,image.tag=6.7.0,cassandra.jvm.heap_size="3G" dse datastax-dse
```
