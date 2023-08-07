# Subgraph-Radio Helm Chart

Deploy a Graphcast Subgraph Radio into your Kubernetes stack

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) ![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.1.2](https://img.shields.io/badge/AppVersion-0.1.2-informational?style=flat-square)

## Introduction

The [Subgraph-Radio](https://docs.graphops.xyz/graphcast/radios/subgraph-radio) a Graphcast Radio focused on sending gossips about particular subgraphs on a P2P network.

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
$ helm install my-release graphops/subgraph-radio
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
 | env.GRAPHCAST_NETWORK | Supported Graphcast networks: mainnet, testnet | string | `"mainnet"` |
 | env.GRAPH_NODE_STATUS_ENDPOINT | Graph Node endpoint for indexing statuses | string | `""` |
 | env.INDEXER_ADDRESS | Indexer address | string | `""` |
 | env.NETWORK_SUBGRAPH | Subgraph endpoint to The Graph network subgraph | string | `"https://api.thegraph.com/subgraphs/name/graphprotocol/graph-network-mainnet"` |
 | env.REGISTRY_SUBGRAPH | Subgraph endpoint to the Graphcast Registry | string | `"https://api.thegraph.com/subgraphs/name/hopeyen/graphcast-registry-mainnet"` |
 | env.RUST_LOG | Comma separated static list of content topics to subscribe to | string | `"info,hyper=off,graphcast_sdk=info,waku_bindings=off,subgraph_radio=info"` |
 | extraArgs | Additional CLI arguments to pass to `indexer-agent` | list | `[]` |
 | fullnameOverride |  | string | `""` |
 | image | Image for indexer-agent | object | `{"pullPolicy":"IfNotPresent","repository":"ghcr.io/graphops/subgraph-radio","tag":""}` |
 | image.tag | Overrides the image tag | string | Chart.appVersion |
 | imagePullSecrets | Pull secrets required to fetch the Image | list | `[]` |
 | nameOverride |  | string | `""` |
 | nodeSelector |  | object | `{}` |
 | p2pNodePort.discv5Port | Discv5 NodePort to be used. Must be unique. | int | `9000` |
 | p2pNodePort.enabled | Expose P2P port via NodePort | bool | `false` |
 | p2pNodePort.initContainer.image.pullPolicy | Container pull policy | string | `"IfNotPresent"` |
 | p2pNodePort.initContainer.image.repository | Container image to fetch nodeport information | string | `"lachlanevenson/k8s-kubectl"` |
 | p2pNodePort.initContainer.image.tag | Container tag | string | `"v1.21.3"` |
 | p2pNodePort.wakuPort | Waku NodePort to be used. Must be unique. | int | `60000` |
 | podAnnotations | Annotations for the `Pod` | object | `{}` |
 | podSecurityContext | Pod-wide security context | object | `{}` |
 | prometheus.serviceMonitors.enabled | Enable monitoring by creating `ServiceMonitor` CRDs ([prometheus-operator](https://github.com/prometheus-operator/prometheus-operator)) | bool | `false` |
 | prometheus.serviceMonitors.interval |  | string | `nil` |
 | prometheus.serviceMonitors.labels |  | object | `{}` |
 | prometheus.serviceMonitors.relabelings |  | list | `[]` |
 | prometheus.serviceMonitors.scrapeTimeout |  | string | `nil` |
 | resources |  | object | `{}` |
 | secretEnv |  | object | `{}` |
 | service.ports.http-api | Service Port to expose JSON-RPC interface on | int | `7700` |
 | service.ports.http-metrics | Service Port to expose Prometheus metrics on | int | `2384` |
 | service.type |  | string | `"ClusterIP"` |
 | serviceAccount.annotations | Annotations to add to the service account | object | `{}` |
 | serviceAccount.create | Specifies whether a service account should be created | bool | `true` |
 | serviceAccount.name | The name of the service account to use. If not set and create is true, a name is generated using the fullname template | string | `""` |
 | terminationGracePeriodSeconds | Amount of time to wait before force-killing the process | int | `10` |
 | tolerations |  | list | `[]` |
 | volumeClaimSpec.accessModes[0] |  | string | `"ReadWriteOnce"` |
 | volumeClaimSpec.resources.requests.storage | The amount of disk space to provision | string | `"50Gi"` |
 | volumeClaimSpec.storageClassName | The storage class to use when provisioning a persistent volume | string | `"openebs-zfs-localpv-compressed-128k"` |

## Contributing

We welcome and appreciate your contributions! Please see the [Contributor Guide](/CONTRIBUTING.md), [Code Of Conduct](/CODE_OF_CONDUCT.md) and [Security Notes](/SECURITY.md) for this repository.
