# Avalanche Helm Chart

Deploy and scale [avalanche](https://github.com/avalancheEth/avalanche) inside Kubernetes with ease

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) ![Version: 0.1.2](https://img.shields.io/badge/Version-0.1.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v1.10.14](https://img.shields.io/badge/AppVersion-v1.10.14-informational?style=flat-square)

## Chart Features

- Actively maintained by [GraphOps](https://graphops.xyz) and contributors
- Strong security defaults (non-root execution, ready-only root filesystem, drops all capabilities)
- Readiness checks to ensure traffic only hits `Pod`s that are healthy and ready to serve requests
- Support for `ServiceMonitor`s to configure Prometheus to scrape metrics ([prometheus-operator](https://github.com/prometheus-operator/prometheus-operator))
- Support for configuring Grafana dashboards ([grafana](https://github.com/grafana/helm-charts/tree/main/charts/grafana))
- Support for exposing a NodePort to enable inbound P2P dials for better peering

## Quickstart

To install the chart with the release name `my-release`:

```console
$ helm repo add graphops http://graphops.github.io/launchpad-charts
$ helm install my-release graphops/avalanche
```

## Enabling inbound P2P dials

By default, your avalanche node will not have an internet-accessible port for P2P traffic. This makes it harder for your node to establish a strong set of peers because you cannot accept inbound P2P dials. To change this behaviour, you can set `avalanche.p2pNodePort.enabled` to `true`. This will make your node accessible via the Internet using a `Service` of type `NodePort`. When using `avalanche.p2pNodePort.enabled`, the exposed IP address on your avalanche ENR record will be the "External IP" of the Node where the Pod is running. When using this mode, `avalanche.replicaCount` will be locked to `1`.

```yaml
# values.yaml

avalanche:
  p2pNodePort:
    enabled: true
    port: 31000 # Must be globally unique and available on the host
```

## Upgrading

We recommend that you pin the version of the Chart that you deploy. You can use the `--version` flag with `helm install` and `helm upgrade` to specify a chart version constraint.

This project uses [Semantic Versioning](https://semver.org/). Changes to the version of the application (the `appVersion`) that the Chart deploys will generally result in a patch version bump for the Chart. Breaking changes to the Chart or its `values.yaml` interface will be reflected with a major version bump.

We do not recommend that you upgrade the application by overriding `image.tag`. Instead, use the version of the Chart that is built for your desired `appVersion`.

## Values

| Key | Description | Type | Default |
|-----|-------------|------|---------|
 | avalanche.affinity |  | object | `{}` |
 | avalanche.affinityPresets.antiAffinityByHostname | Configure anti-affinity rules to prevent multiple instances on the same host | bool | `true` |
 | avalanche.extraArgs | Additional CLI arguments | list | `[]` |
 | avalanche.extraLabels | Extra labels to attach to the Pod for matching against | object | `{}` |
 | avalanche.initChownData.enabled | Init container to set the correct permissions to access data directories | bool | `true` |
 | avalanche.initChownData.image.pullPolicy | Container pull policy | string | `"IfNotPresent"` |
 | avalanche.initChownData.image.repository | Container repository | string | `"busybox"` |
 | avalanche.initChownData.image.tag | Container tag | string | `"1.36.1"` |
 | avalanche.nodeSelector |  | object | `{}` |
 | avalanche.p2pNodePort.enabled | Expose P2P port via NodePort | bool | `false` |
 | avalanche.p2pNodePort.initContainer.image.pullPolicy | Container pull policy | string | `"IfNotPresent"` |
 | avalanche.p2pNodePort.initContainer.image.repository | Container image to fetch nodeport information | string | `"lachlanevenson/k8s-kubectl"` |
 | avalanche.p2pNodePort.initContainer.image.tag | Container tag | string | `"v1.25.4"` |
 | avalanche.p2pNodePort.port | NodePort to be used. Must be unique. | int | `31000` |
 | avalanche.podAnnotations | Annotations for the `Pod` | object | `{}` |
 | avalanche.podSecurityContext | Pod-wide security context | object | `{"fsGroup":0,"runAsGroup":0,"runAsNonRoot":false,"runAsUser":0}` |
 | avalanche.resources |  | object | `{}` |
 | avalanche.service.ports.http-jsonrpc | Service Port to expose JSON-RPC interface on | int | `9650` |
 | avalanche.service.ports.http-metrics | Service Port to expose Prometheus metrics on | int | `9651` |
 | avalanche.service.ports.http-p2p |  | int | `9655` |
 | avalanche.service.ports.http-port |  | int | `9656` |
 | avalanche.service.topologyAwareRouting.enabled |  | bool | `false` |
 | avalanche.service.type |  | string | `"ClusterIP"` |
 | avalanche.terminationGracePeriodSeconds | Amount of time to wait before force-killing the container | int | `60` |
 | avalanche.tolerations |  | list | `[]` |
 | avalanche.volumeClaimSpec | [PersistentVolumeClaimSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.23/#persistentvolumeclaimspec-v1-core) for storage | object | `{"accessModes":["ReadWriteOnce"],"resources":{"requests":{"storage":"4Ti"}},"storageClassName":null}` |
 | avalanche.volumeClaimSpec.resources.requests.storage | The amount of disk space to provision | string | `"4Ti"` |
 | avalanche.volumeClaimSpec.storageClassName | The storage class to use when provisioning a persistent volume | string | `nil` |
 | configTemplate | [Configuration for avalanche](https://github.com/ava-labs/avalanche-faucet/blob/main/config.json) | string | See default template in [values.yaml](values.yaml) |
 | fullnameOverride |  | string | `""` |
 | grafana.dashboards | Enable creation of Grafana dashboards. [Grafana chart](https://github.com/grafana/helm-charts/tree/main/charts/grafana#grafana-helm-chart) must be configured to search this namespace, see `sidecar.dashboards.searchNamespace` | bool | `false` |
 | grafana.dashboardsConfigMapLabel | Must match `sidecar.dashboards.label` value for the [Grafana chart](https://github.com/grafana/helm-charts/tree/main/charts/grafana#grafana-helm-chart) | string | `"grafana_dashboard"` |
 | grafana.dashboardsConfigMapLabelValue | Must match `sidecar.dashboards.labelValue` value for the [Grafana chart](https://github.com/grafana/helm-charts/tree/main/charts/grafana#grafana-helm-chart) | string | `"1"` |
 | image.pullPolicy |  | string | `"IfNotPresent"` |
 | image.repository | Image for avalanche | string | `"avaplatform/avalanchego"` |
 | image.tag | Overrides the image tag | string | Chart.appVersion |
 | imagePullSecrets | Pull secrets required to fetch the Image | list | `[]` |
 | nameOverride |  | string | `""` |
 | prometheus.pushGateway.enabled | Enable pushing metrics into Prometheus via PushGateway | bool | `false` |
 | prometheus.pushGateway.pushGatewayUrl | URL to your Prometheus PushGateway server | string | `nil` |
 | rbac.clusterRules | Required ClusterRole rules | list | See `values.yaml` |
 | rbac.create | Specifies whether RBAC resources are to be created | bool | `true` |
 | rbac.rules | Required ClusterRole rules | list | See `values.yaml` |
 | serviceAccount.annotations | Annotations to add to the service account | object | `{}` |
 | serviceAccount.create | Specifies whether a service account should be created | bool | `true` |
 | serviceAccount.name | The name of the service account to use. If not set and create is true, a name is generated using the fullname template | string | `""` |

## Contributing

We welcome and appreciate your contributions! Please see the [Contributor Guide](/CONTRIBUTING.md), [Code Of Conduct](/CODE_OF_CONDUCT.md) and [Security Notes](/SECURITY.md) for this repository.
