# Arbitrum-Classic Helm Chart

Deploy and scale [Arbitrum-Classic](https://github.com/OffchainLabs/arbitrum) inside Kubernetes with ease

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) ![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v1.4.5-e97c1a4](https://img.shields.io/badge/AppVersion-v1.4.5--e97c1a4-informational?style=flat-square)

## Features

- Actively maintained by [GraphOps](https://graphops.xyz) [and contributors](https://github.com/graphops/helm-charts/graphs/contributors)
- Deploys a scalable pool of `rpcdaemon` instances, with auto-scaling support, for automatic elastic JSON-RPC
- Strong security defaults (non-root execution, ready-only root filesystem, drops all capabilities)
- Readiness checks to ensure traffic only hits `Pod`s that are healthy and ready to serve requests
- Support for `ServiceMonitor`s to configure Prometheus to scrape metrics ([prometheus-operator](https://github.com/prometheus-operator/prometheus-operator))
- Support for configuring Grafana dashboards for arbitrum ([grafana](https://github.com/grafana/helm-charts/tree/main/charts/grafana))
- Support for exposing a NodePort to enable inbound P2P dials for better peering

## Quickstart

To install the chart with the release name `my-release`:

```console
$ helm repo add graphops http://graphops.github.io/helm-charts
$ helm install my-release graphops/arbitrum-classic
```

Once the release is installed, arbitrum will begin syncing. You can use `kubectl logs` to monitor the sync status. See the Values section to install Prometheus `ServiceMonitor`s and a Grafana dashboard.

JSON-RPC is available at `<release-name>-arbitrum-rpcdaemon:8545` by default.

## Specifying the Engine API JWT

To use arbitrum on a network that requires a Consensus Client, you will need to configure a JWT that is used by the Consensus Client to authenticate with the Engine API on port `8551`. You will need to pass the same JWT to your Consensus Client.

You can specify the JWT for arbitrum either as a literal value, or as a reference to a key in an existing Kubernetes Secret. If you specify a literal value, it will be wrapped into a new Kubernetes Secret and passed into the arbitrum Pod.

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

You can access JSON-RPC via the stateful node `Service` (`<release-name>-arbitrum-nitro`) on port `8545` by default.

Synchronous request performance is typically best when using the built-in JSON-RPC server, however for large throughput workloads you should use a scalable set of `rpcdaemon`s.

### Scalable `Deployment` of `rpcdaemon`s

For workloads where synchronous performance is less important than the scalability of request throughput, you should use a scalable `Deployment` of `rpcdaemon`s. In this mode, the number of `rpcdaemon`s can be scaled up. Each one connects to the stateful node process via its gRPC API. You can also use node selectors and other placement configuration to customise where `rpcdaemon`s are deployed within your cluster.

A dedicated `Service` (`<release-name>-arbitrum-rpcdaemon`) will be created to load balance JSON-RPC requests across `rpcdaemon` `Pod`s in the scalable `Deployment`. See the Values section to configure the `Deployment` and the number of replicas.

#### JSON-RPC Autoscaling

You can enable autoscaling for your scalable `Deployment` of `rpcdaemon`s. When enabled, the Chart will install a `HorizontalPodAutoscaler` into the cluster, which will manage the number of `rpcdaemon` replicas based on resource utilization.

If doing this, be sure to configure `rpcdaemon.resources.requests` with appropriate values, as the CPU and Memory utilization targets set in the autoscaling config are relative to the requested resource values.

## Enabling inbound P2P dials

By default, your arbitrum node will not have an internet-accessible port for P2P traffic. This makes it harder for your node to establish a strong set of peers because you cannot accept inbound P2P dials. To change this behaviour, you can set `statefulNode.p2pNodePort.enabled` to `true`. This will make your node accessible via the Internet using a `Service` of type `NodePort`. When using `statefulNode.p2pNodePort.enabled`, the exposed IP address on your arbitrum ENR record will be the "External IP" of the Node where the Pod is running. When using this mode, `statefulNode.replicaCount` will be locked to `1`.

```yaml
# values.yaml

statefulNode:
  p2pNodePort:
    enabled: true
    port: 31000 # Must be globally unique and available on the host
```

## Restoring chaindata from a snapshot

You can specify a snapshot URL that will be used to restore arbitrum's `chaindata` state. When enabled, an init container will perform a streaming extraction of the snapshot into storage. The snapshot should be a gzipped tarball of `chaindata`.

Example:
```yaml
# values.yaml

statefulNode:
  restoreSnapshot:
    enable: true
    snapshotUrl: https://matic-blockchain-snapshots.s3-accelerate.amazonaws.com/matic-mainnet/arbitrum-archive-snapshot-2022-07-15.tar.gz
```

Once arbitrum's state has been restored, the snapshot URL will be saved to storage at `/from_snapshot`. Any time the arbitrum Pod starts, as long as the snapshot configuration has not changed, arbitrum will boot with the existing state. If you modify the snapshot configuration, the init container will remove existing chaindata and restore state again.

You can monitor progress by following the logs of the `nitro-init` container: `kubectl logs --since 1m -f release-name-nitro-0 -c nitro-init`

## Upgrading

We recommend that you pin the version of the Chart that you deploy. You can use the `--version` flag with `helm install` and `helm upgrade` to specify a chart version constraint.

This project uses [Semantic Versioning](https://semver.org/). Changes to the version of the application (the `appVersion`) that the Chart deploys will generally result in a patch version bump for the Chart. Breaking changes to the Chart or its `values.yaml` interface will be reflected with a major version bump.

We do not recommend that you upgrade the application by overriding `image.tag`. Instead, use the version of the Chart that is built for your desired `appVersion`.

## Values

| Key | Description | Type | Default |
|-----|-------------|------|---------|
 | arbitrum.affinity |  | object | `{}` |
 | arbitrum.affinityPresets.antiAffinityByHostname | Configure anti-affinity rules to prevent multiple arbitrum instances on the same host | bool | `true` |
 | arbitrum.extraArgs | Additional CLI arguments to pass to `arbitrum` | list | `["--node.chain-id=42161","--l1.url=http://erigon-archive-trace-eth-mainnet-0-rpcdaemon.eth-mainnet:8545"]` |
 | arbitrum.extraLabels | Extra labels to attach to the Pod for matching against | object | `{}` |
 | arbitrum.nodeSelector |  | object | `{}` |
 | arbitrum.p2pNodePort.enabled | Expose P2P port via NodePort | bool | `false` |
 | arbitrum.p2pNodePort.initContainer.image.pullPolicy | Container pull policy | string | `"IfNotPresent"` |
 | arbitrum.p2pNodePort.initContainer.image.repository | Container image to fetch nodeport information | string | `"lachlanevenson/k8s-kubectl"` |
 | arbitrum.p2pNodePort.initContainer.image.tag | Container tag | string | `"v1.21.3"` |
 | arbitrum.p2pNodePort.port | NodePort to be used. Must be unique. | int | `31000` |
 | arbitrum.podAnnotations | Annotations for the `Pod` | object | `{}` |
 | arbitrum.podSecurityContext | Pod-wide security context | object | `{"fsGroup":101337,"runAsGroup":101337,"runAsNonRoot":true,"runAsUser":101337}` |
 | arbitrum.resources |  | object | `{}` |
 | arbitrum.restoreSnapshot.enabled | Enable initialising arbitrum state from a remote snapshot | bool | `false` |
 | arbitrum.restoreSnapshot.snapshotUrl | URL for snapshot to download and extract to restore state | string | `"https://snapshot.arbitrum.io/mainnet/db.tar"` |
 | arbitrum.service.ports.http-jsonrpc | Service Port to expose JSON-RPC interface on | int | `8547` |
 | arbitrum.service.ports.http-metrics | Service Port to expose Prometheus metrics on | int | `6070` |
 | arbitrum.service.ports.http-rpc | Service Port to expose engineAPI interface on | int | `9656` |
 | arbitrum.service.ports.ws |  | int | `8548` |
 | arbitrum.service.type |  | string | `"ClusterIP"` |
 | arbitrum.terminationGracePeriodSeconds | Amount of time to wait before force-killing the arbitrum process | int | `60` |
 | arbitrum.tolerations |  | list | `[]` |
 | arbitrum.volumeClaimSpec | [PersistentVolumeClaimSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.23/#persistentvolumeclaimspec-v1-core) for arbitrum storage | object | `{"accessModes":["ReadWriteOnce"],"resources":{"requests":{"storage":"3Ti"}},"storageClassName":null}` |
 | arbitrum.volumeClaimSpec.resources.requests.storage | The amount of disk space to provision for arbitrum | string | `"3Ti"` |
 | arbitrum.volumeClaimSpec.storageClassName | The storage class to use when provisioning a persistent volume for arbitrum | string | `nil` |
 | fullnameOverride |  | string | `""` |
 | grafana.dashboards | Enable creation of Grafana dashboards. [Grafana chart](https://github.com/grafana/helm-charts/tree/main/charts/grafana#grafana-helm-chart) must be configured to search this namespace, see `sidecar.dashboards.searchNamespace` | bool | `false` |
 | grafana.dashboardsConfigMapLabel | Must match `sidecar.dashboards.label` value for the [Grafana chart](https://github.com/grafana/helm-charts/tree/main/charts/grafana#grafana-helm-chart) | string | `"grafana_dashboard"` |
 | grafana.dashboardsConfigMapLabelValue | Must match `sidecar.dashboards.labelValue` value for the [Grafana chart](https://github.com/grafana/helm-charts/tree/main/charts/grafana#grafana-helm-chart) | string | `"1"` |
 | image.pullPolicy |  | string | `"IfNotPresent"` |
 | image.repository |  | string | `"offchainlabs/arb-node"` |
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
 | serviceAccount.annotations | Annotations to add to the service account | object | `{}` |
 | serviceAccount.create | Specifies whether a service account should be created | bool | `true` |
 | serviceAccount.name | The name of the service account to use. If not set and create is true, a name is generated using the fullname template | string | `""` |

## Contributing

We welcome and appreciate your contributions! Please see the [Contributor Guide](/CONTRIBUTING.md), [Code Of Conduct](/CODE_OF_CONDUCT.md) and [Security Notes](/SECURITY.md) for this repository.
