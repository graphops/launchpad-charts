# Subgraph-Availability-Oracle Helm Chart

Deploy a Subgraph Availability Oracle into your Kubernetes stack

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) ![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: latest](https://img.shields.io/badge/AppVersion-latest-informational?style=flat-square)

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
$ helm install my-release graphops/subgraph-availability-oracle
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
 | env.ORACLE_IPFS | URL for IPFS node | string | `""` |
 | env.ORACLE_SUBGRAPH | URL for Oracle Subgraph | string | `""` |
 | env.REWARDS_MANAGER_CONTRACT | The address of the Rewards Manager contract | string | `""` |
 | env.RPC_URL | URL for the JSON-RPC endpoint | string | `""` |
 | env.RUST_LOG | RUST_LOG level | string | `"info"` |
 | extraArgs | Additional CLI arguments to pass to `indexer-agent` | list | `[]` |
 | fullnameOverride |  | string | `""` |
 | image | Image for subgraph-radio | object | `{"pullPolicy":"IfNotPresent","repository":"ghcr.io/graphprotocol/availability-oracle","tag":""}` |
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
 | secretEnv.ORACLE_SIGNING_KEY.key | Name of the data key in the secret that contains your Oracle Secret Key | string | `nil` |
 | secretEnv.ORACLE_SIGNING_KEY.secretName | Name of the secret that contains your Oracle Signing Key | string | `nil` |
 | service.ports.http-metrics | Service Port to expose Prometheus metrics on | int | `8090` |
 | service.topologyAwareRouting.enabled |  | bool | `false` |
 | service.type |  | string | `"ClusterIP"` |
 | serviceAccount.annotations | Annotations to add to the service account | object | `{}` |
 | serviceAccount.create | Specifies whether a service account should be created | bool | `true` |
 | serviceAccount.name | The name of the service account to use. If not set and create is true, a name is generated using the fullname template | string | `""` |
 | terminationGracePeriodSeconds | Amount of time to wait before force-killing the process | int | `10` |
 | tolerations |  | list | `[]` |

## Contributing

We welcome and appreciate your contributions! Please see the [Contributor Guide](/CONTRIBUTING.md), [Code Of Conduct](/CODE_OF_CONDUCT.md) and [Security Notes](/SECURITY.md) for this repository.
