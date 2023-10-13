# Graph-Network-Indexer Helm Chart

Deploy and scale the [Graph Network Indexer](https://github.com/graphprotocol/indexer) components inside Kubernetes with ease

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) ![Version: 0.2.2](https://img.shields.io/badge/Version-0.2.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v0.20.22](https://img.shields.io/badge/AppVersion-v0.20.22-informational?style=flat-square)

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
 | fullnameOverride |  | string | `""` |
 | grafana.dashboards | Enable creation of Grafana dashboards. [Grafana chart](https://github.com/grafana/helm-charts/tree/main/charts/grafana#grafana-helm-chart) must be configured to search this namespace, see `sidecar.dashboards.searchNamespace` | bool | `false` |
 | grafana.dashboardsConfigMapLabel | Must match `sidecar.dashboards.label` value for the [Grafana chart](https://github.com/grafana/helm-charts/tree/main/charts/grafana#grafana-helm-chart) | string | `"grafana_dashboard"` |
 | grafana.dashboardsConfigMapLabelValue | Must match `sidecar.dashboards.labelValue` value for the [Grafana chart](https://github.com/grafana/helm-charts/tree/main/charts/grafana#grafana-helm-chart) | string | `"1"` |
 | imagePullSecrets | Pull secrets required to fetch the Image | list | `[]` |
 | indexerAgent.affinity |  | object | `{}` |
 | indexerAgent.affinityPresets.antiAffinityByHostname | Configure anti-affinity rules to prevent multiple instances on the same host | bool | `true` |
 | indexerAgent.config | Config to be supplied as CLI arguments, specified using YAML keys to allow overriding | object | `{"collect-receipts-endpoint":null,"dai-contract":null,"epoch-subgraph-endpoint":null,"graph-node-admin-endpoint":null,"index-node-ids":null,"network-subgraph-deployment":null,"public-indexer-url":null}` |
 | indexerAgent.config.collect-receipts-endpoint | The gateway collect-receipts endpoint for getting vouchers | required | `nil` |
 | indexerAgent.config.dai-contract | Contract address of ERC20 used for DAI variable in cost models | required | `nil` |
 | indexerAgent.config.epoch-subgraph-endpoint | Query endpoint for syncing status of EBO and its contract state. | optional | `nil` |
 | indexerAgent.config.graph-node-admin-endpoint | URL for your graph-node admin API endpoint | required | `nil` |
 | indexerAgent.config.index-node-ids | A command separated list of graph-node Node IDs to assign subgraphs to | required | `nil` |
 | indexerAgent.config.network-subgraph-deployment | Base58 deployment hash (Qm...) for the Graph Network Subgraph | required | `nil` |
 | indexerAgent.config.public-indexer-url | Public HTTPS URL of your indexer-service query endpoint | required | `nil` |
 | indexerAgent.env |  | object | `{}` |
 | indexerAgent.extraArgs | Additional CLI arguments to pass to `indexer-agent` | list | `[]` |
 | indexerAgent.image | Image for indexer-agent | object | `{"pullPolicy":"IfNotPresent","repository":"ghcr.io/graphprotocol/indexer-agent","tag":""}` |
 | indexerAgent.image.tag | Overrides the image tag | string | Chart.appVersion |
 | indexerAgent.nodeSelector |  | object | `{}` |
 | indexerAgent.podAnnotations | Annotations for the `Pod` | object | `{}` |
 | indexerAgent.podSecurityContext | Pod-wide security context | object | `{"fsGroup":101337,"runAsGroup":101337,"runAsNonRoot":true,"runAsUser":101337}` |
 | indexerAgent.resources |  | object | `{}` |
 | indexerAgent.secretEnv |  | object | `{}` |
 | indexerAgent.service.ports.http-metrics | Service Port to expose Metrics on | int | `7300` |
 | indexerAgent.service.ports.http-mgmtapi | Service Port to expose Indexer Management API on | int | `8000` |
 | indexerAgent.service.topologyAwareRouting.enabled |  | bool | `false` |
 | indexerAgent.service.type |  | string | `"ClusterIP"` |
 | indexerAgent.terminationGracePeriodSeconds | Amount of time to wait before force-killing the process | int | `10` |
 | indexerAgent.tolerations |  | list | `[]` |
 | indexerDefaults | Value defaults that apply to both indexer-agent and indexer-service | object | `{"config":{"ethereum":null,"ethereum-network":"mainnet","graph-node-query-endpoint":null,"graph-node-status-endpoint":null,"indexer-address":null,"mnemonic":null,"network-subgraph-endpoint":null,"postgres-database":"indexer","postgres-host":null,"postgres-password":null,"postgres-port":5432,"postgres-username":null},"env":{},"secretEnv":{}}` |
 | indexerDefaults.config | Config to be supplied as CLI arguments, specified using YAML keys to allow overriding | object | `{"ethereum":null,"ethereum-network":"mainnet","graph-node-query-endpoint":null,"graph-node-status-endpoint":null,"indexer-address":null,"mnemonic":null,"network-subgraph-endpoint":null,"postgres-database":"indexer","postgres-host":null,"postgres-password":null,"postgres-port":5432,"postgres-username":null}` |
 | indexerDefaults.config.ethereum | URL for a blockchain node that has the Graph Protocol contracts (e.g. Ethereum Mainnet, Goerli) | required | `nil` |
 | indexerDefaults.config.ethereum-network | Name of the network that you have specified a node URL for in `ethereum` | string | `"mainnet"` |
 | indexerDefaults.config.graph-node-query-endpoint | URL for your graph node query endpoint (probably a load balancer address) | required | `nil` |
 | indexerDefaults.config.graph-node-status-endpoint | URL for your graph node status endpoint (probably a load balancer address) | required | `nil` |
 | indexerDefaults.config.indexer-address | Ethereum address of your Indexer | required | `nil` |
 | indexerDefaults.config.mnemonic | Specify a plain text mnemonic for your operator account. Instead, we recommend using a Kubernetes Secret and secretEnv to mount the value as an environment variable. | not recommended | `nil` |
 | indexerDefaults.config.network-subgraph-endpoint | An endpoint to query the network subgraph | required | `nil` |
 | indexerDefaults.config.postgres-database | Name of the Postgres database to use for indexer metadata | string | `"indexer"` |
 | indexerDefaults.config.postgres-host | Hostname for your Postgres indexer metadata database | required | `nil` |
 | indexerDefaults.config.postgres-password | Specify a plain text password to authenticate with Postgres. Instead, we recommend using a Kubernetes Secret and secretEnv to mount the value as an environment variable. | not recommended | `nil` |
 | indexerDefaults.config.postgres-port | Port that Postgres is available on | int | `5432` |
 | indexerDefaults.config.postgres-username | Specify a plain text username to authenticate with Postgres | string | `nil` |
 | indexerService.affinity |  | object | `{}` |
 | indexerService.affinityPresets.antiAffinityByHostname | Configure anti-affinity rules to prevent multiple instances on the same host | bool | `true` |
 | indexerService.config | Config to be supplied as CLI arguments, specified using YAML keys to allow overriding | object | `{"client-signer-address":null}` |
 | indexerService.config.client-signer-address | The address of the signer for vouchers (see https://github.com/graphprotocol/indexer/blob/main/docs/networks.md) | required | `nil` |
 | indexerService.env |  | object | `{}` |
 | indexerService.extraArgs | Additional CLI arguments to pass to `indexer-service` | list | `[]` |
 | indexerService.image | Image for indexer-service | object | `{"pullPolicy":"IfNotPresent","repository":"ghcr.io/graphprotocol/indexer-service","tag":""}` |
 | indexerService.image.tag | Overrides the image tag | string | Chart.appVersion |
 | indexerService.nodeSelector |  | object | `{}` |
 | indexerService.podAnnotations | Annotations for the `Pod` | object | `{}` |
 | indexerService.podSecurityContext | Pod-wide security context | object | `{"fsGroup":101337,"runAsGroup":101337,"runAsNonRoot":true,"runAsUser":101337}` |
 | indexerService.resources |  | object | `{}` |
 | indexerService.secretEnv |  | object | `{}` |
 | indexerService.service.ports.http-metrics | Service Port to expose Metrics on | int | `7300` |
 | indexerService.service.ports.http-queryapi | Service Port to expose Query API on | int | `7600` |
 | indexerService.service.topologyAwareRouting.enabled |  | bool | `false` |
 | indexerService.service.type |  | string | `"ClusterIP"` |
 | indexerService.terminationGracePeriodSeconds | Amount of time to wait before force-killing the process | int | `10` |
 | indexerService.tolerations |  | list | `[]` |
 | nameOverride |  | string | `""` |
 | prometheus.serviceMonitors.enabled | Enable monitoring by creating `ServiceMonitor` CRDs ([prometheus-operator](https://github.com/prometheus-operator/prometheus-operator)) | bool | `false` |
 | prometheus.serviceMonitors.interval |  | string | `nil` |
 | prometheus.serviceMonitors.labels |  | object | `{}` |
 | prometheus.serviceMonitors.relabelings |  | list | `[]` |
 | prometheus.serviceMonitors.scrapeTimeout |  | string | `nil` |
 | serviceAccount.annotations | Annotations to add to the service account | object | `{}` |
 | serviceAccount.create | Specifies whether a service account should be created | bool | `true` |
 | serviceAccount.name | The name of the service account to use. If not set and create is true, a name is generated using the fullname template | string | `""` |

## Contributing

We welcome and appreciate your contributions! Please see the [Contributor Guide](/CONTRIBUTING.md), [Code Of Conduct](/CODE_OF_CONDUCT.md) and [Security Notes](/SECURITY.md) for this repository.
