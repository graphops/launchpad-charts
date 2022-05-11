# Graph-Node Helm Chart

Deploy and scale [Graph Node](https://github.com/graphprotocol/graph-node) inside Kubernetes with ease

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) ![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v0.26.0](https://img.shields.io/badge/AppVersion-v0.26.0-informational?style=flat-square)

## Features

- Actively maintained by [GraphOps](https://graphops.xyz) and contributors
- Deploys a scalable pool of `rpcdaemon` instances, with auto-scaling support, for automatic elastic JSON-RPC
- Strong security defaults (non-root execution, ready-only root filesystem, drops all capabilities)
- Readiness checks to ensure traffic only hits `Pod`s that are healthy and ready to serve requests
- Support for `ServiceMonitor`s to configure Prometheus to scrape metrics ([prometheus-operator](https://github.com/prometheus-operator/prometheus-operator))
- Support for configuring Grafana dashboards ([grafana](https://github.com/grafana/helm-charts/tree/main/charts/grafana))

## Quickstart

To install the chart with the release name `my-release`:

```console
$ helm repo add graphops http://graphops.github.io/helm-charts
$ helm install my-release graphops/graph-node
```

## Upgrading

We recommend that you pin the version of the Chart that you deploy. You can use the `--version` flag with `helm install` and `helm upgrade` to specify a chart version constraint.

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
| image.repository | string | `"graphprotocol/graph-node"` | Image for Graph Node |
| image.tag | string | Chart.appVersion | Overrides the image tag |
| imagePullSecrets | list | `[]` | Pull secrets required to fetch the Image |
| nameOverride | string | `""` |  |
| prometheus.serviceMonitors.enabled | bool | `false` | Enable monitoring by creating `ServiceMonitor` CRDs ([prometheus-operator](https://github.com/prometheus-operator/prometheus-operator)) |
| prometheus.serviceMonitors.interval | string | `nil` |  |
| prometheus.serviceMonitors.labels | object | `{}` |  |
| prometheus.serviceMonitors.relabelings | list | `[]` |  |
| prometheus.serviceMonitors.scrapeTimeout | string | `nil` |  |
| rpcdaemons.affinity | object | `{}` |  |
| rpcdaemons.affinityPresets.antiAffinityByHostname | bool | `true` |  |
| rpcdaemons.autoscaling.enabled | bool | `false` | Enable auto-scaling of the rpcdaemons Deployment. Be sure to set resources.requests for rpcdaemons. |
| rpcdaemons.autoscaling.maxReplicas | int | `10` | Maximum number of replicas |
| rpcdaemons.autoscaling.minReplicas | int | `2` | Minimum number of replicas |
| rpcdaemons.autoscaling.targetCPUUtilizationPercentage | int | `75` |  |
| rpcdaemons.autoscaling.targetMemoryUtilizationPercentage | string | `nil` |  |
| rpcdaemons.enabled | bool | `true` | Enable a Deployment of rpcdaemons that can be scaled independently |
| rpcdaemons.extraArgs | list | `["--http.api=eth,debug,net,trace","--trace.maxtraces=10000","--http.vhosts=*","--http.corsdomain=*","--ws","--rpc.batch.concurrency=4","--state.cache=2000000"]` | Additional CLI arguments to pass to `rpcdaemon` |
| rpcdaemons.nodeSelector | object | `{}` |  |
| rpcdaemons.podAnnotations | object | `{}` | Annotations for the `Pod` |
| rpcdaemons.podSecurityContext | object | `{"fsGroup":101337,"runAsGroup":101337,"runAsNonRoot":true,"runAsUser":101337}` | Pod-wide security context |
| rpcdaemons.replicaCount | int | `2` | Number of rpcdaemons to run |
| rpcdaemons.resources.limits | object | `{}` |  |
| rpcdaemons.resources.requests | object | `{"cpu":"500m","memory":"4Gi"}` | Requests must be specified if you are using autoscaling |
| rpcdaemons.service.ports.http-jsonrpc | int | `8545` | Service Port to expose rpcdaemons JSON-RPC interface on |
| rpcdaemons.service.type | string | `"ClusterIP"` |  |
| rpcdaemons.tolerations | list | `[]` |  |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| statefulNode.affinity | object | `{}` |  |
| statefulNode.affinityPresets.antiAffinityByHostname | bool | `true` |  |
| statefulNode.extraArgs | list | `["--torrent.download.rate=100mb"]` | Additional CLI arguments to pass to  |
| statefulNode.nodeSelector | object | `{}` |  |
| statefulNode.podAnnotations | object | `{}` | Annotations for the `Pod` |
| statefulNode.podSecurityContext | object | `{"fsGroup":101337,"runAsGroup":101337,"runAsNonRoot":true,"runAsUser":101337}` | Pod-wide security context |
| statefulNode.resources | object | `{}` |  |
| statefulNode.service.ports.grpc-erigon | int | `9090` | Service Port to expose Erigon GRPC interface on |
| statefulNode.service.ports.http-engineapi | int | `8550` | Service Port to expose engineAPI interface on |
| statefulNode.service.ports.http-jsonrpc | int | `8545` | Service Port to expose JSON-RPC interface on |
| statefulNode.service.type | string | `"ClusterIP"` |  |
| statefulNode.terminationGracePeriodSeconds | int | `60` | Amount of time to wait before force-killing the Erigon process |
| statefulNode.tolerations | list | `[]` |  |

## Contributing

We welcome and appreciate your contributions! Please see the [Contributor Guide](/CONTRIBUTING.md), [Code Of Conduct](/CODE_OF_CONDUCT.md) and [Security Notes](/SECURITY.md) for this repository.