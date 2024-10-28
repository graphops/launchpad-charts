# Erigon Helm Chart

Deploy and scale [Erigon](https://github.com/ledgerwatch/erigon) inside Kubernetes with ease

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) ![Version: 0.10.7](https://img.shields.io/badge/Version-0.10.7-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 2.60.8](https://img.shields.io/badge/AppVersion-2.60.8-informational?style=flat-square)

## Features

- Actively maintained by [GraphOps](https://graphops.xyz) [and contributors](https://github.com/graphops/launchpad-charts/graphs/contributors)
- Deploys a scalable pool of `rpcdaemon` instances, with auto-scaling support, for automatic elastic JSON-RPC
- Strong security defaults (non-root execution, ready-only root filesystem, drops all capabilities)
- Readiness checks to ensure traffic only hits `Pod`s that are healthy and ready to serve requests
- Support for `ServiceMonitor`s to configure Prometheus to scrape metrics ([prometheus-operator](https://github.com/prometheus-operator/prometheus-operator))
- Support for configuring Grafana dashboards for Erigon ([grafana](https://github.com/grafana/helm-charts/tree/main/charts/grafana))
- Support for exposing a NodePort to enable inbound P2P dials for better peering

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

By default, your Erigon node will not have an internet-accessible port for P2P traffic. This makes it harder for your node to establish a strong set of peers because you cannot accept inbound P2P dials. To change this behaviour, you can set `statefulNode.p2pNodePort.enabled` to `true`. This will make your node accessible via the Internet using a `Service` of type `NodePort`. When using `statefulNode.p2pNodePort.enabled`, the exposed IP address on your Erigon ENR record will be the "External IP" of the Node where the Pod is running. When using this mode, `statefulNode.replicaCount` will be locked to `1`.

```yaml
# values.yaml

statefulNode:
  p2pNodePort:
    enabled: true
    port: 31000 # Must be globally unique and available on the host
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
 | image.pullPolicy |  | string | `"IfNotPresent"` |
 | image.repository | Image for Erigon | string | `"thorax/erigon"` |
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
 | rpcdaemon.podSecurityContext | Pod-wide security context | object | `{"fsGroup":101337,"runAsGroup":101337,"runAsNonRoot":true,"runAsUser":101337}` |
 | rpcdaemon.replicaCount | Number of replicas to run | int | `2` |
 | rpcdaemon.resources.limits |  | object | `{}` |
 | rpcdaemon.resources.requests | Requests must be specified if you are using autoscaling | object | `{"cpu":"500m","memory":"4Gi"}` |
 | rpcdaemon.service.ports.http-jsonrpc | Service Port to expose rpcdaemon JSON-RPC interface on | int | `8545` |
 | rpcdaemon.service.ports.http-metrics | Service Port to expose Prometheus metrics on | int | `6060` |
 | rpcdaemon.service.type |  | string | `"ClusterIP"` |
 | rpcdaemon.tolerations |  | list | `[]` |
 | serviceAccount.annotations | Annotations to add to the service account | object | `{}` |
 | serviceAccount.create | Specifies whether a service account should be created | bool | `true` |
 | serviceAccount.name | The name of the service account to use. If not set and create is true, a name is generated using the fullname template | string | `""` |
 | statefulNode.affinity |  | object | `{}` |
 | statefulNode.affinityPresets.antiAffinityByHostname | Configure anti-affinity rules to prevent multiple Erigon instances on the same host | bool | `true` |
 | statefulNode.extraArgs | Additional CLI arguments to pass to `erigon` | list | `[]` |
 | statefulNode.extraLabels | Extra labels to attach to the Pod for matching against | object | `{}` |
 | statefulNode.jwt | JWT for clients to authenticate with the Engine API. Specify either `existingSecret` OR `fromLiteral`. | object | `{"existingSecret":{"key":null,"name":null},"fromLiteral":null}` |
 | statefulNode.jwt.existingSecret | Load the JWT from an existing Kubernetes Secret. Takes precedence over `fromLiteral` if set. | object | `{"key":null,"name":null}` |
 | statefulNode.jwt.existingSecret.key | Data key for the JWT in the Secret | string | `nil` |
 | statefulNode.jwt.existingSecret.name | Name of the Secret resource in the same namespace | string | `nil` |
 | statefulNode.jwt.fromLiteral | Use this literal value for the JWT | string | `nil` |
 | statefulNode.nodeSelector |  | object | `{}` |
 | statefulNode.p2pNodePort.enabled | Expose P2P port via NodePort | bool | `false` |
 | statefulNode.p2pNodePort.initContainer.image.pullPolicy | Container pull policy | string | `"IfNotPresent"` |
 | statefulNode.p2pNodePort.initContainer.image.repository | Container image to fetch nodeport information | string | `"lachlanevenson/k8s-kubectl"` |
 | statefulNode.p2pNodePort.initContainer.image.tag | Container tag | string | `"v1.25.4"` |
 | statefulNode.p2pNodePort.port | NodePort to be used. Must be unique. | int | `31000` |
 | statefulNode.podAnnotations | Annotations for the `Pod` | object | `{}` |
 | statefulNode.podSecurityContext | Pod-wide security context | object | `{"fsGroup":101337,"runAsGroup":101337,"runAsNonRoot":true,"runAsUser":101337}` |
 | statefulNode.resources |  | object | `{}` |
 | statefulNode.restoreSnapshot.enabled | Enable initialising Erigon state from a remote snapshot | bool | `false` |
 | statefulNode.restoreSnapshot.snapshotUrl | URL for snapshot to download and extract to restore state | string | `""` |
 | statefulNode.service.ports.grpc-erigon | Service Port to expose Erigon GRPC interface on | int | `9090` |
 | statefulNode.service.ports.http-engineapi | Service Port to expose engineAPI interface on | int | `8551` |
 | statefulNode.service.ports.http-jsonrpc | Service Port to expose JSON-RPC interface on | int | `8545` |
 | statefulNode.service.ports.http-metrics | Service Port to expose Prometheus metrics on | int | `6060` |
 | statefulNode.service.ports.ws-rpc | Service Port to expose WS-RPC interface on | int | `8546` |
 | statefulNode.service.topologyAwareRouting.enabled |  | bool | `false` |
 | statefulNode.service.type |  | string | `"ClusterIP"` |
 | statefulNode.terminationGracePeriodSeconds | Amount of time to wait before force-killing the Erigon process | int | `60` |
 | statefulNode.tolerations |  | list | `[]` |
 | statefulNode.volumeClaimSpec | [PersistentVolumeClaimSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.23/#persistentvolumeclaimspec-v1-core) for Erigon storage | object | `{"accessModes":["ReadWriteOncePod"],"resources":{"requests":{"storage":"3Ti"}},"storageClassName":null}` |
 | statefulNode.volumeClaimSpec.resources.requests.storage | The amount of disk space to provision for Erigon | string | `"3Ti"` |
 | statefulNode.volumeClaimSpec.storageClassName | The storage class to use when provisioning a persistent volume for Erigon | string | `nil` |

## Contributing

We welcome and appreciate your contributions! Please see the [Contributor Guide](/CONTRIBUTING.md), [Code Of Conduct](/CODE_OF_CONDUCT.md) and [Security Notes](/SECURITY.md) for this repository.
