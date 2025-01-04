# Graph-Network-Indexer Helm Chart

Deploy and scale the [Graph Network Indexer](https://github.com/graphprotocol/indexer) components inside Kubernetes with ease

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) ![Version: 0.5.13](https://img.shields.io/badge/Version-0.5.13-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

## Introduction

The Graph Network Indexer components are essential for participating in [The Graph's Decentralized Network](https://thegraph.com/explorer). These components enable Indexers to interact with on-chain Graph Protocol contracts, manage data services, and integrate with off-chain systems like TAP.

- **[indexer-agent](https://github.com/graphprotocol/indexer/tree/main/packages/indexer-agent)** handles the on-chain interactions with Graph Protocol contracts, ensuring that indexers can manage their allocations and rewards efficiently.

- **[indexer-service](https://github.com/graphprotocol/indexer-rs/tree/main/service)** intermediates requests and provides data services, acting as the gateway for queries directed at the Indexer.

- **[indexer-tap-agent](https://github.com/graphprotocol/indexer-rs/tree/main/tap-agent)** integrates with [TAP (Timeline Aggregation Protocol)](https://github.com/semiotic-ai/timeline-aggregation-protocol), a trustless, efficient unidirectional micro-payments system.

## Chart Features

- Actively maintained by [GraphOps](https://graphops.xyz) [and contributors](https://github.com/graphops/launchpad-charts/graphs/contributors)
- Strong security defaults (non-root execution, ready-only root filesystem, drops all capabilities)
- Readiness checks to ensure traffic only hits `Pod`s that are healthy and ready to serve requests
- Support for `ServiceMonitor`s to configure Prometheus to scrape metrics ([prometheus-operator](https://github.com/prometheus-operator/prometheus-operator))
- Support for configuring Grafana dashboards ([grafana](https://github.com/grafana/helm-charts/tree/main/charts/grafana)) and a TAP dashboard providing details about query receipts and RAV (Receipt Aggregation Vouchers) redemptions.

## Quickstart

To install the chart with the release name `my-release`:

```console
$ helm repo add graphops http://graphops.github.io/launchpad-charts
$ helm install my-release graphops/graph-network-indexer
```

## Configuring graph-network-indexer

The `indexer-tap-agent` and `indexer-service` components require a combination of a [`config.toml`](https://github.com/graphprotocol/indexer-rs/blob/main/config/minimal-config-example.toml) file and environment variables for their initial setup, while the `indexer-agent` is bootstrapped using a mix of command-line arguments and environment variables.

Since these components share many common parameters, we’ve designed the Helm chart to minimize duplication and prevent user errors. The configuration is structured as follows:

- **`indexerDefaults.config`**: This renders the `config.toml` for both `indexer-tap-agent` and `indexer-service`. Defaults are provided, but they can be overridden by `indexerService.config` or `indexerTapAgent.config` as needed.
- The common parameters from `indexerDefaults.config` that are relevant to `indexer-agent` are automatically mapped to the required CLI arguments format for the `indexer-agent`.
- **`indexerAgent.config`**: Parameters specific to the `indexer-agent` that aren’t shared with other components are mapped directly to its CLI format.
- **Important**: Do not include `indexer-agent`-specific parameters in `indexerDefaults.config` to avoid conflicts, as the format expected by `indexer-service` and `indexer-tap-agent` differs from that of `indexer-agent`.

### Example Configuration:
Given the following values:

```yaml
indexerDefaults:
  config:
    graph_node:
      query_url: "your_graph_node_query_url"
      status_url: "your_graph_node_status_endpoint"
    indexer:
      indexer_address: "your_indexer_address"
```
This would be rendered in config.toml as:

```toml
[graph_node]
query_url = "your_graph_node_query_url"
status_url = "your_graph_node_status_endpoint"

[indexer]
indexer_address = "your_indexer_address"
```
The same values be rendered for `indexer-agent` as args:

```yaml
args:
    - --graph-node-query-endpoint=http://graph-node-query.graph-arbitrum-sepolia.svc.cluster.local.:8000
    - --graph-node-status-endpoint=http://graph-node-block-ingestor:8030/graphql
    - --indexer-address="0x32288863Ca0831F4406a905D360Ab1A9a4F0b42D"
```

The three components also share the same connection to the postgres database, which is configured using the `indexerDefaults.postgresConfig` values:

```yaml
postgresConfig:
  host: "localhost"
  port: 5432
  database: "your_database"
```
**Important**: The PostgreSQL username and password are not included in the example above, as the user is expected to provide them via environment variables.

Both `indexer-service` and `indexer-tap-agent` allow for a full PostgreSQL connection string (via `INDEXER_SERVICE_DATABASE__POSTGRES_URL` and `TAP_AGENT_DATABASE__POSTGRES_URL`, respectively). The Helm chart computes these connection strings using a combination of values from `indexerDefaults.postgresConfig` and the `POSTGRES_USERNAME` and `POSTGRES_PASSWORD` environment variables.

In contrast, `indexer-agent` requires each PostgreSQL configuration value (e.g., database, host, port) to be passed individually as either CLI arguments or environment variables. The chart computes the values for the CLI arguments `--postgres-database`, `--postgres-host`, and `--postgres-port`. For the username and password, users must either pass additional CLI arguments ( via `indexerAgent.config` ) or specify the environment variables `INDEXER_AGENT_POSTGRES_USERNAME` and `INDEXER_AGENT_POSTGRES_PASSWORD` (via `env` or `secretEnv`).

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
 | indexerAgent.image | Image for indexer-agent | object | `{"pullPolicy":"IfNotPresent","repository":"ghcr.io/graphprotocol/indexer-agent","tag":"v0.21.11"}` |
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
 | indexerDefaults | Value defaults that apply to both indexer-agent and indexer-service | object | `{"config":{"blockchain":{"chain_id":"valid_blockchain_chain_id","receipts_verifier_address":"valid_blockchain_receipts_verifier_address"},"graph_node":{"query_url":"your_graph_node_query_url","status_url":"your_graph_node_status_endpoint"},"indexer":{"indexer_address":"your_indexer_address"},"service":{"host_and_port":"0.0.0.0:7600"},"subgraphs.escrow":{"query_url":"http://your-graph-node-query:8000/subgraphs/id/TAP_ESCROW_SUBGRAPH","syncing_interval_secs":60},"subgraphs.network":{"query_url":"http://your-graph-node-query:8000/subgraphs/id/NETWORK_SUBGRAPH","syncing_interval_secs":60},"tap.rav_request":{"trigger_value_divisor":100}},"env":{},"metrics":{"address":"0.0.0.0","enabled":true,"port":7300},"postgresConfig":{"database":"your_database","host":"localhost","port":5432}}` |
 | indexerDefaults.config."subgraphs.escrow".query_url | Query URL for the Graph Escrow subgraph. For optimal performance, it's recommended to locally index the subgraph. If locally indexed, use a combination of `deployment_id` and `query_url` pointing to your graph-node-query. If not locally indexed, use the gateway URL. | required | `"http://your-graph-node-query:8000/subgraphs/id/TAP_ESCROW_SUBGRAPH"` |
 | indexerDefaults.config."subgraphs.network".query_url | Query URL for the Graph Network subgraph. For optimal performance, it's recommended to locally index the subgraph. If locally indexed, use a combination of `deployment_id` and `query_url` pointing to your graph-node-query. If not locally indexed, use the gateway URL. | required | `"http://your-graph-node-query:8000/subgraphs/id/NETWORK_SUBGRAPH"` |
 | indexerDefaults.config.graph_node.query_url | URL for your graph node query endpoint (probably a load balancer address) | required | `"your_graph_node_query_url"` |
 | indexerDefaults.config.graph_node.status_url | URL for your graph node status endpoint (probably a load balancer address) | required | `"your_graph_node_status_endpoint"` |
 | indexerDefaults.config.indexer.indexer_address | Ethereum address of your Indexer | required | `"your_indexer_address"` |
 | indexerService.affinity |  | object | `{}` |
 | indexerService.affinityPresets.antiAffinityByHostname | Configure anti-affinity rules to prevent multiple instances on the same host | bool | `true` |
 | indexerService.command | Entrypoint command to run | string | `"/usr/local/bin/indexer-service-rs"` |
 | indexerService.config |  | object | `{}` |
 | indexerService.env |  | object | `{}` |
 | indexerService.extraArgs | Additional CLI arguments to pass to `indexer-service` | list | `[]` |
 | indexerService.image | Image for indexer-service | object | `{"pullPolicy":"IfNotPresent","repository":"ghcr.io/graphprotocol/indexer-service-rs","tag":"v1.4.0"}` |
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
 | indexerTapAgent.command | Entrypoint command to run | string | `"/usr/local/bin/indexer-tap-agent"` |
 | indexerTapAgent.config |  | object | `{}` |
 | indexerTapAgent.extraArgs | Additional CLI arguments to pass to `indexer-service` | list | `[]` |
 | indexerTapAgent.image | Image for indexer-tap-agent | object | `{"pullPolicy":"IfNotPresent","repository":"ghcr.io/graphprotocol/indexer-tap-agent","tag":"v1.7.4"}` |
 | indexerTapAgent.nodeSelector |  | object | `{}` |
 | indexerTapAgent.podAnnotations | Annotations for the `Pod` | object | `{}` |
 | indexerTapAgent.podSecurityContext | Pod-wide security context | object | `{"fsGroup":101337,"runAsGroup":101337,"runAsNonRoot":true,"runAsUser":101337}` |
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
