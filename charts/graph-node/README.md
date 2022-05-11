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
| graphNodeDefaults.affinity | object | `{}` |  |
| graphNodeDefaults.affinityPresets.antiAffinityByHostname | bool | `true` |  |
| graphNodeDefaults.extraArgs | list | `[]` | Additional CLI arguments to pass to Graph Node |
| graphNodeDefaults.nodeSelector | object | `{}` |  |
| graphNodeDefaults.podAnnotations | object | `{}` | Annotations for the `Pod` |
| graphNodeDefaults.podSecurityContext | object | `{"fsGroup":101337,"runAsGroup":101337,"runAsNonRoot":true,"runAsUser":101337}` | Pod-wide security context |
| graphNodeDefaults.resources | object | `{}` |  |
| graphNodeDefaults.service.ports.http-admin | int | `8020` | Service Port to expose Graph Node Admin endpoint on |
| graphNodeDefaults.service.ports.http-metrics | int | `8040` | Service Port to expose Graph Node Metrics endpoint on |
| graphNodeDefaults.service.ports.http-query | int | `8000` | Service Port to expose Graph Node Query endpoint on |
| graphNodeDefaults.service.ports.http-queryws | int | `8001` | Service Port to expose Graph Node Websocket Query endpoint on |
| graphNodeDefaults.service.ports.http-status | int | `8030` | Service Port to expose Graph Node Status endpoint on |
| graphNodeDefaults.service.type | string | `"ClusterIP"` |  |
| graphNodeDefaults.terminationGracePeriodSeconds | int | `60` | Amount of time to wait before force-killing the Erigon process |
| graphNodeDefaults.tolerations | list | `[]` |  |
| graphNodes.index-node.replicaCount | int | `1` |  |
| graphNodes.query-node.replicaCount | int | `1` |  |
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
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |

## Contributing

We welcome and appreciate your contributions! Please see the [Contributor Guide](/CONTRIBUTING.md), [Code Of Conduct](/CODE_OF_CONDUCT.md) and [Security Notes](/SECURITY.md) for this repository.