# Graph-Toolbox Helm Chart

Deploy a preconfigured toolbox container for to be used alongside the Graph Network Indexer stack

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) ![Version: 0.1.4](https://img.shields.io/badge/Version-0.1.4-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: main](https://img.shields.io/badge/AppVersion-main-informational?style=flat-square)

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
$ helm install my-release graphops/graph-toolbox
```

## Configuring graph-toolbox

...

## Upgrading

We recommend that you pin the version of the Chart that you deploy. You can use the `--version` flag with `helm install` and `helm upgrade` to specify a chart version constraint.

This project uses [Semantic Versioning](https://semver.org/). Changes to the version of the application (the `appVersion`) that the Chart deploys will generally result in a patch version bump for the Chart. Breaking changes to the Chart or its `values.yaml` interface will be reflected with a major version bump.

We do not recommend that you upgrade the application by overriding `image.tag`. Instead, use the version of the Chart that is built for your desired `appVersion`.

## Values

| Key | Description | Type | Default |
|-----|-------------|------|---------|
 | affinity |  | object | `{}` |
 | aliases | Set custom aliases for preconfigured commands in your environment | object | `{}` |
 | config | [required] Configuration for Toolbox to connect to dependencies | object | `{"graphNode":{"adminApiUrl":null,"existingConfigMap":{"configFileKey":null,"configMapName":null}},"indexer":{"indexerAgentManagementUrl":null}}` |
 | config.graphNode.adminApiUrl | URL to Graph Node Admin API | string | `nil` |
 | config.graphNode.existingConfigMap.configFileKey | The name of the data key in the ConfigMap that contains your config.toml | string | `nil` |
 | config.graphNode.existingConfigMap.configMapName | The name of the ConfigMap that contains your Graph Node config.toml | string | `nil` |
 | config.indexer.indexerAgentManagementUrl | URL to Indexer Agent Management Server | string | `nil` |
 | env |  | object | `{}` |
 | extraArgs | Additional CLI arguments to pass to `indexer-agent` | list | `[]` |
 | fullnameOverride |  | string | `""` |
 | image | Image for indexer-agent | object | `{"pullPolicy":"IfNotPresent","repository":"ghcr.io/graphops/docker-builds/graph-toolbox","tag":""}` |
 | image.tag | Overrides the image tag | string | Chart.appVersion |
 | imagePullSecrets | Pull secrets required to fetch the Image | list | `[]` |
 | nameOverride |  | string | `""` |
 | nodeSelector |  | object | `{}` |
 | podAnnotations | Annotations for the `Pod` | object | `{}` |
 | podSecurityContext | Pod-wide security context | object | `{}` |
 | resources |  | object | `{}` |
 | secretEnv |  | object | `{}` |
 | serviceAccount.annotations | Annotations to add to the service account | object | `{}` |
 | serviceAccount.create | Specifies whether a service account should be created | bool | `true` |
 | serviceAccount.name | The name of the service account to use. If not set and create is true, a name is generated using the fullname template | string | `""` |
 | startupScript | Inject custom bash to run when the container starts up. You can customise the environment. | advanced | `nil` |
 | terminationGracePeriodSeconds | Amount of time to wait before force-killing the process | int | `10` |
 | tolerations |  | list | `[]` |

## Contributing

We welcome and appreciate your contributions! Please see the [Contributor Guide](/CONTRIBUTING.md), [Code Of Conduct](/CODE_OF_CONDUCT.md) and [Security Notes](/SECURITY.md) for this repository.
