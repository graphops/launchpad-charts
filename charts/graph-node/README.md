# Graph-Node Helm Chart

Deploy and scale [Graph Node](https://github.com/graphprotocol/graph-node) inside Kubernetes with ease

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) ![Version: 0.4.3](https://img.shields.io/badge/Version-0.4.3-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v0.34.1](https://img.shields.io/badge/AppVersion-v0.34.1-informational?style=flat-square)

## Introduction

[Graph Node](https://github.com/graphprotocol/graph-node) is key component of [The Graph](https://thegraph.com), a decentralised blockchain data protocol. Graph Node supports executing [Subgraphs](https://thegraph.com/docs/en/developing/creating-a-subgraph/) to extract, process and index blockchain data. It also provides a rich GraphQL query interface to inspect and interrogate this data. [Learn more](https://github.com/graphprotocol/graph-node/blob/master/docs/getting-started.md).

## Chart Features

- Actively maintained by [GraphOps](https://graphops.xyz) [and contributors](https://github.com/graphops/launchpad-charts/graphs/contributors)
- Strong security defaults (non-root execution, ready-only root filesystem, drops all capabilities)
- Readiness checks to ensure traffic only hits `Pod`s that are healthy and ready to serve requests
- Support for `ServiceMonitor`s to configure Prometheus to scrape metrics ([prometheus-operator](https://github.com/prometheus-operator/prometheus-operator))
- Support for configuring Grafana dashboards ([grafana](https://github.com/grafana/helm-charts/tree/main/charts/grafana))
- Easily define groups of Graph Nodes and split responsibilities across them

## Quickstart

To install the chart with the release name `my-release`:

```console
$ helm repo add graphops http://graphops.github.io/launchpad-charts
$ helm install my-release graphops/graph-node
```

## Configuring graph-node

This chart uses [`config.toml` to configure Graph Node](https://github.com/graphprotocol/graph-node/blob/master/docs/config.md). The Chart uses your [Values](#Values), as well as a [configuration template](#advanced-configuration), to render a `config.toml`. This approach provides a great out of the box experience, while providing flexibility for power users to generate customised configuration for highly advanced configurations of Graph Node.

### Graph Node Groups

Graph Node supports being deployed in a wide variety of configurations. In the most simple case, you can have a single instance of Graph Node that is responsible for all tasks, including block ingestion, indexing subgraphs and serving queries. More advanced users might separate out each task into a dedicated group of Graph Nodes. Operators indexing many blockchains can even deploy a dedicated group of indexing Graph Nodes for each blockchain.

Groups are defined in your `values.yaml` (see [Values](#Values)) under the `groupNodeGroups` key. Default configuration which will be applied to all groups can be set under the `graphNodeDefaults` key. Values in group-specific configuration will take precedence over those present in the default configuration.

#### Default Group Configuration

By default, the chart defines three Graph Node Groups:

1. `block-ingestor`, with a `replicaCount` of `1`, which is also configured in the [configuration template](#advanced-configuration) as the block ingestor node
1. `index`, with a `replicaCount` of `1`, which is configured as an `index-node`, and included in the `default` [Index Pool for subgraph deployment purposes](#subgraph-deployment-rules)
1. `query`, with a `replicaCount` of `1`, which is configured as a `query-node`

See [Values](#Values) for how to scale these groups and apply other configuration. You can also disable these groups to define more advanced grouping configuration.

Kubernetes `Service`s are provisioned for each group to allow load balancing and failover for nodes in that group.

#### Customising Groups

You can disable default groups and define your own.

<details>
  <summary><strong>Groups Config Example</strong>: Single combined Graph Node that performs all functions</summary>

  ```yaml
  graphNodeDefaults:
    env:
      IPFS: "https://ipfs.network.thegraph.com"
      PGDATABASE: graph
      PGHOST: my-pg-host

    secretEnv:   
      PGUSER:
        secretName: postgres-config
        key: username
      PGPASSWORD:
        secretName: postgres-config
        key: password

  graphNodeGroups:
    combined:
      enabled: true
      replicaCount: 1
      includeInIndexPools:
        - default
      env:
        NODE_ROLE: combined-mode
  blockIngestorGroupName: combined # we must override this because the default value assumes a dedicated block-ingestor group
  ```
</details>

<details>
  <summary><strong>Groups Config Example</strong>: Separated block ingestor, index nodes, query nodes, with dedicated groups for debugging subgraph indexing and VIP subgraph deployments</summary>

  ```yaml
  graphNodeDefaults:
    env:
      PGDATABASE: graph
      PGHOST: my-pg-host

    secretEnv:   
      PGUSER:
        secretName: postgres-config
        key: username
      PGPASSWORD:
        secretName: postgres-config
        key: password

  graphNodeGroups:
    block-ingestor:
      enabled: true
      replicaCount: 1
      includeInIndexPools: [] # do not index any subgraphs on the block ingestor
      env:
        NODE_ROLE: index-node
    index:
      enabled: true
      replicaCount: 10
      includeInIndexPools:
        - default
      env:
        NODE_ROLE: index-node
    index-vip:
      enabled: true
      replicaCount: 2
      includeInIndexPools: [] # don't deploy here by default, rely on manual assignment
      nodeSelector:
        my_high_performance_node_label: "true"
      env:
        NODE_ROLE: index-node
    index-debug:
      enabled: true
      replicaCount: 1
      includeInIndexPools: [] # don't deploy here by default, rely on manual assignment
      env:
        NODE_ROLE: index-node
        RUST_LOG: trace
        GRAPH_LOG: trace
    query:
      enabled: true
      replicaCount: 3
      env:
        NODE_ROLE: query-node
  ```

  In this example, subgraph deployments could be manually reassigned to a `index-debug` node to extract trace index logs, or to a `index-vip` node to run on a VIP node pointing at a higher performance JSON-RPC endpoint.
</details>

### Configuring Blockchain JSON-RPC Nodes

You need to pass JSON-RPC node configuration for as many blockchains as you want to index.

Example:

```yaml
# values.yaml

chains:
  mainnet:
    enabled: true
    shard: primary # The database shard to use for this chain
    provider:
      - label: ethereum-mainnet-archival-trace-node
        url: "http://ethereum-mainnet-archival-trace-node:8545"
        features: [archive, traces]
      - label: ethereum-mainnet-pruned-node
        url: "http://ethereum-mainnet-pruned-node:8545"
        features: []
  gnosis:
    enabled: true
    shard: primary
    provider:
      - label: gnosis-mainnet-archival-trace-node
        url: "http://gnosis-mainnet-archival-trace-node:8545"
        features: [archive, traces]
```

This configuration will be used to generate the appropriate TOML config for Graph Node. To customise this behaviour, see [advanced configuration](#advanced-configuration).

### Subgraph Deployment Rules

By default, the configuration template defines a single subgraph deployment rule that assigns all subgraphs to the set of nodes defined by the `default` index pool.

#### Index Pools

An Index Pool is a set of Graph Nodes (an array of [Node ID](#automatic-node-ids)s) that are grouped together for subgraph indexing purposes. You can include a Graph Node Group and its nodes in an Index Pool by specifying the pool name in that Group's `includeInIndexPools` configuration.

The Chart automatically generates Index Pools basic on the Group configuration you specify in [Values](#Values).

#### Automatic Node IDs

Graph Node instances are assigned an ID, allowing subgraphs to be assigned to a particular instance.

This Chart deploys Graph Node using Kubernetes `StatefulSet`s, providing a consistent naming scheme for all `Pod`s. This is the basis for Node ID generation.

The Node ID template follows the format: `<release-name>-<group-name>-<index>`, where index is an integer indicating the node number in that group, with the first node having the index of `0`.

### Advanced Configuration

This Chart uses a template to allow customisation of the configuration passed into the application. The template is rendered by Helm, so you can use [Go templating](https://golangdocs.com/templates-in-golang) as well as [Helm context built-ins](https://helm.sh/docs/chart_template_guide/builtin_objects) to customise the configuration. This includes accessing and looping over any values that you pass into the Helm release.

The template is defined under the `configTemplate` key in the [Values](#Values). You can override this value to specify your custom template.

The Chart also computes additional values that are appended to the template context. You can use these in your template too. See more below.

This diagram describes how this template is used to generate of the output configuration.

```mermaid
graph LR
    a(Chart Values) -->|All Values| b{Context}
    a --> c[Helm]
    c -->|Computed Values| b
    b --> d[Helm]
    a -->|Config Template| d
    d -->|Render Template| e[Output Config]
```

### Computed Template Variables

The following additional template variables are computed and injected into the template context under the `computed` key:

- `indexPools` - a `dict` of `index_pool_name -> [graph_node_id1, graph_node_id2, graph_node_id3]`

You can use these keys in your custom configuration template (e.g. `{{ .computed.computedValue }}`).

## Grafana Integration

This chart supports integration with the [Grafana Chart](https://github.com/grafana/helm-charts/tree/main/charts/grafana#grafana-helm-chart) to automatically create [bundled Dashboards](dashboards) and Grafana Data Sources for each configured Graph Node Store. See keys under `grafana` in [Values](#Values) for configuration options.

## Upgrading

We recommend that you pin the version of the Chart that you deploy. You can use the `--version` flag with `helm install` and `helm upgrade` to specify a chart version constraint.

This project uses [Semantic Versioning](https://semver.org/). Changes to the version of the application (the `appVersion`) that the Chart deploys will generally result in a patch version bump for the Chart. Breaking changes to the Chart or its `values.yaml` interface will be reflected with a major version bump.

We do not recommend that you upgrade the application by overriding `image.tag`. Instead, use the version of the Chart that is built for your desired `appVersion`.

## Values

| Key | Description | Type | Default |
|-----|-------------|------|---------|
 | blockIngestorGroupName | Name of the Graph Node Group that should be the block ingestor. Only the first node instance (with index 0) will be configured as the block ingestor. | string | `"block-ingestor"` |
 | chains | Blockchain configuration for Graph Node | object | `{"mainnet":{"enabled":false,"provider":[{"details":{"features":["archive","traces"],"type":"web3","url":""},"label":"eth-mainnet"},{"details":{"token":"$FIREHOSE_TOKEN_IN_ENV","type":"firehose","url":""},"label":"eth-mainnet-firehose"},{"details":{"token":"$SUBSTREAMS_TOKEN_IN_ENV","type":"substreams","url":""},"label":"eth-mainnet-substreams"}],"shard":"primary"}}` |
 | chains.mainnet | Ethereum Mainnet | object | `{"enabled":false,"provider":[{"details":{"features":["archive","traces"],"type":"web3","url":""},"label":"eth-mainnet"},{"details":{"token":"$FIREHOSE_TOKEN_IN_ENV","type":"firehose","url":""},"label":"eth-mainnet-firehose"},{"details":{"token":"$SUBSTREAMS_TOKEN_IN_ENV","type":"substreams","url":""},"label":"eth-mainnet-substreams"}],"shard":"primary"}` |
 | chains.mainnet.enabled | Enable this configuring graph-node with this chain | bool | `false` |
 | chains.mainnet.provider[0].details.features | Data capabilities this node has | list | `["archive","traces"]` |
 | chains.mainnet.provider[0].details.type | Type of Provider: web3 | string | `"web3"` |
 | chains.mainnet.provider[0].details.url | URL for JSON-RPC endpoint | string | `""` |
 | chains.mainnet.provider[0].label | Label for a JSON-RPC endpoint | string | `"eth-mainnet"` |
 | chains.mainnet.provider[1].details.token | Token to authenticate | string | `"$FIREHOSE_TOKEN_IN_ENV"` |
 | chains.mainnet.provider[1].details.type | Type of Provider: firehose | string | `"firehose"` |
 | chains.mainnet.provider[1].details.url | URL for Firehose  endpoint | string | `""` |
 | chains.mainnet.provider[1].label | Label for a Firehose endpoint | string | `"eth-mainnet-firehose"` |
 | chains.mainnet.provider[2].details.token | Token to authenticate | string | `"$SUBSTREAMS_TOKEN_IN_ENV"` |
 | chains.mainnet.provider[2].details.type | Type of Provider: substreams | string | `"substreams"` |
 | chains.mainnet.provider[2].details.url | URL for Substreams endpoint | string | `""` |
 | chains.mainnet.provider[2].label | Label for a Substreams endpoint | string | `"eth-mainnet-substreams"` |
 | chains.mainnet.shard | The database shard to use for this chain | string | `"primary"` |
 | configTemplate | [Configuration for graph-node](https://github.com/graphprotocol/graph-node/blob/master/docs/config.md) | string | See default template in [values.yaml](values.yaml) |
 | fullnameOverride |  | string | `""` |
 | grafana.dashboards | Enable creation of Grafana dashboards. [Grafana chart](https://github.com/grafana/helm-charts/tree/main/charts/grafana#grafana-helm-chart) must be configured to search this namespace, see `sidecar.dashboards.searchNamespace` | bool | `false` |
 | grafana.dashboardsConfigMapLabel | Must match `sidecar.dashboards.label` value for the [Grafana chart](https://github.com/grafana/helm-charts/tree/main/charts/grafana#grafana-helm-chart) | string | `"grafana_dashboard"` |
 | grafana.dashboardsConfigMapLabelValue | Must match `sidecar.dashboards.labelValue` value for the [Grafana chart](https://github.com/grafana/helm-charts/tree/main/charts/grafana#grafana-helm-chart) | string | `"1"` |
 | grafana.datasources | Enable creation of Grafana Data Sources for each Graph Node store using an init container | bool | `false` |
 | grafana.datasourcesGraphNodeGroupName | Name of the Graph Node group that should be used to create Grafana Data Sources | string | `"block-ingestor"` |
 | grafana.datasourcesSecretLabel | Must match `sidecar.datasources.label` value for the [Grafana chart](https://github.com/grafana/helm-charts/tree/main/charts/grafana#grafana-helm-chart) | string | `"grafana_datasource"` |
 | grafana.datasourcesSecretLabelValue | Must match `sidecar.datasources.labelValue` value for the [Grafana chart](https://github.com/grafana/helm-charts/tree/main/charts/grafana#grafana-helm-chart) | string | `"1"` |
 | graphNodeDefaults | Default values for all Group Node Groups | object | `{"affinity":{},"affinityPresets":{"antiAffinityByHostname":true},"enabled":true,"env":{"IPFS":"","PRIMARY_SUBGRAPH_DATA_PGDATABASE":"","PRIMARY_SUBGRAPH_DATA_PGHOST":"","PRIMARY_SUBGRAPH_DATA_PGPORT":5432},"extraArgs":[],"includeInIndexPools":[],"kind":"StatefulSet","nodeSelector":{},"podAnnotations":{},"podSecurityContext":{"fsGroup":101337,"runAsGroup":101337,"runAsNonRoot":true,"runAsUser":101337},"replicaCount":1,"resources":{},"secretEnv":{"PRIMARY_SUBGRAPH_DATA_PGPASSWORD":{"key":null,"secretName":null},"PRIMARY_SUBGRAPH_DATA_PGUSER":{"key":null,"secretName":null}},"service":{"ports":{"http-admin":8020,"http-metrics":8040,"http-query":8000,"http-queryws":8001,"http-status":8030},"topologyAwareRouting":{"enabled":false},"type":"ClusterIP"},"terminationGracePeriodSeconds":0,"terminationGracePeriodSecondsQueryNodes":60,"tolerations":[]}` |
 | graphNodeDefaults.affinityPresets.antiAffinityByHostname | Create anti-affinity rule to deter scheduling replicas on the same host | bool | `true` |
 | graphNodeDefaults.enabled | Enable the group | bool | `true` |
 | graphNodeDefaults.env | Environment variable defaults for all Graph Node groups | object | `{"IPFS":"","PRIMARY_SUBGRAPH_DATA_PGDATABASE":"","PRIMARY_SUBGRAPH_DATA_PGHOST":"","PRIMARY_SUBGRAPH_DATA_PGPORT":5432}` |
 | graphNodeDefaults.env.IPFS | The URL for your IPFS node | string | `""` |
 | graphNodeDefaults.env.PRIMARY_SUBGRAPH_DATA_PGDATABASE | Name of the primary shard database to use | string | `""` |
 | graphNodeDefaults.env.PRIMARY_SUBGRAPH_DATA_PGHOST | Hostname of the primary shard PostgreSQL server | string | `""` |
 | graphNodeDefaults.env.PRIMARY_SUBGRAPH_DATA_PGPORT | Port for the primary shard PostgreSQL server | int | `5432` |
 | graphNodeDefaults.extraArgs | Additional CLI arguments to pass to Graph Node | list | `[]` |
 | graphNodeDefaults.includeInIndexPools | List of Index Pools to include nodes in the group in | list | `[]` |
 | graphNodeDefaults.kind | Workload kind, as one may want to use Deployment for query-nodes | string | `"StatefulSet"` |
 | graphNodeDefaults.nodeSelector | Specify a [node selector](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/) | object | `{}` |
 | graphNodeDefaults.podAnnotations | Annotations for the `Pod` | object | `{}` |
 | graphNodeDefaults.podSecurityContext | Pod-wide security context | object | `{"fsGroup":101337,"runAsGroup":101337,"runAsNonRoot":true,"runAsUser":101337}` |
 | graphNodeDefaults.replicaCount | The number of nodes to run in the group | int | `1` |
 | graphNodeDefaults.resources | Specify [resource requests and limits](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#requests-and-limits) for each node in the group | object | `{}` |
 | graphNodeDefaults.secretEnv | Environment variable defaults that come from `Secret`s for all Graph Node groups | object | `{"PRIMARY_SUBGRAPH_DATA_PGPASSWORD":{"key":null,"secretName":null},"PRIMARY_SUBGRAPH_DATA_PGUSER":{"key":null,"secretName":null}}` |
 | graphNodeDefaults.secretEnv.PRIMARY_SUBGRAPH_DATA_PGPASSWORD.key | Name of the data key in the secret that contains your PG password | string | `nil` |
 | graphNodeDefaults.secretEnv.PRIMARY_SUBGRAPH_DATA_PGPASSWORD.secretName | Name of the secret that contains your PG password | string | `nil` |
 | graphNodeDefaults.secretEnv.PRIMARY_SUBGRAPH_DATA_PGUSER.key | Name of the data key in the secret that contains your PG username | string | `nil` |
 | graphNodeDefaults.secretEnv.PRIMARY_SUBGRAPH_DATA_PGUSER.secretName | Name of the secret that contains your PG username | string | `nil` |
 | graphNodeDefaults.service.ports.http-admin | Service Port to expose Graph Node Admin endpoint on | int | `8020` |
 | graphNodeDefaults.service.ports.http-metrics | Service Port to expose Graph Node Metrics endpoint on | int | `8040` |
 | graphNodeDefaults.service.ports.http-query | Service Port to expose Graph Node Query endpoint on | int | `8000` |
 | graphNodeDefaults.service.ports.http-queryws | Service Port to expose Graph Node Websocket Query endpoint on | int | `8001` |
 | graphNodeDefaults.service.ports.http-status | Service Port to expose Graph Node Status endpoint on | int | `8030` |
 | graphNodeDefaults.terminationGracePeriodSeconds | Amount of time to wait before force-killing the Erigon process, graph-node ignores SIGTERM (check here: https://github.com/graphops/launchpad-charts/issues/287, and here: https://github.com/graphprotocol/graph-node/issues/4712) | int | `0` |
 | graphNodeDefaults.terminationGracePeriodSecondsQueryNodes | terminationGracePeriodSeconds specifically for query nodes, which will be identified by the env.node_role parameter defined in the GraphNodeGroups section. | int | `60` |
 | graphNodeDefaults.tolerations | Specify [tolerations](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/) | list | `[]` |
 | graphNodeGroups | Groups of Graph Nodes to deploy | object | `{"block-ingestor":{"enabled":true,"env":{"node_role":"index-node"},"includeInIndexPools":[],"replicaCount":1},"index":{"enabled":true,"env":{"node_role":"index-node"},"includeInIndexPools":["default"],"replicaCount":1},"query":{"enabled":true,"env":{"node_role":"query-node"},"replicaCount":1}}` |
 | image.pullPolicy |  | string | `"IfNotPresent"` |
 | image.repository | Image for Graph Node | string | `"graphprotocol/graph-node"` |
 | image.tag | Overrides the image tag | string | Chart.appVersion |
 | imagePullSecrets | Pull secrets required to fetch the Image | list | `[]` |
 | nameOverride |  | string | `""` |
 | prometheus.serviceMonitors.enabled | Enable monitoring by creating `ServiceMonitor` CRDs ([prometheus-operator](https://github.com/prometheus-operator/prometheus-operator)) | bool | `false` |
 | prometheus.serviceMonitors.interval |  | string | `nil` |
 | prometheus.serviceMonitors.labels |  | object | `{}` |
 | prometheus.serviceMonitors.relabelings |  | list | `[]` |
 | prometheus.serviceMonitors.scrapeTimeout |  | string | `nil` |
 | rbac.create | Specifies whether RBAC resources are to be created | bool | `true` |
 | rbac.rules[0].apiGroups[0] |  | string | `""` |
 | rbac.rules[0].resources[0] |  | string | `"secrets"` |
 | rbac.rules[0].verbs[0] |  | string | `"get"` |
 | rbac.rules[0].verbs[1] |  | string | `"create"` |
 | rbac.rules[0].verbs[2] |  | string | `"patch"` |
 | serviceAccount.annotations | Annotations to add to the service account | object | `{}` |
 | serviceAccount.create | Specifies whether a service account should be created | bool | `true` |
 | serviceAccount.name | The name of the service account to use. If not set and create is true, a name is generated using the fullname template | string | `""` |
 | store | Store configuration for Graph Node | object | `{"primary":{"connection":"postgresql://${PRIMARY_SUBGRAPH_DATA_PGUSER}:${PRIMARY_SUBGRAPH_DATA_PGPASSWORD}@${PRIMARY_SUBGRAPH_DATA_PGHOST}:${PRIMARY_SUBGRAPH_DATA_PGPORT}/${PRIMARY_SUBGRAPH_DATA_PGDATABASE}","enabled":true}}` |
 | store.primary.connection | PostgreSQL connection string for primary shard | string | `"postgresql://${PRIMARY_SUBGRAPH_DATA_PGUSER}:${PRIMARY_SUBGRAPH_DATA_PGPASSWORD}@${PRIMARY_SUBGRAPH_DATA_PGHOST}:${PRIMARY_SUBGRAPH_DATA_PGPORT}/${PRIMARY_SUBGRAPH_DATA_PGDATABASE}"` |
 | store.primary.enabled | Enable this store for Graph Node | bool | `true` |

## Contributing

We welcome and appreciate your contributions! Please see the [Contributor Guide](/CONTRIBUTING.md), [Code Of Conduct](/CODE_OF_CONDUCT.md) and [Security Notes](/SECURITY.md) for this repository.

## See also

- [Erigon](../erigon)
- [Proxyd](../proxyd)
