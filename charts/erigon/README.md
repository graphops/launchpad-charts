# Erigon Helm Chart

Deploy and scale [Erigon](https://github.com/ledgerwatch/erigon) inside Kubernetes with ease

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) ![Version: 0.12.4](https://img.shields.io/badge/Version-0.12.4-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v3.3.1](https://img.shields.io/badge/AppVersion-v3.3.1-informational?style=flat-square)

## Features

- Actively maintained by [GraphOps](https://graphops.xyz) [and contributors](https://github.com/graphops/launchpad-charts/graphs/contributors)
- Deploys a scalable pool of `rpcdaemon` instances, with auto-scaling support, for automatic elastic JSON-RPC
- Strong security defaults (non-root execution, ready-only root filesystem, drops all capabilities)
- Readiness checks to ensure traffic only hits `Pod`s that are healthy and ready to serve requests
- Support for `ServiceMonitor`s to configure Prometheus to scrape metrics ([prometheus-operator](https://github.com/prometheus-operator/prometheus-operator))
- Support for configuring Grafana dashboards for Erigon ([grafana](https://github.com/grafana/helm-charts/tree/main/charts/grafana))
- Support for exposing P2P via NodePort or LoadBalancer for inbound dials

## Quickstart

To install the chart with the release name `my-release`:

```console
$ helm repo add graphops http://graphops.github.io/launchpad-charts
$ helm install my-release graphops/erigon
```

Once the release is installed, Erigon will begin syncing. You can use `kubectl logs` to monitor the sync status. See the Values section to install Prometheus `ServiceMonitor`s and a Grafana dashboard.

JSON-RPC is available at `<release-name>-erigon-rpcdaemon:8545` by default.

## Specifying the Engine API JWT

To use Erigon on a network that requires a Consensus Client, you will need to configure a JWT that is used by the Consensus Client to authenticate with the Engine API on port `8551`. You will need to pass the same JWT to your Consensus Client.

You can specify the JWT for Erigon either as a literal value, or as a reference to a key in an existing Kubernetes Secret. If you specify a literal value, it will be wrapped into a new Kubernetes Secret and passed into the Erigon Pod.

Using a literal value:

```yaml
# values.yaml

statefulNode:
  jwt:
    fromLiteral: some-secure-random-value-that-you-generate # You can generate this with: openssl rand -hex 32
```

Using an existing Kubernetes Secret:

```yaml
# values.yaml

statefulNode:
  jwt:
    existingSecret:
      name: my-ethereum-mainnet-jwt-secret
      key: jwt
```

## JSON-RPC

### Built-in JSON-RPC

You can access JSON-RPC via the stateful node `Service` (`<release-name>-erigon-stateful-node`) on port `8545` by default.

Synchronous request performance is typically best when using the built-in JSON-RPC server, however for large throughput workloads you should use a scalable set of `rpcdaemon`s.

### Scalable `Deployment` of `rpcdaemon`s

For workloads where synchronous performance is less important than the scalability of request throughput, you should use a scalable `Deployment` of `rpcdaemon`s. In this mode, the number of `rpcdaemon`s can be scaled up. Each one connects to the stateful node process via its gRPC API. You can also use node selectors and other placement configuration to customise where `rpcdaemon`s are deployed within your cluster.

A dedicated `Service` (`<release-name>-erigon-rpcdaemon`) will be created to load balance JSON-RPC requests across `rpcdaemon` `Pod`s in the scalable `Deployment`. See the Values section to configure the `Deployment` and the number of replicas.

#### JSON-RPC Autoscaling

You can enable autoscaling for your scalable `Deployment` of `rpcdaemon`s. When enabled, the Chart will install a `HorizontalPodAutoscaler` into the cluster, which will manage the number of `rpcdaemon` replicas based on resource utilization.

If doing this, be sure to configure `rpcdaemon.resources.requests` with appropriate values, as the CPU and Memory utilization targets set in the autoscaling config are relative to the requested resource values.

## Enabling inbound P2P dials

By default, your Erigon node will not have an internet-accessible port for P2P traffic. This makes it harder to establish a strong set of peers because you cannot accept inbound P2P dials.

To expose P2P you can now use either NodePort or LoadBalancer:

- NodePort (legacy and default behavior when enabled): set `statefulNode.p2p.service.enabled=true` and `statefulNode.p2p.service.type=NodePort` (or `statefulNode.p2pNodePort.enabled=true` for backwards compatibility). This mode locks `statefulNode.replicaCount` to `1` and uses an initContainer to discover the Node's external IP for correct ENR advertisement.
- LoadBalancer: set `statefulNode.p2p.service.enabled=true` and `statefulNode.p2p.service.type=LoadBalancer`. You can add cloud-specific annotations via `statefulNode.p2p.service.annotations` and the P2P Service ports will match the container P2P flags.

Note: `statefulNode.p2pNodePort.*` remains supported for backwards compatibility, but `statefulNode.p2p.service.*` is preferred going forward.

```yaml
# values.yaml

statefulNode:
```

## Restoring chaindata from a snapshot

You can specify a snapshot URL that will be used to restore Erigon's `chaindata` state. When enabled, an init container will perform a streaming extraction of the snapshot into storage. The snapshot should be a gzipped tarball of `chaindata`.

Example:
```yaml
# values.yaml

statefulNode:
  restoreSnapshot:
    enable: true
    snapshotUrl: https://matic-blockchain-snapshots.s3-accelerate.amazonaws.com/matic-mainnet/erigon-archive-snapshot-2022-07-15.tar.gz
```

Once Erigon's state has been restored, the snapshot URL will be saved to storage at `/from_snapshot`. Any time the Erigon Pod starts, as long as the snapshot configuration has not changed, Erigon will boot with the existing state. If you modify the snapshot configuration, the init container will remove existing chaindata and restore state again.

You can monitor progress by following the logs of the `stateful-node-init` container: `kubectl logs --since 1m -f release-name-stateful-node-0 -c stateful-node-init`

## Upgrading

We recommend that you pin the version of the Chart that you deploy. You can use the `--version` flag with `helm install` and `helm upgrade` to specify a chart version constraint.

This project uses [Semantic Versioning](https://semver.org/). Changes to the version of the application (the `appVersion`) that the Chart deploys will generally result in a patch version bump for the Chart. Breaking changes to the Chart or its `values.yaml` interface will be reflected with a major version bump.

We do not recommend that you upgrade the application by overriding `image.tag`. Instead, use the version of the Chart that is built for your desired `appVersion`.

## Values

| Key | Description | Type | Default |
|-----|-------------|------|---------|
 | fullnameOverride |  | string | `""` |
 | grafana.dashboards | Enable creation of Grafana dashboards. [Grafana chart](https://github.com/grafana/helm-charts/tree/main/charts/grafana#grafana-helm-chart) must be configured to search this namespace, see `sidecar.dashboards.searchNamespace` | bool | `false` |
 | grafana.dashboardsConfigMapLabel | Must match `sidecar.dashboards.label` value for the [Grafana chart](https://github.com/grafana/helm-charts/tree/main/charts/grafana#grafana-helm-chart) | string | `"grafana_dashboard"` |
 | grafana.dashboardsConfigMapLabelValue | Must match `sidecar.dashboards.labelValue` value for the [Grafana chart](https://github.com/grafana/helm-charts/tree/main/charts/grafana#grafana-helm-chart) | string | `"1"` |
 | grafana.operatorDashboards | Create GrafanaDashboard CRDs via Grafana Operator from files in `dashboards/` | object | `{"allowCrossNamespaceImport":false,"annotations":{},"enabled":false,"extraSpec":{},"folder":"","folderUID":"","instanceSelector":{"matchLabels":{}},"labels":{},"namespace":"","resyncPeriod":"","suspend":false,"uid":""}` |
 | grafana.operatorDashboards.allowCrossNamespaceImport | Allow matching Grafana instances outside current namespace | bool | `false` |
 | grafana.operatorDashboards.extraSpec | Additional spec fields to merge into GrafanaDashboard.spec | object | `{}` |
 | grafana.operatorDashboards.folder | Optional folder metadata | string | `""` |
 | grafana.operatorDashboards.instanceSelector | Selector to match Grafana instances managed by the operator | object | `{"matchLabels":{}}` |
 | grafana.operatorDashboards.labels | Extra labels and annotations on the GrafanaDashboard resources | object | `{}` |
 | grafana.operatorDashboards.namespace | Optional target namespace for the GrafanaDashboard CRDs (defaults to release namespace) | string | `""` |
 | grafana.operatorDashboards.resyncPeriod | Operator sync behavior | string | `""` |
 | image.pullPolicy |  | string | `"IfNotPresent"` |
 | image.repository | Image for Erigon | string | `"docker.io/erigontech/erigon"` |
 | image.tag | Overrides the image tag | string | Chart.appVersion |
 | imagePullSecrets | Pull secrets required to fetch the Image | list | `[]` |
 | nameOverride |  | string | `""` |
 | prometheus.serviceMonitors.enabled | Enable monitoring by creating `ServiceMonitor` CRDs ([prometheus-operator](https://github.com/prometheus-operator/prometheus-operator)) | bool | `false` |
 | prometheus.serviceMonitors.interval |  | string | `nil` |
 | prometheus.serviceMonitors.labels |  | object | `{}` |
 | prometheus.serviceMonitors.relabelings |  | list | `[]` |
 | prometheus.serviceMonitors.scrapeTimeout |  | string | `nil` |
 | rbac.clusterRules | Required ClusterRole rules | list | See `values.yaml` |
 | rbac.create | Specifies whether RBAC resources are to be created | bool | `true` |
 | rbac.rules | Required ClusterRole rules | list | See `values.yaml` |
 | rpcdaemon.affinity |  | object | `{}` |
 | rpcdaemon.affinityPresets.antiAffinityByHostname | Configure anti-affinity rules to prevent multiple Erigon instances on the same host | bool | `true` |
 | rpcdaemon.autoscaling.enabled | Enable auto-scaling of the rpcdaemon Deployment. Be sure to set resources.requests for rpcdaemon. | bool | `false` |
 | rpcdaemon.autoscaling.maxReplicas | Maximum number of replicas | int | `10` |
 | rpcdaemon.autoscaling.minReplicas | Minimum number of replicas | int | `2` |
 | rpcdaemon.autoscaling.targetCPUUtilizationPercentage |  | int | `75` |
 | rpcdaemon.autoscaling.targetMemoryUtilizationPercentage |  | string | `nil` |
 | rpcdaemon.enabled | Enable a Deployment of rpcdaemon that can be scaled independently | bool | `true` |
 | rpcdaemon.extraArgs | Additional CLI arguments to pass to `rpcdaemon` | list | `[]` |
 | rpcdaemon.extraLabels | Extra labels to attach to the Pod for matching against | object | `{}` |
 | rpcdaemon.nodeSelector |  | object | `{}` |
 | rpcdaemon.podAnnotations | Annotations for the `Pod` | object | `{}` |
 | rpcdaemon.podSecurityContext | Pod-wide security context | object | `{"fsGroup":1000,"runAsGroup":1000,"runAsNonRoot":true,"runAsUser":1000}` |
 | rpcdaemon.replicaCount | Number of replicas to run | int | `2` |
 | rpcdaemon.resources.limits |  | object | `{}` |
 | rpcdaemon.resources.requests | Requests must be specified if you are using autoscaling | object | `{"cpu":"500m","memory":"4Gi"}` |
 | rpcdaemon.service.ports.http-jsonrpc | Service Port to expose rpcdaemon JSON-RPC interface on | int | `8545` |
 | rpcdaemon.service.ports.http-metrics | Service Port to expose Prometheus metrics on | int | `6061` |
 | rpcdaemon.service.type |  | string | `"ClusterIP"` |
 | rpcdaemon.tolerations |  | list | `[]` |
 | serviceAccount.annotations | Annotations to add to the service account | object | `{}` |
 | serviceAccount.create | Specifies whether a service account should be created | bool | `true` |
 | serviceAccount.name | The name of the service account to use. If not set and create is true, a name is generated using the fullname template | string | `""` |
 | statefulNode.affinity |  | object | `{}` |
 | statefulNode.affinityPresets.antiAffinityByHostname | Configure anti-affinity rules to prevent multiple Erigon instances on the same host | bool | `true` |
 | statefulNode.beaconApi | Beacon API configuration for erigon3 | object | `{"addr":"0.0.0.0","api":"beacon,builder,config,debug,events,node,lighthouse","blobsArchive":true,"blobsNoPruning":true,"blocksArchive":true,"corsAllowMethods":"*","corsAllowOrigins":"*","enabled":true,"port":5555}` |
 | statefulNode.beaconApi.addr | Beacon API address to bind to | string | `"0.0.0.0"` |
 | statefulNode.beaconApi.api | Comma-separated list of API namespaces to enable | string | `"beacon,builder,config,debug,events,node,lighthouse"` |
 | statefulNode.beaconApi.blobsArchive | Enable blobs archive | bool | `true` |
 | statefulNode.beaconApi.blobsNoPruning | Disable blobs pruning | bool | `true` |
 | statefulNode.beaconApi.blocksArchive | Enable blocks archive | bool | `true` |
 | statefulNode.beaconApi.corsAllowMethods | CORS allow methods | string | `"*"` |
 | statefulNode.beaconApi.corsAllowOrigins | CORS allow origins | string | `"*"` |
 | statefulNode.beaconApi.enabled | Enable Beacon API | bool | `true` |
 | statefulNode.beaconApi.port | Beacon API port to expose | int | `5555` |
 | statefulNode.datadir | The path to the Erigon data directory | string | `"/storage"` |
 | statefulNode.extraArgs | Additional CLI arguments to pass to `erigon` | list | `[]` |
 | statefulNode.extraContainers | Additional containers to inject to this graph node group - an array of Container objects | list | `[]` |
 | statefulNode.extraInitContainers | Additional init containers to inject to this graph node group - an array of Container objects | list | `[]` |
 | statefulNode.extraLabels | Extra labels to attach to the Pod for matching against | object | `{}` |
 | statefulNode.jwt | JWT for clients to authenticate with the Engine API. Specify either `existingSecret` OR `fromLiteral`. | object | `{"existingSecret":{"key":null,"name":null},"fromLiteral":null}` |
 | statefulNode.jwt.existingSecret | Load the JWT from an existing Kubernetes Secret. Takes precedence over `fromLiteral` if set. | object | `{"key":null,"name":null}` |
 | statefulNode.jwt.existingSecret.key | Data key for the JWT in the Secret | string | `nil` |
 | statefulNode.jwt.existingSecret.name | Name of the Secret resource in the same namespace | string | `nil` |
 | statefulNode.jwt.fromLiteral | Use this literal value for the JWT | string | `nil` |
 | statefulNode.livenessProbe | Sets a livenessProbe configuration for the container | object | `{}` |
 | statefulNode.nodeSelector |  | object | `{}` |
 | statefulNode.p2p.allowedPorts | Two explicit P2P ports to allow (protocol 68,67). Services and container ports will match these.    If not set, defaults to [30303, 30304]. | list | `[30303,30304]` |
 | statefulNode.p2p.service.advertiseIP | IP address to explicitly advertise on the P2P network (overrides autodetection and LB IP) | string | `""` |
 | statefulNode.p2p.service.annotations | Annotations to add to the P2P Service (useful for cloud LBs) | object | `{}` |
 | statefulNode.p2p.service.enabled | Enable creation of a P2P Service | bool | `false` |
 | statefulNode.p2p.service.externalIPs | Fixed external IPs to bind the P2P Service to (NodePort or LoadBalancer); requires upstream routing | list | `[]` |
 | statefulNode.p2p.service.externalTrafficPolicy | External traffic policy for NodePort/LoadBalancer | string | `"Local"` |
 | statefulNode.p2p.service.initContainer | override initContainer image used in NodePort mode | Advanced | `{"image":{"pullPolicy":"IfNotPresent","repository":"lachlanevenson/k8s-kubectl","tag":"v1.25.4"}}` |
 | statefulNode.p2p.service.labels | Additional labels to add to the P2P Service | object | `{}` |
 | statefulNode.p2p.service.loadBalancerIP | When using a LoadBalancer and your cloud supports it, reserve a specific IP | string | `""` |
 | statefulNode.p2p.service.loadBalancerSourceRanges | Restrict which source ranges can access the LoadBalancer (CIDRs) | list | `[]` |
 | statefulNode.p2p.service.nodePort | When type is NodePort, base nodePort to use (port and port+1 are used) | object | `{"base":31000}` |
 | statefulNode.p2p.service.publishNotReadyAddresses | Toggle publishing not ready addresses for p2p service | bool | `false` |
 | statefulNode.p2p.service.type | Service type for P2P exposure (NodePort or LoadBalancer) | string | `"NodePort"` |
 | statefulNode.p2pNodePort.enabled | Expose P2P port via NodePort | bool | `false` |
 | statefulNode.p2pNodePort.initContainer.image.pullPolicy | Container pull policy | string | `"IfNotPresent"` |
 | statefulNode.p2pNodePort.initContainer.image.repository | Container image to fetch nodeport information | string | `"lachlanevenson/k8s-kubectl"` |
 | statefulNode.p2pNodePort.initContainer.image.tag | Container tag | string | `"v1.25.4"` |
 | statefulNode.p2pNodePort.port | Start NodePort to be used in a range (2 ports for protocol versions 68 and 67). Must be unique. | int | `31000` |
 | statefulNode.podAnnotations | Annotations for the `Pod` | object | `{}` |
 | statefulNode.podSecurityContext | Pod-wide security context | object | `{"fsGroup":1000,"runAsGroup":1000,"runAsNonRoot":true,"runAsUser":1000}` |
 | statefulNode.privateApi.ratelimit |  | int | `31872` |
 | statefulNode.pruneMode | Sets the pruning mode to use (archive, validator, full) | string | `"archive"` |
 | statefulNode.readinessProbe | Sets a readinessProbe configuration for the container | object | `{}` |
 | statefulNode.resources |  | object | `{}` |
 | statefulNode.rollingUpdatePartition | When using a RollingUpdate update strategy in the StatefulSet, sets a partition index to only update PODs with that index or higher | int | `0` |
 | statefulNode.rpc.batch.concurrency |  | int | `2` |
 | statefulNode.rpc.batch.limit |  | int | `100` |
 | statefulNode.service.ports.grpc-erigon | Service Port to expose Erigon GRPC interface on | int | `9090` |
 | statefulNode.service.ports.http-beaconapi | Service Port to expose Beacon API interface on | int | `5555` |
 | statefulNode.service.ports.http-engineapi | Service Port to expose engineAPI interface on | int | `8551` |
 | statefulNode.service.ports.http-jsonrpc | Service Port to expose JSON-RPC interface on | int | `8545` |
 | statefulNode.service.ports.http-metrics | Service Port to expose Prometheus metrics on | int | `6061` |
 | statefulNode.service.ports.ws-rpc | Service Port to expose WS-RPC interface on | int | `8546` |
 | statefulNode.service.publishNotReadyAddresses.headless | Toggle publishing not ready addresses for headless service | bool | `false` |
 | statefulNode.service.publishNotReadyAddresses.p2p | Toggle publishing not ready addresses for p2p service | bool | `false` |
 | statefulNode.service.topologyAwareRouting.enabled | Toggle for topology aware routing | bool | `false` |
 | statefulNode.service.type |  | string | `"ClusterIP"` |
 | statefulNode.startupProbe | Sets a startupProbe configuration for the container | object | `{}` |
 | statefulNode.terminationGracePeriodSeconds | Amount of time to wait before force-killing the Erigon process | int | `60` |
 | statefulNode.tolerations |  | list | `[]` |
 | statefulNode.updateStrategyType | Choice of StatefulSet updateStrategy (OnDelete|RollingUpdate) | string | `"RollingUpdate"` |
 | statefulNode.volumeClaimSpec | [PersistentVolumeClaimSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.23/#persistentvolumeclaimspec-v1-core) for Erigon storage | object | `{"accessModes":["ReadWriteOnce"],"resources":{"requests":{"storage":"3Ti"}},"storageClassName":null}` |
 | statefulNode.volumeClaimSpec.resources.requests.storage | The amount of disk space to provision for Erigon | string | `"3Ti"` |
 | statefulNode.volumeClaimSpec.storageClassName | The storage class to use when provisioning a persistent volume for Erigon | string | `nil` |

## Contributing

We welcome and appreciate your contributions! Please see the [Contributor Guide](/CONTRIBUTING.md), [Code Of Conduct](/CODE_OF_CONDUCT.md) and [Security Notes](/SECURITY.md) for this repository.
