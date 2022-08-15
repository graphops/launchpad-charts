# Graph-Node Helm Chart

Deploy and scale [Graph Node](https://github.com/graphprotocol/graph-node) inside Kubernetes with ease

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) ![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v0.26.0](https://img.shields.io/badge/AppVersion-v0.26.0-informational?style=flat-square)

## Features

- Actively maintained by [GraphOps](https://graphops.xyz) and contributors
- Strong security defaults (non-root execution, ready-only root filesystem, drops all capabilities)
- Readiness checks to ensure traffic only hits `Pod`s that are healthy and ready to serve requests
- Support for `ServiceMonitor`s to configure Prometheus to scrape metrics ([prometheus-operator](https://github.com/prometheus-operator/prometheus-operator))
- Support for configuring Grafana dashboards ([grafana](https://github.com/grafana/helm-charts/tree/main/charts/grafana))

## TODO
# toolbox -> graphman, pgclient, indexer-agent (pod definition tty, stdin)
# forced restart of pods when deps change (check dione)
# docs for: graph node groups, default block ingestor, generated index pools, custom config templating, deployment rules configuration

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
| graphNodeConfigTemplate | string | `"[store]\n[store.primary]\nconnection = \"postgresql://${PG_PRIMARY_USERNAME}:${PG_PRIMARY_PASSWORD}@${PG_PRIMARY_HOSTNAME}/${PG_PRIMARY_DATABASE}\"\n# weight = 0\npool_size = 10\n[chains]\ningestor = \"block-ingestor\"\n[chains.mainnet]\nshard = \"primary\"\nprovider = [\n  { label = \"eth-mainnet\", url = \"${ETH_MAINNET_RPC_URL}\", features = [ \"archive\", \"traces\" ] }\n]\n[deployment]\n[[deployment.rule]]\n# There's no 'match', so any subgraph matches\nshards = [\"primary\"]\nindexers = {{ toJson .generated.indexPools.default }}\n"` | [Configuration for graph-node](https://github.com/graphprotocol/graph-node/blob/master/docs/config.md) |
| graphNodeDefaults.affinity | object | `{}` |  |
| graphNodeDefaults.affinityPresets.antiAffinityByHostname | bool | `true` |  |
| graphNodeDefaults.enabled | bool | `true` |  |
| graphNodeDefaults.env.ETH_MAINNET_RPC_URL | string | `nil` |  |
| graphNodeDefaults.env.PG_PRIMARY_DATABASE | string | `nil` |  |
| graphNodeDefaults.env.PG_PRIMARY_HOSTNAME | string | `nil` |  |
| graphNodeDefaults.extraArgs | list | `[]` | Additional CLI arguments to pass to Graph Node |
| graphNodeDefaults.includeInIndexPools | list | `[]` |  |
| graphNodeDefaults.nodeSelector | object | `{}` |  |
| graphNodeDefaults.podAnnotations | object | `{}` | Annotations for the `Pod` |
| graphNodeDefaults.podSecurityContext | object | `{"fsGroup":101337,"runAsGroup":101337,"runAsNonRoot":true,"runAsUser":101337}` | Pod-wide security context |
| graphNodeDefaults.replicaCount | int | `1` |  |
| graphNodeDefaults.resources | object | `{}` |  |
| graphNodeDefaults.secretEnv.PG_PRIMARY_PASSWORD.key | string | `"password"` |  |
| graphNodeDefaults.secretEnv.PG_PRIMARY_PASSWORD.secretName | string | `"postgres-config"` |  |
| graphNodeDefaults.secretEnv.PG_PRIMARY_USERNAME.key | string | `"username"` |  |
| graphNodeDefaults.secretEnv.PG_PRIMARY_USERNAME.secretName | string | `"postgres-config"` |  |
| graphNodeDefaults.service.ports.http-admin | int | `8020` | Service Port to expose Graph Node Admin endpoint on |
| graphNodeDefaults.service.ports.http-metrics | int | `8040` | Service Port to expose Graph Node Metrics endpoint on |
| graphNodeDefaults.service.ports.http-query | int | `8000` | Service Port to expose Graph Node Query endpoint on |
| graphNodeDefaults.service.ports.http-queryws | int | `8001` | Service Port to expose Graph Node Websocket Query endpoint on |
| graphNodeDefaults.service.ports.http-status | int | `8030` | Service Port to expose Graph Node Status endpoint on |
| graphNodeDefaults.service.type | string | `"ClusterIP"` |  |
| graphNodeDefaults.terminationGracePeriodSeconds | int | `60` | Amount of time to wait before force-killing the Erigon process |
| graphNodeDefaults.tolerations | list | `[]` |  |
| graphNodeGroups.block-ingestor.env.NODE_ROLE | string | `"index-node"` |  |
| graphNodeGroups.block-ingestor.includeInIndexPools | list | `[]` |  |
| graphNodeGroups.block-ingestor.replicaCount | int | `1` |  |
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
| toolbox.affinity | object | `{}` |  |
| toolbox.enabled | bool | `true` |  |
| toolbox.env | object | `{}` |  |
| toolbox.image.pullPolicy | string | `"IfNotPresent"` |  |
| toolbox.image.repository | string | `"graphprotocol/graph-node"` |  |
| toolbox.image.tag | string | `""` | Overrides the image tag |
| toolbox.nodeSelector | object | `{}` |  |
| toolbox.podAnnotations | object | `{}` |  |
| toolbox.podSecurityContext | object | `{"fsGroup":101337,"runAsGroup":101337,"runAsNonRoot":true,"runAsUser":101337}` | Pod-wide security context |
| toolbox.resources | object | `{}` |  |
| toolbox.secretEnv | object | `{}` |  |
| toolbox.tolerations | list | `[]` |  |

## Contributing

We welcome and appreciate your contributions! Please see the [Contributor Guide](/CONTRIBUTING.md), [Code Of Conduct](/CODE_OF_CONDUCT.md) and [Security Notes](/SECURITY.md) for this repository.