# Heimdall Helm Chart

Deploy and scale [Heimdall](https://github.com/maticnetwork/heimdall) inside Kubernetes with ease

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) ![Version: 1.1.2](https://img.shields.io/badge/Version-1.1.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v0.3.0](https://img.shields.io/badge/AppVersion-v0.3.0-informational?style=flat-square)

## Features

- Actively maintained by [GraphOps](https://graphops.xyz) and contributors
- Deploys a scalable pool of `statefulset` instances, with auto-scaling support
- Strong security defaults (non-root execution, ready-only root filesystem, drops all capabilities)
- Readiness checks to ensure traffic only hits `Pod`s that are healthy and ready to serve requests
- Support for `PodMonitor`s to configure Prometheus to scrape metrics ([prometheus-operator](https://github.com/prometheus-operator/prometheus-operator))
- Support for configuring Grafana dashboards for polygon ([grafana](https://github.com/grafana/helm-charts/tree/main/charts/grafana))

## Quickstart

To install the chart with the release name `my-release`:

```console
$ helm repo add graphops http://graphops.github.io/helm-charts
$ helm install my-release graphops/heimdall
```

Once the release is installed, heimdall will begin syncing from snapshot if the following was specified:
```fromSnapshot:
    # -- Enable initialising Heimdall from a remote Snapshot
    enabled: true
    # -- URL to snapshot to download and extract, see [here](https://snapshots.matic.today)
    snapshotUrl:
```
You can use `kubectl logs` to monitor the download status. See the Values section to install Prometheus `PodMonitor`s and a Grafana dashboard.

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
 | grafana.dashboardsConfigMapLabelValue | Must match `sidecar.dashboards.labelValue` value for the [Grafana chart](https://github.com/grafana/helm-charts/tree/main/charts/grafana#grafana-helm-chart) | string | `""` |
 | heimdall.affinity |  | object | `{}` |
 | heimdall.affinityPresets.antiAffinityByHostname | Configure anti-affinity rules to prevent multiple Heimdall instances on the same host | bool | `true` |
 | heimdall.enabled | Enable creation of `StatefulSet` for Heimdall | bool | `true` |
 | heimdall.env | Environment variables to set in key/value format | object | `{"BOOTNODES":"","ETH1_RPC_URL":""}` |
 | heimdall.extraArgs | Additional CLI arguments to pass to Heimdall | list | `[]` |
 | heimdall.fromSnapshot.enabled | Enable initialising Heimdall from a remote Snapshot | bool | `false` |
 | heimdall.fromSnapshot.snapshotUrl | URL to snapshot to download and extract, see [here](https://snapshots.matic.today) | string | `nil` |
 | heimdall.image.pullPolicy |  | string | `"IfNotPresent"` |
 | heimdall.image.repository | Image for Heimdall | string | `"maticnetwork/heimdall"` |
 | heimdall.image.tag |  | string | `"v0.3.0"` |
 | heimdall.nodeSelector |  | object | `{}` |
 | heimdall.podAnnotations | Annotations for the `Pod` | object | `{}` |
 | heimdall.podSecurityContext | Pod-wide security context | object | `{"runAsNonRoot":false}` |
 | heimdall.resources |  | object | `{}` |
 | heimdall.restServer | Options for Heimdall rest-server sidecar | object | `{"extraArgs":[],"resources":{}}` |
 | heimdall.service.ports.http-rest |  | int | `1317` |
 | heimdall.service.ports.http-trpc |  | int | `26657` |
 | heimdall.service.type |  | string | `"ClusterIP"` |
 | heimdall.tolerations |  | list | `[]` |
 | heimdall.volumeClaimSpec | [PersistentVolumeClaimSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.23/#persistentvolumeclaimspec-v1-core) for heimdall storage | object | `{"accessModes":["ReadWriteOnce"],"resources":{"requests":{"storage":"300Gi"}},"storageClassName":null}` |
 | heimdall.volumeClaimSpec.resources.requests.storage | The amount of disk space to provision for Heimdall | string | `"300Gi"` |
 | heimdall.volumeClaimSpec.storageClassName | The storage class to use when provisioning a persistent volume for heimdall | string | `nil` |
 | nameOverride |  | string | `""` |
 | network | Specifies the heimdall network instance, one of: `mainnet`, `testnet` | string | `"mainnet"` |
 | prometheus.serviceMonitors.enabled | Enable monitoring by creating `PodMonitor` CRDs ([prometheus-operator](https://github.com/prometheus-operator/prometheus-operator)) | bool | `false` |
 | prometheus.serviceMonitors.interval |  | string | `nil` |
 | prometheus.serviceMonitors.labels |  | object | `{}` |
 | prometheus.serviceMonitors.relabelings |  | list | `[]` |
 | prometheus.serviceMonitors.scrapeTimeout |  | string | `nil` |
 | serviceAccount.annotations | Annotations to add to the service account | object | `{}` |
 | serviceAccount.create | Specifies whether a service account should be created | bool | `true` |
 | serviceAccount.name | The name of the service account to use. If not set and create is true, a name is generated using the fullname template | string | `""` |

## Contributing

We welcome and appreciate your contributions! Please see the [Contributor Guide](/CONTRIBUTING.md), [Code Of Conduct](/CODE_OF_CONDUCT.md) and [Security Notes](/SECURITY.md) for this repository.