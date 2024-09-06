# Graph-Network-Indexer Helm Chart

Deploy and scale the [Graph Network Indexer](https://github.com/graphprotocol/indexer) components inside Kubernetes with ease

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) ![Version: 0.5.0-canary.1](https://img.shields.io/badge/Version-0.5.0--canary.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.0.0-rc.6](https://img.shields.io/badge/AppVersion-1.0.0--rc.6-informational?style=flat-square)

## Introduction

The [Graph Network Indexer](https://github.com/graphprotocol/indexer) components are required for participating in [The Graph's Decentralised Network](https://thegraph.com/explorer). `indexer-agent` performs interactions with the Graph Protocol contracts on-chain, and `indexer-service` intermediates requests and ensures query payment is valid.

## Chart Features

- Actively maintained by [GraphOps](https://graphops.xyz) [and contributors](https://github.com/graphops/launchpad-charts/graphs/contributors)
- Strong security defaults (non-root execution, ready-only root filesystem, drops all capabilities)
- Readiness checks to ensure traffic only hits `Pod`s that are healthy and ready to serve requests
- Support for `ServiceMonitor`s to configure Prometheus to scrape metrics ([prometheus-operator](https://github.com/prometheus-operator/prometheus-operator))
- Support for configuring Grafana dashboards ([grafana](https://github.com/grafana/helm-charts/tree/main/charts/grafana))

## Quickstart

To install the chart with the release name `my-release`:

```console
$ helm repo add graphops http://graphops.github.io/launchpad-charts
$ helm install my-release graphops/graph-network-indexer
```

## Configuring graph-network-indexer

...

## Upgrading

We recommend that you pin the version of the Chart that you deploy. You can use the `--version` flag with `helm install` and `helm upgrade` to specify a chart version constraint.

This project uses [Semantic Versioning](https://semver.org/). Changes to the version of the application (the `appVersion`) that the Chart deploys will generally result in a patch version bump for the Chart. Breaking changes to the Chart or its `values.yaml` interface will be reflected with a major version bump.

We do not recommend that you upgrade the application by overriding `image.tag`. Instead, use the version of the Chart that is built for your desired `appVersion`.

## Values

| Key | Description | Type | Default |
|-----|-------------|------|---------|
 | config |  | object | `{}` |
 | fullnameOverride |  | string | `""` |
 | grafana.dashboards | Enable creation of Grafana dashboards. [Grafana chart](https://github.com/grafana/helm-charts/tree/main/charts/grafana#grafana-helm-chart) must be configured to search this namespace, see `sidecar.dashboards.searchNamespace` | bool | `false` |
 | grafana.dashboardsConfigMapLabel | Must match `sidecar.dashboards.label` value for the [Grafana chart](https://github.com/grafana/helm-charts/tree/main/charts/grafana#grafana-helm-chart) | string | `"grafana_dashboard"` |
 | grafana.dashboardsConfigMapLabelValue | Must match `sidecar.dashboards.labelValue` value for the [Grafana chart](https://github.com/grafana/helm-charts/tree/main/charts/grafana#grafana-helm-chart) | string | `"1"` |
 | imagePullSecrets | Pull secrets required to fetch the Image | list | `[]` |
 | indexerAgent.affinity |  | object | `{}` |
 | indexerAgent.affinityPresets.antiAffinityByHostname | Configure anti-affinity rules to prevent multiple instances on the same host | bool | `true` |
 | indexerAgent.config | Config to be supplied as CLI arguments, specified using YAML keys to allow overriding | object | `{"ethereum":null,"ethereum-network":"mainnet","graph-node-admin-endpoint":"test","indexer-management-port":8000}` |
 | indexerAgent.config.ethereum-network | Name of the network that you have specified a node URL for in `ethereum` | string | `"mainnet"` |
 | indexerAgent.env |  | object | `{}` |
 | indexerAgent.extraArgs |  | list | `[]` |
 | indexerAgent.image | Image for indexer-agent | object | `{"pullPolicy":"IfNotPresent","repository":"ghcr.io/graphprotocol/indexer-agent","tag":"v0.21.4"}` |
 | indexerAgent.nodeSelector |  | object | `{}` |
 | indexerAgent.podAnnotations | Annotations for the `Pod` | object | `{}` |
 | indexerAgent.podSecurityContext | Pod-wide security context | object | `{"fsGroup":101337,"runAsGroup":101337,"runAsNonRoot":true,"runAsUser":101337}` |
 | indexerAgent.resources |  | object | `{}` |
 | indexerAgent.secretEnv |  | object | `{}` |
 | indexerAgent.service.ports.http-mgmtapi | Service Port to expose Indexer Management API on | int | `8000` |
 | indexerAgent.service.topologyAwareRouting.enabled |  | bool | `false` |
 | indexerAgent.service.type |  | string | `"ClusterIP"` |
 | indexerAgent.terminationGracePeriodSeconds | Amount of time to wait before force-killing the process | int | `10` |
 | indexerAgent.tolerations |  | list | `[]` |
 | indexerDefaults | Value defaults that apply to both indexer-agent and indexer-service | object | `{"config":{"blockchain":{"chain_id":"valid_blockchain_chain_id","receipts_verifier_address":"valid_blockchain_receipts_verifier_address"},"graph_node":{"query_url":"your_graph_node_query_url","status_url":"your_graph_node_status_endpoint"},"indexer":{"indexer_address":"your_indexer_address"},"service":{"host_and_port":"0.0.0.0:7600"},"subgraphs.escrow":{"syncing_interval_secs":60},"subgraphs.network":{"syncing_interval_secs":60},"tap.rav_request":{"trigger_value_divisor":100}},"env":{},"metrics":{"address":"0.0.0.0","enabled":true,"port":7300},"postgresConfig":{"database":"your_database","host":"localhost","port":5432}}` |
 | indexerDefaults.config.graph_node.query_url | URL for your graph node query endpoint (probably a load balancer address) | required | `"your_graph_node_query_url"` |
 | indexerDefaults.config.graph_node.status_url | URL for your graph node status endpoint (probably a load balancer address) | required | `"your_graph_node_status_endpoint"` |
 | indexerDefaults.config.indexer.indexer_address | Ethereum address of your Indexer | required | `"your_indexer_address"` |
 | indexerService.affinity |  | object | `{}` |
 | indexerService.affinityPresets.antiAffinityByHostname | Configure anti-affinity rules to prevent multiple instances on the same host | bool | `true` |
 | indexerService.config |  | object | `{}` |
 | indexerService.env |  | object | `{}` |
 | indexerService.extraArgs | Additional CLI arguments to pass to `indexer-service` | list | `[]` |
 | indexerService.image | Image for indexer-service | object | `{"pullPolicy":"IfNotPresent","repository":"ghcr.io/graphprotocol/indexer-service-rs","tag":""}` |
 | indexerService.image.tag | Overrides the image tag | string | Chart.appVersion |
 | indexerService.nodeSelector |  | object | `{}` |
 | indexerService.podAnnotations | Annotations for the `Pod` | object | `{}` |
 | indexerService.podSecurityContext | Pod-wide security context | object | `{"fsGroup":101337,"runAsGroup":101337,"runAsNonRoot":true,"runAsUser":101337}` |
 | indexerService.replicas | Number of replicas to run | int | `1` |
 | indexerService.resources |  | object | `{}` |
 | indexerService.secretEnv |  | object | `{}` |
 | indexerService.service.ports.http-queryapi | Service Port to expose Indexer Query API on | int | `7600` |
 | indexerService.service.topologyAwareRouting.enabled |  | bool | `false` |
 | indexerService.service.type |  | string | `"ClusterIP"` |
 | indexerService.terminationGracePeriodSeconds | Amount of time to wait before force-killing the process | int | `10` |
 | indexerService.tolerations |  | list | `[]` |
 | indexerTapAgent.affinity |  | object | `{}` |
 | indexerTapAgent.affinityPresets.antiAffinityByHostname | Configure anti-affinity rules to prevent multiple instances on the same host | bool | `true` |
 | indexerTapAgent.config |  | object | `{}` |
 | indexerTapAgent.extraArgs | Additional CLI arguments to pass to `indexer-service` | list | `[]` |
 | indexerTapAgent.image | Image for indexer-tap-agent | object | `{"pullPolicy":"IfNotPresent","repository":"ghcr.io/graphprotocol/indexer-tap-agent","tag":""}` |
 | indexerTapAgent.image.tag | Overrides the image tag | string | Chart.appVersion |
 | indexerTapAgent.nodeSelector |  | object | `{}` |
 | indexerTapAgent.podAnnotations | Annotations for the `Pod` | object | `{}` |
 | indexerTapAgent.podSecurityContext | Pod-wide security context | object | `{"fsGroup":101337,"runAsGroup":101337,"runAsNonRoot":true,"runAsUser":101337}` |
 | indexerTapAgent.replicas | Number of replicas to run | int | `1` |
 | indexerTapAgent.resources |  | object | `{}` |
 | indexerTapAgent.secretEnv |  | object | `{}` |
 | indexerTapAgent.service.ports.http-queryapi | Service Port to expose Indexer Query API on | int | `7600` |
 | indexerTapAgent.service.topologyAwareRouting.enabled |  | bool | `false` |
 | indexerTapAgent.service.type |  | string | `"ClusterIP"` |
 | indexerTapAgent.terminationGracePeriodSeconds | Amount of time to wait before force-killing the process | int | `10` |
 | indexerTapAgent.tolerations |  | list | `[]` |
 | nameOverride |  | string | `""` |
 | prometheus.serviceMonitors.enabled | Enable monitoring by creating `ServiceMonitor` CRDs ([prometheus-operator](https://github.com/prometheus-operator/prometheus-operator)) | bool | `false` |
 | prometheus.serviceMonitors.interval |  | string | `nil` |
 | prometheus.serviceMonitors.labels |  | object | `{}` |
 | prometheus.serviceMonitors.metricRelabelings |  | list | `[]` |
 | prometheus.serviceMonitors.relabelings |  | list | `[]` |
 | prometheus.serviceMonitors.scrapeTimeout |  | string | `nil` |
 | serviceAccount.annotations | Annotations to add to the service account | object | `{}` |
 | serviceAccount.create | Specifies whether a service account should be created | bool | `true` |
 | serviceAccount.name | The name of the service account to use. If not set and create is true, a name is generated using the fullname template | string | `""` |

## Contributing

We welcome and appreciate your contributions! Please see the [Contributor Guide](/CONTRIBUTING.md), [Code Of Conduct](/CODE_OF_CONDUCT.md) and [Security Notes](/SECURITY.md) for this repository.
