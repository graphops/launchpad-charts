# Arbitrum-Nitro Helm Chart

Deploy and scale [Arbitrum-Nitro](https://github.com/OffchainLabs/nitro/) inside Kubernetes with ease

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) ![Version: 0.6.0](https://img.shields.io/badge/Version-0.6.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v3.5.2-33d30c0](https://img.shields.io/badge/AppVersion-v3.5.2--33d30c0-informational?style=flat-square)

## Features

- Actively maintained by [GraphOps](https://graphops.xyz) [and contributors](https://github.com/graphops/launchpad-charts/graphs/contributors)
- Deploys a scalable pool of `rpcdaemon` instances, with auto-scaling support, for automatic elastic JSON-RPC
- Strong security defaults (non-root execution, ready-only root filesystem, drops all capabilities)
- Readiness checks to ensure traffic only hits `Pod`s that are healthy and ready to serve requests
- Support for `ServiceMonitor`s to configure Prometheus to scrape metrics ([prometheus-operator](https://github.com/prometheus-operator/prometheus-operator))
- Support for configuring Grafana dashboards for arbitrum ([grafana](https://github.com/grafana/helm-charts/tree/main/charts/grafana))
- Support for exposing a NodePort to enable inbound P2P dials for better peering

## Quickstart

To install the chart with the release name `my-release`:

```console
$ helm repo add graphops http://graphops.github.io/launchpad-charts
$ helm install my-release graphops/arbitrum-nitro
```

Once the release is installed, arbitrum will begin syncing. You can use `kubectl logs` to monitor the sync status. See the Values section to install Prometheus `ServiceMonitor`s and a Grafana dashboard.

JSON-RPC is available at `<release-name>:8545` by default.

## JSON-RPC

### Built-in JSON-RPC

You can access JSON-RPC via the stateful node `Service` (`<release-name>`) on port `8545` by default.

Synchronous request performance is typically best when using the built-in JSON-RPC server, however for large throughput workloads you should use a scalable set of `rpcdaemon`s.

#### JSON-RPC Autoscaling

You can enable autoscaling for your scalable `Deployment` of `rpcdaemon`s. When enabled, the Chart will install a `HorizontalPodAutoscaler` into the cluster, which will manage the number of `rpcdaemon` replicas based on resource utilization.

If doing this, be sure to configure `rpcdaemon.resources.requests` with appropriate values, as the CPU and Memory utilization targets set in the autoscaling config are relative to the requested resource values.

## Enabling inbound P2P dials

By default, your arbitrum node will not have an internet-accessible port for P2P traffic. This makes it harder for your node to establish a strong set of peers because you cannot accept inbound P2P dials. To change this behaviour, you can set `statefulNode.p2pNodePort.enabled` to `true`. This will make your node accessible via the Internet using a `Service` of type `NodePort`. When using `statefulNode.p2pNodePort.enabled`, the exposed IP address on your arbitrum ENR record will be the "External IP" of the Node where the Pod is running. When using this mode, `statefulNode.replicaCount` will be locked to `1`.

```yaml
# values.yaml

nitro:
  p2pNodePort:
    enabled: true
    port: 31000 # Must be globally unique and available on the host
```

## Restoring chaindata from a snapshot

You can specify a snapshot URL that will be used to restore nitro's `chaindata` state.

Example:
```yaml
# values.yaml

nitro:
  extraArgs:
    - --initsnapshotUrl: https://snapshot.arbitrum.io/mainnet/nitro.tar
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
 | fullnameOverride |  | string | `""` |
 | grafana.dashboards | Enable creation of Grafana dashboards. [Grafana chart](https://github.com/grafana/helm-charts/tree/main/charts/grafana#grafana-helm-chart) must be configured to search this namespace, see `sidecar.dashboards.searchNamespace` | bool | `false` |
 | grafana.dashboardsConfigMapLabel | Must match `sidecar.dashboards.label` value for the [Grafana chart](https://github.com/grafana/helm-charts/tree/main/charts/grafana#grafana-helm-chart) | string | `"grafana_dashboard"` |
 | grafana.dashboardsConfigMapLabelValue | Must match `sidecar.dashboards.labelValue` value for the [Grafana chart](https://github.com/grafana/helm-charts/tree/main/charts/grafana#grafana-helm-chart) | string | `"1"` |
 | image.pullPolicy |  | string | `"IfNotPresent"` |
 | image.repository | Image for arbitrum | string | `"offchainlabs/nitro-node"` |
 | image.tag | Overrides the image tag | string | Chart.appVersion |
 | imagePullSecrets | Pull secrets required to fetch the Image | list | `[]` |
 | nameOverride |  | string | `""` |
 | nitro.affinity |  | object | `{}` |
 | nitro.affinityPresets.antiAffinityByHostname | Configure anti-affinity rules to prevent multiple arbitrum instances on the same host | bool | `true` |
 | nitro.config | Nitro configuration parameters | object | `{"chain":42161,"classicUrl":null,"defaultArgs":["--execution.caching.archive"],"extraArgs":[],"httpRpc":{"addr":"0.0.0.0","api":"net,web3,eth,debug","cors":"*","vhosts":"*"},"metrics":{"addr":"0.0.0.0","enabled":true},"parentChainBeaconUrl":"CHANGE_ME_BEACON_URL","parentChainUrl":"CHANGE_ME_RPC_URL"}` |
 | nitro.config.chain | Chain ID, 42161 for Arbitrum One | int | `42161` |
 | nitro.config.classicUrl | RPC Url to Arbitrum Classic Archive node if serving classic blocks | string | `nil` |
 | nitro.config.defaultArgs | Enabled default arguments on the chart | list | `["--execution.caching.archive"]` |
 | nitro.config.extraArgs | Additional CLI arguments to pass to `nitro` | list | `[]` |
 | nitro.config.httpRpc | RPC config parameters | object | `{"addr":"0.0.0.0","api":"net,web3,eth,debug","cors":"*","vhosts":"*"}` |
 | nitro.config.httpRpc.addr | Listen address | string | `"0.0.0.0"` |
 | nitro.config.httpRpc.api | Enabled APIs | string | `"net,web3,eth,debug"` |
 | nitro.config.httpRpc.cors | Allowed CORS domains | string | `"*"` |
 | nitro.config.httpRpc.vhosts | Allowed vhosts | string | `"*"` |
 | nitro.config.metrics | Metrics parameters | object | `{"addr":"0.0.0.0","enabled":true}` |
 | nitro.config.metrics.addr | Listen address | string | `"0.0.0.0"` |
 | nitro.config.metrics.enabled | Enable metrics | bool | `true` |
 | nitro.config.parentChainBeaconUrl | Beacon URL to L1 chain (ethereum) | string | `"CHANGE_ME_BEACON_URL"` |
 | nitro.config.parentChainUrl | RPC URL to L1 chain (ethereum) | string | `"CHANGE_ME_RPC_URL"` |
 | nitro.extraLabels | Extra labels to attach to the Pod for matching against | object | `{}` |
 | nitro.nodeSelector |  | object | `{}` |
 | nitro.podAnnotations | Annotations for the `Pod` | object | `{}` |
 | nitro.podSecurityContext | Pod-wide security context | object | `{"fsGroup":101337,"runAsGroup":101337,"runAsNonRoot":true,"runAsUser":101337}` |
 | nitro.resources |  | object | `{}` |
 | nitro.restoreSnapshot.chunkSize | Size of chunks for chunked downloading. Too small hurts performance, too big leads to more waste when it needs to be retried | int | `1000000000` |
 | nitro.restoreSnapshot.cleanSubpath | Erase destination path before unpacking | bool | `true` |
 | nitro.restoreSnapshot.enabled | Enable initialising arbitrum state from a remote snapshot | bool | `false` |
 | nitro.restoreSnapshot.extraTarArgs | A string with extra arguments to tar command (i.e. "--strip-components=1") | string | `nil` |
 | nitro.restoreSnapshot.snapshotUrl | URL for snapshot to download and extract to restore state | string | `"https://snapshot.arbitrum.foundation/arb1/nitro-archive.tar"` |
 | nitro.restoreSnapshot.subpath | Path where the snapshot should be unpacked to, relative to the volume root | string | `"data/nitro"` |
 | nitro.service.ports.http-metrics | Service Port to expose Prometheus metrics on | int | `6070` |
 | nitro.service.ports.http-rpc | Service Port to expose JSON-RPC interface on | int | `8547` |
 | nitro.service.ports.ws-rpc | Service Port to expose WebSockets interface on | int | `8548` |
 | nitro.service.topologyAwareRouting.enabled |  | bool | `false` |
 | nitro.service.type |  | string | `"ClusterIP"` |
 | nitro.terminationGracePeriodSeconds | Amount of time to wait before force-killing the arbitrum process | int | `60` |
 | nitro.tolerations |  | list | `[]` |
 | nitro.volumeClaimSpec | [PersistentVolumeClaimSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.23/#persistentvolumeclaimspec-v1-core) for arbitrum storage | object | `{"accessModes":["ReadWriteOnce"],"resources":{"requests":{"storage":"8Ti"}},"storageClassName":null}` |
 | nitro.volumeClaimSpec.resources.requests.storage | The amount of disk space to provision for arbitrum | string | `"8Ti"` |
 | nitro.volumeClaimSpec.storageClassName | The storage class to use when provisioning a persistent volume for arbitrum | string | `nil` |
 | prometheus.serviceMonitors.enabled | Enable monitoring by creating `ServiceMonitor` CRDs ([prometheus-operator](https://github.com/prometheus-operator/prometheus-operator)) | bool | `false` |
 | prometheus.serviceMonitors.interval |  | string | `nil` |
 | prometheus.serviceMonitors.labels |  | object | `{}` |
 | prometheus.serviceMonitors.metricRelabelings |  | list | `[]` |
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
