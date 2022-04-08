# Erigon Helm Chart

Deploy and scale [Erigon](https://github.com/ledgerwatch/erigon) inside Kubernetes with ease

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) ![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v2022.03.02](https://img.shields.io/badge/AppVersion-v2022.03.02-informational?style=flat-square)

## Features

- Actively maintained by [GraphOps](https://graphops.xyz) and contributors
- Supports deploying a `rpcdaemon` sidecar within the `Pod` that contains the stateful `erigon` container, allowing direct database access and higher performance for the sidecar `rpcdaemon`
- Supports an independent pool of `rpcdaemon` instances, with auto-scaling support, for automatic elastic JSON-RPC
- Good security defaults (non-root execution, ready-only root filesystem, drops all capabilities)
- Readiness checks to ensure traffic only hits Pods that are ready
- Support for installing [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack) `PodMonitor`s to configure Prometheus to scrape metrics
- Support for installing [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack) Grafana dashboards for Erigon

## Todo

- Support for installing [grafana-operator](https://github.com/grafana-operator/grafana-operator) `Dashboard`s
- Figure out release notes automation
- Move ulimit config to separate chart
- Test removing chmod initContainer given that we gave fsGroup

## Quickstart

To install the chart with the release name `my-release`:

```console
$ helm repo add graphops http://graphops.github.io/charts
$ helm install my-release graphops/erigon
```

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
| prometheus.podMonitors | bool | `false` | Enable monitoring by creating PodMonitor CRDs |
| rpcDaemons.affinity | object | `{}` |  |
| rpcDaemons.affinityPresets.antiAffinityByHostname | bool | `true` | Configure anti-affinity rules to prevent multiple Erigon instances on the same host |
| rpcDaemons.autoscaling.enabled | bool | `false` | Enable auto-scaling of the rpcdaemons Deployment |
| rpcDaemons.autoscaling.maxReplicas | int | `100` |  |
| rpcDaemons.autoscaling.minReplicas | int | `1` | Minimum number of replicas |
| rpcDaemons.autoscaling.targetCPUUtilizationPercentage | string | `nil` |  |
| rpcDaemons.autoscaling.targetMemoryUtilizationPercentage | string | `nil` |  |
| rpcDaemons.enabled | bool | `true` | Enable a Deployment of rpcdaemons that can be scaled independently |
| rpcDaemons.extraArgs | list | `[]` | Additional CLI arguments to pass to `rpcdaemon` |
| rpcDaemons.nodeSelector | object | `{}` |  |
| rpcDaemons.podAnnotations | object | `{}` |  |
| rpcDaemons.podSecurityContext | object | `{"fsGroup":101337,"runAsGroup":101337,"runAsNonRoot":true,"runAsUser":101337}` | Pod-wide security context for locking down container permissions |
| rpcDaemons.replicaCount | int | `2` | Number of rpcdaemons to run |
| rpcDaemons.resources | object | `{}` |  |
| rpcDaemons.service.ports.http-jsonrpc | int | `8545` | Service Port to expose rpcdaemons JSON-RPC interface on |
| rpcDaemons.service.type | string | `"ClusterIP"` |  |
| rpcDaemons.tolerations | list | `[]` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| statefulNode.affinity | object | `{}` |  |
| statefulNode.affinityPresets.antiAffinityByHostname | bool | `true` | Configure anti-affinity rules to prevent multiple Erigon instances on the same host |
| statefulNode.extraArgs | list | `[]` | Additional CLI arguments to pass to `erigon` |
| statefulNode.nodeSelector | object | `{}` |  |
| statefulNode.podAnnotations | object | `{}` | Annotations to attach to the Pod |
| statefulNode.podSecurityContext | object | `{"fsGroup":101337,"runAsGroup":101337,"runAsNonRoot":true,"runAsUser":101337}` | Pod-wide security context |
| statefulNode.resources | object | `{}` |  |
| statefulNode.service.ports.grpc-erigon | int | `9090` | Service Port to expose Erigon GRPC interface on |
| statefulNode.service.ports.http-jsonrpc | int | `8545` | Service Port to expose sidecar rpcdaemon JSON-RPC interface on (if enabled) |
| statefulNode.service.type | string | `"ClusterIP"` |  |
| statefulNode.sidecarRpc.enabled | bool | `true` | Enables a high-performance sidecar rpcdaemon container inside the Erigon pod |
| statefulNode.sidecarRpc.extraArgs | list | `["--http.api=eth,debug,net,trace","--trace.maxtraces=10000"]` | Additional CLI arguments to pass to `rpcdaemon` |
| statefulNode.terminationGracePeriodSeconds | int | `300` | Amount of time to wait before force-killing the Erigon process |
| statefulNode.tolerations | list | `[]` |  |
| statefulNode.volumeClaimSpec | object | `{"accessModes":["ReadWriteOnce"],"resources":{"requests":{"storage":"3Ti"}},"storageClassName":null}` | PersistentVolumeClaimSpec for Erigon storage, see https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.23/#persistentvolumeclaimspec-v1-core |
| statefulNode.volumeClaimSpec.resources.requests.storage | string | `"3Ti"` | The amount of disk space to provision for Erigon |
| statefulNode.volumeClaimSpec.storageClassName | string | `nil` | The storage class to use when provisioning a persistent volume for Erigon |

## Troubleshooting

## Contributing

- install deps (helm, helm-docs)
- install git hooks
- CLA?