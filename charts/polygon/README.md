# Polygon Helm Chart

Deploy and scale [Polygon](https://github.com/maticnetwork/) inside Kubernetes with ease

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) ![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v2022.04.03](https://img.shields.io/badge/AppVersion-v2022.04.03-informational?style=flat-square)

## Features

- Actively maintained by [GraphOps](https://graphops.xyz) and contributors
- Deploys a scalable pool of `rpcdaemon` instances, with auto-scaling support, for automatic elastic JSON-RPC
- Strong security defaults (non-root execution, ready-only root filesystem, drops all capabilities)
- Readiness checks to ensure traffic only hits `Pod`s that are healthy and ready to serve requests
- Support for `PodMonitor`s to configure Prometheus to scrape metrics ([prometheus-operator](https://github.com/prometheus-operator/prometheus-operator))
- Support for configuring Grafana dashboards for polygon ([grafana](https://github.com/grafana/helm-charts/tree/main/charts/grafana))

## Quickstart

To install the chart with the release name `my-release`:

```console
$ helm repo add graphops http://graphops.github.io/helm-charts
$ helm install my-release graphops/polygon
```

Once the release is installed, polygon will begin syncing. You can use `kubectl logs` to monitor the sync status. See the Values section to install Prometheus `PodMonitor`s and a Grafana dashboard.

JSON-RPC is available at `<release-name>-polygon-rpcdaemons:8545` by default.

## JSON-RPC

### Built-in JSON-RPC

You can access JSON-RPC via the stateful node `Service` (`<release-name>-polygon-stateful-node`) on port `8545` by default.

Synchronous request performance is typically best when using the built-in JSON-RPC server, however for large throughput workloads you should use a scalable set of `rpcdaemon`s.

### Scalable `Deployment` of `rpcdaemon`s

For workloads where synchronous performance is less important than the scalability of request throughput, you should use a scalable `Deployment` of `rpcdaemon`s. In this mode, the number of `rpcdaemon`s can be scaled up. Each one connects to the stateful node process via its gRPC API. You can also use node selectors and other placement configuration to customise where `rpcdaemon`s are deployed within your cluster.

A dedicated `Service` (`<release-name>-polygon-rpcdaemons`) will be created to load balance JSON-RPC requests across `rpcdaemon` `Pod`s in the scalable `Deployment`. See the Values section to configure the `Deployment` and the number of replicas.

#### JSON-RPC Autoscaling

You can enable autoscaling for your scalable `Deployment` of `rpcdaemon`s. When enabled, the Chart will install a `HorizontalPodAutoscaler` into the cluster, which will manage the number of `rpcdaemon` replicas based on resource utilization.

If doing this, be sure to configure `rpcdaemons.resources.requests` with appropriate values, as the CPU and Memory utilization targets set in the autoscaling config are relative to the requested resource values.

## Upgrading

We recommend that you pin the version of the Chart that you deploy. You can use the `--version` flag with `helm install` and `helm upgrade` to specify a chart version constraint.

This project uses [Semantic Versioning](https://semver.org/). Changes to the version of the application (the `appVersion`) that the Chart deploys will generally result in a patch version bump for the Chart. Breaking changes to the Chart or its `values.yaml` interface will be reflected with a major version bump.

We do not recommend that you upgrade the application by overriding `image.tag`. Instead, use the version of the Chart that is built for your desired `appVersion`.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| bor.affinity | object | `{}` |  |
| bor.affinityPresets.antiAffinityByHostname | bool | `true` | Configure anti-affinity rules to prevent multiple Polygon instances on the same host |
| bor.enabled | bool | `true` | Enable creation of `StatefulSet` for Bor |
| bor.extraArgs | list | `["--http","--http.addr=0.0.0.0","--http.vhosts=*","--http.corsdomain=*","--http.port=8545","--http.api=eth,net,web3,txpool","--syncmode=full","--networkid=137","--miner.gasprice=30000000000","--miner.gaslimit=20000000","--miner.gastarget=20000000","--txpool.nolocals","--txpool.accountslots=16","--txpool.globalslots=32768","--txpool.accountqueue=16","--txpool.globalqueue=32768","--txpool.pricelimit=30000000000","--txpool.lifetime=1h30m0s","--maxpeers=200","--metrics","--pprof","--pprof.port=7071","--pprof.addr=0.0.0.0"]` | Additional CLI arguments to pass to Bor |
| bor.image.pullPolicy | string | `"IfNotPresent"` |  |
| bor.image.repository | string | `"maticnetwork/bor"` | Image for Bor |
| bor.image.tag | string | `"v0.2.16-beta2"` |  |
| bor.podSecurityContext.runAsNonRoot | bool | `false` |  |
| bor.service.ports.http-jsonrpc | int | `8545` | Service Port to expose JSON-RPC interface on |
| bor.service.type | string | `"ClusterIP"` |  |
| bor.volumeClaimSpec | object | `{"accessModes":["ReadWriteOnce"],"resources":{"requests":{"storage":"3Ti"}},"storageClassName":null}` | [PersistentVolumeClaimSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.23/#persistentvolumeclaimspec-v1-core) for polygon storage |
| bor.volumeClaimSpec.resources.requests.storage | string | `"3Ti"` | The amount of disk space to provision for polygon |
| bor.volumeClaimSpec.storageClassName | string | `nil` | The storage class to use when provisioning a persistent volume for polygon |
| fullnameOverride | string | `""` |  |
| grafana.dashboards | bool | `false` | Enable creation of Grafana dashboards. [Grafana chart](https://github.com/grafana/helm-charts/tree/main/charts/grafana#grafana-helm-chart) must be configured to search this namespace, see `sidecar.dashboards.searchNamespace` |
| grafana.dashboardsConfigMapLabel | string | `"grafana_dashboard"` | Must match `sidecar.dashboards.label` value for the [Grafana chart](https://github.com/grafana/helm-charts/tree/main/charts/grafana#grafana-helm-chart) |
| grafana.dashboardsConfigMapLabelValue | string | `""` | Must match `sidecar.dashboards.labelValue` value for the [Grafana chart](https://github.com/grafana/helm-charts/tree/main/charts/grafana#grafana-helm-chart) |
| heimdall.affinity | object | `{}` |  |
| heimdall.affinityPresets.antiAffinityByHostname | bool | `true` | Configure anti-affinity rules to prevent multiple Polygon instances on the same host |
| heimdall.enabled | bool | `true` | Enable creation of `StatefulSet` for Heimdall |
| heimdall.env.BOOTSTRAP | int | `1` |  |
| heimdall.env.ETH1_RPC_URL | string | `"http://eth-mainnet-0-erigon-rpcdaemons:8545"` |  |
| heimdall.env.SNAPSHOT_URL | string | `"https://matic-blockchain-snapshots.s3-accelerate.amazonaws.com/matic-mainnet/heimdall-snapshot-2022-04-30.tar.gz"` |  |
| heimdall.extraArgs | list | `[]` | Additional CLI arguments to pass to Heimdall |
| heimdall.image | object | `{"pullPolicy":"IfNotPresent","repository":"maticnetwork/heimdall","tag":"v0.2.9"}` | Number of heimdall replicas to run |
| heimdall.image.repository | string | `"maticnetwork/heimdall"` | Image for Bor |
| heimdall.nodeSelector | object | `{}` |  |
| heimdall.podAnnotations | object | `{}` | Annotations for the `Pod` |
| heimdall.podSecurityContext | object | `{"runAsNonRoot":false}` | Pod-wide security context |
| heimdall.resources.limits | object | `{}` |  |
| heimdall.resources.requests | object | `{"cpu":"500m","memory":"4Gi"}` | Requests must be specified if you are using autoscaling |
| heimdall.restServer.extraArgs | list | `[]` |  |
| heimdall.restServer.resources | object | `{}` |  |
| heimdall.service.ports.http-rest | int | `1317` |  |
| heimdall.service.ports.http-trpc | int | `26657` |  |
| heimdall.service.type | string | `"ClusterIP"` |  |
| heimdall.tolerations | list | `[]` |  |
| heimdall.volumeClaimSpec | object | `{"accessModes":["ReadWriteOnce"],"resources":{"requests":{"storage":"256Gi"}},"storageClassName":null}` | [PersistentVolumeClaimSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.23/#persistentvolumeclaimspec-v1-core) for polygon storage |
| heimdall.volumeClaimSpec.resources.requests.storage | string | `"256Gi"` | The amount of disk space to provision for Heimdall |
| heimdall.volumeClaimSpec.storageClassName | string | `nil` | The storage class to use when provisioning a persistent volume for polygon |
| nameOverride | string | `""` |  |
| network | string | `"mainnet"` | Specifies the Polygon network instance, one of: `mainnet`, `testnet` |
| prometheus.podMonitors.enabled | bool | `false` | Enable monitoring by creating `PodMonitor` CRDs ([prometheus-operator](https://github.com/prometheus-operator/prometheus-operator)) |
| prometheus.podMonitors.interval | string | `nil` |  |
| prometheus.podMonitors.labels | object | `{}` |  |
| prometheus.podMonitors.relabelings | list | `[]` |  |
| prometheus.podMonitors.scrapeTimeout | string | `nil` |  |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |

## Contributing

We welcome and appreciate your contributions! Please see the [Contributor Guide](/CONTRIBUTING.md), [Code Of Conduct](/CODE_OF_CONDUCT.md) and [Security Notes](/SECURITY.md) for this repository.