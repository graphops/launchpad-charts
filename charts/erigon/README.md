

# Erigon Helm Chart

Deploy and scale [Erigon](https://github.com/ledgerwatch/erigon) inside Kubernetes with ease

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) ![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v2022.04.02](https://img.shields.io/badge/AppVersion-v2022.04.02-informational?style=flat-square)

## Features

- Actively maintained by [GraphOps](https://graphops.xyz) and contributors
- Supports deploying a `rpcdaemon` sidecar within the `Pod` that contains the stateful `erigon` container, enabling shared state access and higher performance for the sidecar `rpcdaemon`
- Supports an independent pool of `rpcdaemon` instances, with auto-scaling support, for automatic elastic JSON-RPC
- Strong security defaults (non-root execution, ready-only root filesystem, drops all capabilities)
- Readiness checks to ensure traffic only hits `Pod`s that are healthy and ready to serve requests
- Support for `PodMonitor`s to configure Prometheus to scrape metrics ([prometheus-operator](https://github.com/prometheus-operator/prometheus-operator))
- Support for configuring Grafana dashboards for Erigon ([grafana](https://github.com/grafana/helm-charts/tree/main/charts/grafana))

## Quickstart

To install the chart with the release name `my-release`:

```console
$ helm repo add graphops http://graphops.github.io/charts
$ helm install my-release graphops/erigon
```

## JSON-RPC

### High-performance sidecar

You can enable the deployment of an `rpcdaemon` instance as a sidecar within the stateful Erigon `Pod`. In this mode, the `rpcdaemon` shares a PID namespace with the `erigon` process and can access the node state database directly, cutting out the gRPC API and improving synchronous request performance.

When enabled, you can access the JSON-RPC API via the stateful node `Service` on port `8545` by default. See the Values section to enable and configure the sidecar.

### Scalable `Deployment`

For workloads where synchronous performance is less important than the scalability of request throughput, you can enable an independent scalable `Deployment` of `rpcdaemon`s. In this mode, the `rpcdaemon`s can be scaled up arbitrarily and connect to the stateful node process via the gRPC API. You can also use node selectors and other placement configuration to customise where `rpcdaemon`s are deployed within your cluster.

When enabled, a dedicated `Service` will be created to load balance JSON-RPC requests across `Pod`s in the scalable `Deployment`. See the Values section to enable and configure the `Deployment`.

#### Autoscaling

You can enable autoscaling for your scalable `Deployment` of `rpcdaemon`s. When enabled, the Chart will install a `HorizontalPodAutoscaler` into the cluster, which will manage the number of `rpcdaemon` replicas based on resource utilization.

If doing this, be sure to configure `rpcdaemons.resources.requests` with appropriate values, as the CPU and Memory utilization targets set in the autoscaling config are relative to the requested resource values.

## Upgrading

We recommend that you pin the version of the Chart that you deploy. TODO TODODODODODODOO

This project uses [Semantic Versioning](https://semver.org/). Changes to the version of the application (the `appVersion`) that the Chart deploys will generally result in a patch version bump for the Chart. Breaking changes to the Chart or its `values.yaml` interface will be reflected with a major version bump.

We do not recommend that you upgrade the application by overriding `image.tag`. Instead, use the version of the Chart that is built for your desired `appVersion`.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| fullnameOverride | string | `""` |  |
| grafana.dashboards | bool | `false` | Enable creation of Grafana dashboards. [Grafana chart](https://github.com/grafana/helm-charts/tree/main/charts/grafana#grafana-helm-chart) must be configured to search this namespace, see `sidecar.dashboards.searchNamespace` |
| grafana.dashboardsConfigMapLabel | string | `"grafana_dashboard"` | Must match `sidecar.dashboards.label` value for the [Grafana chart](https://github.com/grafana/helm-charts/tree/main/charts/grafana#grafana-helm-chart) |
| grafana.dashboardsConfigMapLabelValue | string | `""` | Must match `sidecar.dashboards.labelValue` value for the [Grafana chart](https://github.com/grafana/helm-charts/tree/main/charts/grafana#grafana-helm-chart) |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"thorax/erigon"` | Image for Erigon |
| image.tag | string | Chart.appVersion | Overrides the image tag |
| imagePullSecrets | list | `[]` | Pull secrets required to fetch the Image |
| nameOverride | string | `""` |  |
| prometheus.podMonitors.enabled | bool | `false` | Enable monitoring by creating `PodMonitor` CRDs ([prometheus-operator](https://github.com/prometheus-operator/prometheus-operator)) |
| prometheus.podMonitors.interval | string | `nil` |  |
| prometheus.podMonitors.labels | object | `{}` |  |
| prometheus.podMonitors.relabelings | list | `[]` |  |
| prometheus.podMonitors.scrapeTimeout | string | `nil` |  |
| rpcdaemons.affinity | object | `{}` |  |
| rpcdaemons.affinityPresets.antiAffinityByHostname | bool | `true` | Configure anti-affinity rules to prevent multiple Erigon instances on the same host |
| rpcdaemons.autoscaling.enabled | bool | `false` | Enable auto-scaling of the rpcdaemons Deployment. Be sure to set resources.requests for rpcdaemons. |
| rpcdaemons.autoscaling.maxReplicas | int | `10` | Maximum number of replicas |
| rpcdaemons.autoscaling.minReplicas | int | `1` | Minimum number of replicas |
| rpcdaemons.autoscaling.targetCPUUtilizationPercentage | int | `75` |  |
| rpcdaemons.autoscaling.targetMemoryUtilizationPercentage | string | `nil` |  |
| rpcdaemons.enabled | bool | `false` | Enable a Deployment of rpcdaemons that can be scaled independently |
| rpcdaemons.extraArgs | list | `[]` | Additional CLI arguments to pass to `rpcdaemon` |
| rpcdaemons.nodeSelector | object | `{}` |  |
| rpcdaemons.podAnnotations | object | `{}` | Annotations for the `Pod` |
| rpcdaemons.podSecurityContext | object | `{"fsGroup":101337,"runAsGroup":101337,"runAsNonRoot":true,"runAsUser":101337}` | Pod-wide security context |
| rpcdaemons.replicaCount | int | `1` | Number of rpcdaemons to run |
| rpcdaemons.resources.limits | object | `{}` |  |
| rpcdaemons.resources.requests | object | `{"cpu":"500m","memory":"4Gi"}` | Requests must be specified if you are using autoscaling |
| rpcdaemons.service.ports.http-jsonrpc | int | `8545` | Service Port to expose rpcdaemons JSON-RPC interface on |
| rpcdaemons.service.type | string | `"ClusterIP"` |  |
| rpcdaemons.tolerations | list | `[]` |  |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| statefulNode.affinity | object | `{}` |  |
| statefulNode.affinityPresets.antiAffinityByHostname | bool | `true` | Configure anti-affinity rules to prevent multiple Erigon instances on the same host |
| statefulNode.extraArgs | list | `[]` | Additional CLI arguments to pass to `erigon` |
| statefulNode.nodeSelector | object | `{}` |  |
| statefulNode.podAnnotations | object | `{}` | Annotations for the `Pod` |
| statefulNode.podSecurityContext | object | `{"fsGroup":101337,"runAsGroup":101337,"runAsNonRoot":true,"runAsUser":101337}` | Pod-wide security context |
| statefulNode.resources | object | `{}` |  |
| statefulNode.service.ports.grpc-erigon | int | `9090` | Service Port to expose Erigon GRPC interface on |
| statefulNode.service.ports.http-jsonrpc | int | `8545` | Service Port to expose sidecar rpcdaemon JSON-RPC interface on (if enabled) |
| statefulNode.service.type | string | `"ClusterIP"` |  |
| statefulNode.sidecarRpc.enabled | bool | `true` | Enables a high-performance sidecar rpcdaemon container inside the Erigon pod |
| statefulNode.sidecarRpc.extraArgs | list | `["--http.api=eth,debug,net,trace","--trace.maxtraces=10000"]` | Additional CLI arguments to pass to `rpcdaemon` |
| statefulNode.terminationGracePeriodSeconds | int | `60` | Amount of time to wait before force-killing the Erigon process |
| statefulNode.tolerations | list | `[]` |  |
| statefulNode.volumeClaimSpec | object | `{"accessModes":["ReadWriteOnce"],"resources":{"requests":{"storage":"3Ti"}},"storageClassName":null}` | [PersistentVolumeClaimSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.23/#persistentvolumeclaimspec-v1-core) for Erigon storage |
| statefulNode.volumeClaimSpec.resources.requests.storage | string | `"3Ti"` | The amount of disk space to provision for Erigon |
| statefulNode.volumeClaimSpec.storageClassName | string | `nil` | The storage class to use when provisioning a persistent volume for Erigon |

## Contributing

We welcome and appreciate your contributions! Please see the [Contributor Guide](/CONTRIBUTING.md), [Code Of Conduct](/CODE_OF_CONDUCT.md) and [Security Notes](/SECURITY.md) for this repository.

## See also

host-ulimit-config, dshackle