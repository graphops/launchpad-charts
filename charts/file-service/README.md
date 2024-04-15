# File-Service Helm Chart

Deploy a file hosting service server in to your Kubernetes stack

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) ![Version: 0.0.1](https://img.shields.io/badge/Version-0.0.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: sha-1155f59](https://img.shields.io/badge/AppVersion-sha--1155f59-informational?style=flat-square)

## Introduction

[Subgraph Radio](https://docs.graphops.xyz/graphcast/radios/subgraph-radio) is a Graphcast Radio focused on Subgraphs.

## Chart Features

- Actively maintained by [GraphOps](https://graphops.xyz) [and contributors](https://github.com/graphops/launchpad-charts/graphs/contributors)
- Strong security defaults (non-root execution, ready-only root filesystem, drops all capabilities)
- Readiness checks to ensure traffic only hits `Pod`s that are healthy and ready to serve requests
- Support for `ServiceMonitor`s to configure Prometheus to scrape metrics ([prometheus-operator](https://github.com/prometheus-operator/prometheus-operator))
- Support for configuring Grafana dashboards ([grafana](https://github.com/grafana/helm-charts/tree/main/charts/grafana))

## Enabling inbound P2P dials

By default, your subgraph-radio release will not have an internet-accessible port for P2P traffic. This makes it harder for your node to establish a strong set of peers because you cannot accept inbound P2P dials. To change this behaviour, you can set `p2pNodePort.enabled` to `true`. This will make your node accessible via the Internet using a `Service` of type `NodePort`. When using `p2pNodePort.enabled`, the exposed IP address on your arbitrum ENR record will be the "External IP" of the Node where the Pod is running. When using this mode, `replicaCount` will be locked to `1`.

```yaml
# values.yaml

p2pNodePort:
  enabled: true
  port: 31000 # Must be globally unique and available on the host
```

## Quickstart

To install the chart with the release name `my-release`:

```console
$ helm repo add graphops http://graphops.github.io/launchpad-charts
$ helm install my-release graphops/file-service
```

## Upgrading

We recommend that you pin the version of the Chart that you deploy. You can use the `--version` flag with `helm install` and `helm upgrade` to specify a chart version constraint.

This project uses [Semantic Versioning](https://semver.org/). Changes to the version of the application (the `appVersion`) that the Chart deploys will generally result in a patch version bump for the Chart. Breaking changes to the Chart or its `values.yaml` interface will be reflected with a major version bump.

We do not recommend that you upgrade the application by overriding `image.tag`. Instead, use the version of the Chart that is built for your desired `appVersion`.

## Values

| Key | Description | Type | Default |
|-----|-------------|------|---------|
 | affinity |  | object | `{}` |
 | aliases | Set custom aliases for preconfigured commands in your environment | object | `{}` |
 | common.database.postgresUrl |  | string | `"postgres://fileservice:XXXXXX@file-service-database:5432/fileservice"` |
 | common.escrowSubgraph.queryUrl |  | string | `"https://localhost:8080/escrow"` |
 | common.escrowSubgraph.serveSubgraph |  | bool | `false` |
 | common.escrowSubgraph.syncingInterval |  | int | `60` |
 | common.graphNetwork.chainId |  | int | `411614` |
 | common.graphNetwork.id |  | int | `1` |
 | common.graphNode.queryBaseUrl |  | string | `"http://localhost:8000"` |
 | common.graphNode.statusUrl |  | string | `"http://localhost:8030/graphql"` |
 | common.indexer.address |  | string | `"0xdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef"` |
 | common.indexer.operatorMnemonic |  | string | `"ice palace drill gadget biology glow tray equip heavy wolf toddler menu"` |
 | common.networkSubgraph.queryUrl |  | string | `"https://localhost:8080/network"` |
 | common.networkSubgraph.serveAuthToken |  | string | `"it-is-serving-network-subgraph-data"` |
 | common.networkSubgraph.serveSubgraph |  | bool | `false` |
 | common.networkSubgraph.syncingInterval |  | int | `60` |
 | common.scalar.chainId |  | int | `421614` |
 | common.scalar.receiptsVerifierAddress |  | string | `"0xfC24cE7a4428A6B89B52645243662A02BA734ECF"` |
 | common.server.freeQueryAuthToken |  | string | `"free-token"` |
 | common.server.urlPrefix |  | string | `"/"` |
 | commonEscrowSubgraphConfigTemplate |  | string | `"{{- with .Values.common.escrowSubgraph }}\nquery_url = {{ .queryUrl \| quote }}\nsyncing_interval = {{ .syncingInterval \| toJson }}\nserve_subgraph = {{ .serveSubgraph \| toJson }}\n{{- end }}\n"` |
 | commonGraphNetworkConfigTemplate |  | string | `"{{- with .Values.common.graphNetwork }}\nid = {{ .id \| toJson }}\nchain_id = {{ .chainId \| toJson }}\n{{- end }}\n"` |
 | commonGraphNodeConfigTemplate |  | string | `"{{- with .Values.common.graphNode }}\nstatus_url = {{ .statusUrl \| quote }}\nquery_base_url = {{ .queryBaseUrl \| quote }}\n{{- end }}\n"` |
 | commonIndexerConfigTemplate |  | string | `"{{- with .Values.common.indexer }}\nindexer_address = {{ .address \| quote }}\noperator_mnemonic = {{ .operatorMnemonic \| quote }}\n{{- end }}\n"` |
 | commonNetworkSubgraphConfigTemplate |  | string | `"{{- with .Values.common.networkSubgraph }}\nquery_url = {{ .queryUrl \| quote }}\nsyncing_interval = {{ .syncingInterval \| toJson }}\nserve_subgraph = {{ .serveSubgraph \| toJson }}\nserve_auth_token = {{ .serveAuthToken \| quote }}\n{{- end }}\n"` |
 | commonScalarConfigTemplate |  | string | `"{{- with .Values.common.scalar }}\nchain_id = {{ .chainId \| toJson }}\nreceipts_verifier_address = {{ .receiptsVerifierAddress \| quote }}\n{{- end }}\n"` |
 | commonServerConfigTemplate |  | string | `"{{- with .Values.common.server }}\nurl_prefix = {{ .urlPrefix \| quote }}\nfree_query_auth_token = {{ .freeQueryAuthToken \| quote }}\n{{- end }}\nhost_and_port = {{ printf \"%v:%v\" \"0.0.0.0\" (index .Values.service.ports \"http-api\" ) \| quote }}\nmetrics_host_and_port = {{ printf \"%v:%v\" \"0.0.0.0\" ( index .Values.service.ports \"http-metrics\" ) \| quote }}\n"` |
 | configTemplate | The configuration template that is rendered by Helm | string | See default template in [values.yaml](values.yaml) |
 | env |  | object | `{}` |
 | extraArgs | Additional CLI arguments to pass to `indexer-agent` | list | `[]` |
 | fullnameOverride |  | string | `""` |
 | image | Image for file-service | object | `{"pullPolicy":"IfNotPresent","repository":"ghcr.io/graphops/file-service","tag":""}` |
 | image.tag | Overrides the image tag | string | Chart.appVersion |
 | imagePullSecrets | Pull secrets required to fetch the Image | list | `[]` |
 | nameOverride |  | string | `""` |
 | nodeSelector |  | object | `{}` |
 | podAnnotations | Annotations for the `Pod` | object | `{}` |
 | podSecurityContext | Pod-wide security context | object | `{}` |
 | prometheus.serviceMonitors.enabled | Enable monitoring by creating `ServiceMonitor` CRDs ([prometheus-operator](https://github.com/prometheus-operator/prometheus-operator)) | bool | `false` |
 | prometheus.serviceMonitors.interval |  | string | `nil` |
 | prometheus.serviceMonitors.labels |  | object | `{}` |
 | prometheus.serviceMonitors.relabelings |  | list | `[]` |
 | prometheus.serviceMonitors.scrapeTimeout |  | string | `nil` |
 | rbac.clusterRules | Required ClusterRole rules | list | See `values.yaml` |
 | rbac.create | Specifies whether RBAC resources are to be created | bool | `true` |
 | rbac.rules | Required ClusterRole rules | list | See `values.yaml` |
 | resources |  | object | `{}` |
 | secretEnv |  | object | `{}` |
 | server.adminAuthToken |  | string | `"kueen"` |
 | server.adminHost |  | string | `"0.0.0.0"` |
 | server.defaultPricePerByte |  | int | `1` |
 | server.ipfsGateway |  | string | `"https://ipfs.network.thegraph.com"` |
 | server.logFormat |  | string | `"Pretty"` |
 | serverConfigTemplate | TOML configuration for redis | string | `"\ninitial_bundles = [\n    \"QmVPPWWaraEvoc4LCrYXtMbL13WPNbnuXV2yo7W8zexFGq:\",\n    \"QmeD3dRVV6Gs84TRwiNj3tLt9mBEMVqy3GoWm7WN8oDzGz:\",\n    \"QmTSwj1BGkkmVSnhw6uEGkcxGZvP5nq4pDhzHjwJvsQC2Z:\"\n]\ninitial_files = []\nadmin_auth_token = {{ .Values.server.adminAuthToken \| quote }}\nadmin_host_and_port = {{ printf \"%v:%v\" \"0.0.0.0\" ( index .Values.service.ports \"http-admin\" ) \| quote }}\ndefault_price_per_byte = {{ .Values.server.defaultPricePerByte \| toJson }}\nipfs_gateway = {{ .Values.server.ipfsGateway \| quote }}\nlog_format = {{ .Values.server.logFormat \| quote }}\n{{- with .Values.storage.filesystem }}\n{{- if .enabled }}\n[server.storage_method.LocalFiles]\nmain_dir = {{ .dir \| quote }}\n{{- end }}\n{{- end }}\n{{- with .Values.storage.objectStorage }}\n{{- if .enabled }}\n[server.storage_method.ObjectStorage]\nregion = {{ .region \| quote }}\nbucket = {{ .bucket \| quote }}\naccess_key_id = {{ .accessKeyId \| toJson }}\nsecret_key = {{ .secretAccessKey \| toJson }}\nendpoint = {{ .endpoint \| quote }}\n{{- end }}\n{{- end }}\n"` |
 | service.ports.http-admin | Service Port to expose Admin API on | int | `5665` |
 | service.ports.http-api | Service Port to expose service interface on | int | `5679` |
 | service.ports.http-metrics | Service Port to expose metrics on | int | `5680` |
 | service.topologyAwareRouting.enabled |  | bool | `false` |
 | service.type |  | string | `"ClusterIP"` |
 | serviceAccount.annotations | Annotations to add to the service account | object | `{}` |
 | serviceAccount.create | Specifies whether a service account should be created | bool | `true` |
 | serviceAccount.name | The name of the service account to use. If not set and create is true, a name is generated using the fullname template | string | `""` |
 | storage.filesystem.dir |  | string | `"./../example-file"` |
 | storage.filesystem.enabled |  | bool | `false` |
 | storage.filesystem.existingVolumeClaim |  | string | `""` |
 | storage.objectStorage.accessKeyId |  | string | `""` |
 | storage.objectStorage.bucket |  | string | `"contain-texture-dragon"` |
 | storage.objectStorage.enabled |  | bool | `true` |
 | storage.objectStorage.endpoint |  | string | `"https://ams3.digitaloceanspaces.com"` |
 | storage.objectStorage.region |  | string | `"ams3"` |
 | storage.objectStorage.secretAccessKey |  | string | `""` |
 | terminationGracePeriodSeconds | Amount of time to wait before force-killing the process | int | `10` |
 | tolerations |  | list | `[]` |

## Contributing

We welcome and appreciate your contributions! Please see the [Contributor Guide](/CONTRIBUTING.md), [Code Of Conduct](/CODE_OF_CONDUCT.md) and [Security Notes](/SECURITY.md) for this repository.
