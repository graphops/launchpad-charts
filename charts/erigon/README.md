# Erigon Helm Chart

Deploy and scale [Erigon](https://github.com/ledgerwatch/erigon) inside Kubernetes with ease

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) ![Version: 0.1.4](https://img.shields.io/badge/Version-0.1.4-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v2022.07.02](https://img.shields.io/badge/AppVersion-v2022.07.02-informational?style=flat-square)

## Features

- Actively maintained by [GraphOps](https://graphops.xyz) and contributors
- Deploys a scalable pool of `rpcdaemon` instances, with auto-scaling support, for automatic elastic JSON-RPC
- Strong security defaults (non-root execution, ready-only root filesystem, drops all capabilities)
- Readiness checks to ensure traffic only hits `Pod`s that are healthy and ready to serve requests
- Support for `ServiceMonitor`s to configure Prometheus to scrape metrics ([prometheus-operator](https://github.com/prometheus-operator/prometheus-operator))
- Support for configuring Grafana dashboards for Erigon ([grafana](https://github.com/grafana/helm-charts/tree/main/charts/grafana))

## Quickstart

To install the chart with the release name `my-release`:

```console
$ helm repo add graphops http://graphops.github.io/helm-charts
$ helm install my-release graphops/erigon
```

Once the release is installed, Erigon will begin syncing. You can use `kubectl logs` to monitor the sync status. See the Values section to install Prometheus `ServiceMonitor`s and a Grafana dashboard.

JSON-RPC is available at `<release-name>-erigon-rpcdaemons:8545` by default.

## JSON-RPC

### Built-in JSON-RPC

You can access JSON-RPC via the stateful node `Service` (`<release-name>-erigon-stateful-node`) on port `8545` by default.

Synchronous request performance is typically best when using the built-in JSON-RPC server, however for large throughput workloads you should use a scalable set of `rpcdaemon`s.

### Scalable `Deployment` of `rpcdaemon`s

For workloads where synchronous performance is less important than the scalability of request throughput, you should use a scalable `Deployment` of `rpcdaemon`s. In this mode, the number of `rpcdaemon`s can be scaled up. Each one connects to the stateful node process via its gRPC API. You can also use node selectors and other placement configuration to customise where `rpcdaemon`s are deployed within your cluster.

A dedicated `Service` (`<release-name>-erigon-rpcdaemons`) will be created to load balance JSON-RPC requests across `rpcdaemon` `Pod`s in the scalable `Deployment`. See the Values section to configure the `Deployment` and the number of replicas.

#### JSON-RPC Autoscaling

You can enable autoscaling for your scalable `Deployment` of `rpcdaemon`s. When enabled, the Chart will install a `HorizontalPodAutoscaler` into the cluster, which will manage the number of `rpcdaemon` replicas based on resource utilization.

If doing this, be sure to configure `rpcdaemons.resources.requests` with appropriate values, as the CPU and Memory utilization targets set in the autoscaling config are relative to the requested resource values.

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
 | image.pullPolicy |  | string | `"IfNotPresent"` |
 | image.repository | Image for Erigon | string | `"thorax/erigon"` |
 | image.tag | Overrides the image tag | string | Chart.appVersion |
 | imagePullSecrets | Pull secrets required to fetch the Image | list | `[]` |
 | nameOverride |  | string | `""` |
 | prometheus.serviceMonitors.enabled | Enable monitoring by creating `ServiceMonitor` CRDs ([prometheus-operator](https://github.com/prometheus-operator/prometheus-operator)) | bool | `false` |
 | prometheus.serviceMonitors.interval |  | string | `nil` |
 | prometheus.serviceMonitors.labels |  | object | `{}` |
 | prometheus.serviceMonitors.relabelings |  | list | `[]` |
 | prometheus.serviceMonitors.scrapeTimeout |  | string | `nil` |
 | rpcdaemons.affinity |  | object | `{}` |
 | rpcdaemons.affinityPresets.antiAffinityByHostname | Configure anti-affinity rules to prevent multiple Erigon instances on the same host | bool | `true` |
 | rpcdaemons.autoscaling.enabled | Enable auto-scaling of the rpcdaemons Deployment. Be sure to set resources.requests for rpcdaemons. | bool | `false` |
 | rpcdaemons.autoscaling.maxReplicas | Maximum number of replicas | int | `10` |
 | rpcdaemons.autoscaling.minReplicas | Minimum number of replicas | int | `2` |
 | rpcdaemons.autoscaling.targetCPUUtilizationPercentage |  | int | `75` |
 | rpcdaemons.autoscaling.targetMemoryUtilizationPercentage |  | string | `nil` |
 | rpcdaemons.enabled | Enable a Deployment of rpcdaemons that can be scaled independently | bool | `true` |
 | rpcdaemons.extraArgs | Additional CLI arguments to pass to `rpcdaemon` | list | `["--http.api=eth,debug,net,trace","--trace.maxtraces=10000","--http.vhosts=*","--http.corsdomain=*","--ws","--rpc.batch.concurrency=4","--state.cache=2000000"]` |
 | rpcdaemons.nodeSelector |  | object | `{}` |
 | rpcdaemons.podAnnotations | Annotations for the `Pod` | object | `{}` |
 | rpcdaemons.podSecurityContext | Pod-wide security context | object | `{"fsGroup":101337,"runAsGroup":101337,"runAsNonRoot":true,"runAsUser":101337}` |
 | rpcdaemons.replicaCount | Number of rpcdaemons to run | int | `2` |
 | rpcdaemons.resources.limits |  | object | `{}` |
 | rpcdaemons.resources.requests | Requests must be specified if you are using autoscaling | object | `{"cpu":"500m","memory":"4Gi"}` |
 | rpcdaemons.service.ports.http-jsonrpc | Service Port to expose rpcdaemons JSON-RPC interface on | int | `8545` |
 | rpcdaemons.service.type |  | string | `"ClusterIP"` |
 | rpcdaemons.tolerations |  | list | `[]` |
 | serviceAccount.annotations | Annotations to add to the service account | object | `{}` |
 | serviceAccount.create | Specifies whether a service account should be created | bool | `true` |
 | serviceAccount.name | The name of the service account to use. If not set and create is true, a name is generated using the fullname template | string | `""` |
 | statefulNode.affinity |  | object | `{}` |
 | statefulNode.affinityPresets.antiAffinityByHostname | Configure anti-affinity rules to prevent multiple Erigon instances on the same host | bool | `true` |
 | statefulNode.extraArgs | Additional CLI arguments to pass to `erigon` | list | `["--torrent.download.rate=60mb","--torrent.upload.rate=20mb"]` |
 | statefulNode.nodeSelector |  | object | `{}` |
 | statefulNode.podAnnotations | Annotations for the `Pod` | object | `{}` |
 | statefulNode.podSecurityContext | Pod-wide security context | object | `{"fsGroup":101337,"runAsGroup":101337,"runAsNonRoot":true,"runAsUser":101337}` |
 | statefulNode.resources |  | object | `{}` |
 | statefulNode.service.ports.grpc-erigon | Service Port to expose Erigon GRPC interface on | int | `9090` |
 | statefulNode.service.ports.http-engineapi | Service Port to expose engineAPI interface on | int | `8550` |
 | statefulNode.service.ports.http-jsonrpc | Service Port to expose JSON-RPC interface on | int | `8545` |
 | statefulNode.service.type |  | string | `"ClusterIP"` |
 | statefulNode.terminationGracePeriodSeconds | Amount of time to wait before force-killing the Erigon process | int | `60` |
 | statefulNode.tolerations |  | list | `[]` |
 | statefulNode.volumeClaimSpec | [PersistentVolumeClaimSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.23/#persistentvolumeclaimspec-v1-core) for Erigon storage | object | `{"accessModes":["ReadWriteOnce"],"resources":{"requests":{"storage":"3Ti"}},"storageClassName":null}` |
 | statefulNode.volumeClaimSpec.resources.requests.storage | The amount of disk space to provision for Erigon | string | `"3Ti"` |
 | statefulNode.volumeClaimSpec.storageClassName | The storage class to use when provisioning a persistent volume for Erigon | string | `nil` |

## Contributing

We welcome and appreciate your contributions! Please see the [Contributor Guide](/CONTRIBUTING.md), [Code Of Conduct](/CODE_OF_CONDUCT.md) and [Security Notes](/SECURITY.md) for this repository.