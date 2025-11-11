# Heimdall-V2 Helm Chart

Deploy and scale [Heimdall-v2](https://github.com/0xPolygon/heimdall-v2) inside Kubernetes with ease

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) ![Version: 0.0.8](https://img.shields.io/badge/Version-0.0.8-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.4.3](https://img.shields.io/badge/AppVersion-0.4.3-informational?style=flat-square)

## Features

- Actively maintained by [GraphOps](https://graphops.xyz) and contributors
- Deploys a scalable pool of `statefulset` instances, with auto-scaling support
- Strong security defaults (non-root execution, ready-only root filesystem, drops all capabilities)
- Readiness checks to ensure traffic only hits `Pod`s that are healthy and ready to serve requests
- Support for `PodMonitor`s to configure Prometheus to scrape metrics ([prometheus-operator](https://github.com/prometheus-operator/prometheus-operator))
- Support for configuring Grafana dashboards for polygon ([grafana](https://github.com/grafana/helm-charts/tree/main/charts/grafana))
 - P2P exposure via NodePort or LoadBalancer with matching container ports

## Quickstart

To install the chart with the release name `my-release`:

```console
$ helm repo add graphops http://graphops.github.io/launchpad-charts
$ helm install my-release graphops/heimdall-v2
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
 | grafana.operatorDashboards | Create GrafanaDashboard CRDs via Grafana Operator from files in `dashboards/` | object | `{"allowCrossNamespaceImport":false,"annotations":{},"enabled":false,"extraSpec":{},"folder":"","folderUID":"","instanceSelector":{"matchLabels":{}},"labels":{},"namespace":"","resyncPeriod":"","suspend":false,"uid":""}` |
 | grafana.operatorDashboards.allowCrossNamespaceImport | Allow matching Grafana instances outside current namespace | bool | `false` |
 | grafana.operatorDashboards.extraSpec | Additional spec fields to merge into GrafanaDashboard.spec | object | `{}` |
 | grafana.operatorDashboards.folder | Optional folder metadata | string | `""` |
 | grafana.operatorDashboards.instanceSelector | Selector to match Grafana instances managed by the operator | object | `{"matchLabels":{}}` |
 | grafana.operatorDashboards.labels | Extra labels and annotations on the GrafanaDashboard resources | object | `{}` |
 | grafana.operatorDashboards.namespace | Optional target namespace for the GrafanaDashboard CRDs (defaults to release namespace) | string | `""` |
 | grafana.operatorDashboards.resyncPeriod | Operator sync behavior | string | `""` |
 | heimdall.affinity |  | object | `{}` |
 | heimdall.affinityPresets.antiAffinityByHostname | Configure anti-affinity rules to prevent multiple Heimdall instances on the same host | bool | `true` |
 | heimdall.config.borRpcUrl | Bor RPC address | string | `""` |
 | heimdall.config.chainId | Override chain_id - Optional, defaults are provided for each network (heimdallv2-137, heimdallv2-80002) | string | `""` |
 | heimdall.config.corsAllowedOrigins | CORS Allowed Origins | string | `"[\"*\"]"` |
 | heimdall.config.downloadGenesis.enabled | Enable downloading the gensis file at init | bool | `true` |
 | heimdall.config.downloadGenesis.genesisSha512 | SHA512 for the Genesis URL file - Specify this if you set a genesisUrl above | string | `""` |
 | heimdall.config.downloadGenesis.genesisUrl | Override URL for the Genesis file - Optional, defaults are provided for mainnet and amoy | string | `""` |
 | heimdall.config.ethRpcUrl | Ethereum RPC address | string | `""` |
 | heimdall.config.extraArgs | Additional CLI arguments to pass to Heimdall | list | `[]` |
 | heimdall.config.fromSnapshot.enabled | Enable initialising Heimdall from a remote Snapshot | bool | `false` |
 | heimdall.config.fromSnapshot.snapshotUrl | URL to snapshot to download and extract, see [here](https://docs.polygon.technology/pos/how-to/snapshots/) | string | `""` |
 | heimdall.config.logFormat | Logs format | string | `"json"` |
 | heimdall.config.logLevel | Log level setup | string | `"info"` |
 | heimdall.config.metrics.enabled | Enable metrics | bool | `true` |
 | heimdall.config.name | Override moniker - Optional, default {{ .Release.Name }} | string | `""` |
 | heimdall.config.network | Specifies the heimdall network instance, one of: `mainnet`, `amoy` | string | `"mainnet"` |
 | heimdall.config.peers | Override persistent peers - Optional, defaults are provided for each network | string | `""` |
 | heimdall.config.seeds | Override seed nodes - Optional, defaults are provided for each network | string | `""` |
 | heimdall.enabled | Enable creation of `StatefulSet` for Heimdall | bool | `true` |
 | heimdall.env | Environment variables to set in key/value format | object | `{}` |
 | heimdall.image.pullPolicy |  | string | `"IfNotPresent"` |
 | heimdall.image.repository | Image for Heimdall | string | `"0xpolygon/heimdall-v2"` |
 | heimdall.image.tag | Overrides the image tag | string | Chart.appVersion |
 | heimdall.nodeSelector |  | object | `{}` |
 | heimdall.p2p.port | P2P listen port used by BOTH the container and the P2P Service (regardless of Service type).    Notes:      - LoadBalancer: the Service exposes this port and targets the container on the same port      - NodePort: the Service uses this value as the nodePort; ensure it is allowed by cluster policy and available      - Choose a value in your cluster’s NodePort range (typically 30000–32767) | int | `31000` |
 | heimdall.p2p.service.advertiseIP | IP address to explicitly advertise on the P2P network (overrides autodetection and LB IP) | string | `""` |
 | heimdall.p2p.service.annotations | Annotations to add to the P2P Service (useful for cloud LBs) | object | `{}` |
 | heimdall.p2p.service.enabled | Enable creation of a P2P Service | bool | `false` |
 | heimdall.p2p.service.externalIPs | Fixed external IPs to bind the Service to (works for NodePort or LoadBalancer; requires upstream routing) | list | `[]` |
 | heimdall.p2p.service.externalTrafficPolicy | External traffic policy for NodePort/LoadBalancer | string | `"Local"` |
 | heimdall.p2p.service.labels | Additional labels to add to the P2P Service | object | `{}` |
 | heimdall.p2p.service.loadBalancerIP | When using a LoadBalancer and your cloud supports it, set a specific LB IP | string | `""` |
 | heimdall.p2p.service.loadBalancerSourceRanges | Restrict which source ranges can access the LoadBalancer (CIDRs) | list | `[]` |
 | heimdall.p2p.service.type | Service type for P2P exposure (NodePort or LoadBalancer) | string | `"NodePort"` |
 | heimdall.p2pNodePort.enabled | Expose P2P port via NodePort | bool | `false` |
 | heimdall.p2pNodePort.initContainer.image.pullPolicy | Container pull policy | string | `"IfNotPresent"` |
 | heimdall.p2pNodePort.initContainer.image.repository | Container image to fetch nodeport information | string | `"lachlanevenson/k8s-kubectl"` |
 | heimdall.p2pNodePort.initContainer.image.tag | Container tag | string | `"v1.25.4"` |
 | heimdall.p2pNodePort.port | NodePort to be used. Must be unique. | int | `31000` |
 | heimdall.podAnnotations | Annotations for the `Pod` | object | `{}` |
 | heimdall.podSecurityContext | Pod-wide security context | object | `{"runAsNonRoot":false}` |
 | heimdall.readyAfterSync | Enable a readiness probe that checks if heimdall is synced | bool | `false` |
 | heimdall.resources |  | object | `{}` |
 | heimdall.service.ports.http-api |  | int | `1317` |
 | heimdall.service.ports.http-metrics |  | int | `26660` |
 | heimdall.service.ports.http-rpc |  | int | `26657` |
 | heimdall.service.topologyAwareRouting.enabled |  | bool | `false` |
 | heimdall.service.type |  | string | `"ClusterIP"` |
 | heimdall.tolerations |  | list | `[]` |
 | heimdall.volumeClaimSpec | [PersistentVolumeClaimSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.23/#persistentvolumeclaimspec-v1-core) for heimdall storage | object | `{"accessModes":["ReadWriteOnce"],"resources":{"requests":{"storage":"300Gi"}},"storageClassName":null}` |
 | heimdall.volumeClaimSpec.resources.requests.storage | The amount of disk space to provision for Heimdall | string | `"300Gi"` |
 | heimdall.volumeClaimSpec.storageClassName | The storage class to use when provisioning a persistent volume for heimdall | string | `nil` |
 | nameOverride |  | string | `""` |
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
