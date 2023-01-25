# Nwaku Helm Chart

Deploy and scale [Waku v2 Node](https://github.com/waku-org/nwaku) inside Kubernetes with ease

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) ![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v0.14.0](https://img.shields.io/badge/AppVersion-v0.14.0-informational?style=flat-square)

## Features

- Actively maintained by [GraphOps](https://graphops.xyz) [and contributors](https://github.com/graphops/helm-charts/graphs/contributors)
- Deploys a scalable pool of `rpcdaemon` instances, with auto-scaling support, for automatic elastic JSON-RPC
- Strong security defaults (non-root execution, ready-only root filesystem, drops all capabilities)
- Readiness checks to ensure traffic only hits `Pod`s that are healthy and ready to serve requests
- Support for `ServiceMonitor`s to configure Prometheus to scrape metrics ([prometheus-operator](https://github.com/prometheus-operator/prometheus-operator))
- Support for configuring Grafana dashboards for nwaku ([grafana](https://github.com/grafana/helm-charts/tree/main/charts/grafana))
- Support for exposing a NodePort to enable inbound P2P dials for better peering

## Quickstart

To install the chart with the release name `my-release`:

```console
$ helm repo add graphops http://graphops.github.io/helm-charts
$ helm install my-release graphops/nwaku
```

Once the release is installed, nwaku will begin syncing. You can use `kubectl logs` to monitor the sync status. See the Values section to install Prometheus `ServiceMonitor`s and a Grafana dashboard.

## JSON-RPC

### Built-in JSON-RPC

You can access JSON-RPC via the stateful node `Service` (`<release-name>-nwaku`) on port `8545` by default.

## Enabling inbound P2P dials

By default, your nwaku node will not have an internet-accessible port for P2P traffic. This makes it harder for your node to establish a strong set of peers because you cannot accept inbound P2P dials. To change this behaviour, you can set `statefulNode.p2pNodePort.enabled` to `true`. This will make your node accessible via the Internet using a `Service` of type `NodePort`. When using `statefulNode.p2pNodePort.enabled`, the exposed IP address on your nwaku ENR record will be the "External IP" of the Node where the Pod is running. When using this mode, `statefulNode.replicaCount` will be locked to `1`.

```yaml
# values.yaml

statefulNode:
  p2pNodePort:
    enabled: true
    port: 31000 # Must be globally unique and available on the host
```

You can monitor progress by following the logs of the `stateful-node-init` container: `kubectl logs --since 1m -f release-name-stateful-node-0 -c stateful-node-init`

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
 | grafana.dashboardsConfigMapLabelValue | Must match `sidecar.dashboards.labelValue` value for the [Grafana chart](https://github.com/grafana/helm-charts/tree/main/charts/grafana#grafana-helm-chart) | string | `"1"` |
 | image.pullPolicy |  | string | `"IfNotPresent"` |
 | image.repository | Image for nwaku | string | `"statusteam/nim-waku"` |
 | image.tag | Overrides the image tag | string | Chart.appVersion |
 | imagePullSecrets | Pull secrets required to fetch the Image | list | `[]` |
 | nameOverride |  | string | `""` |
 | nwaku.affinity |  | object | `{}` |
 | nwaku.affinityPresets.antiAffinityByHostname | Configure anti-affinity rules to prevent multiple instances on the same host | bool | `true` |
 | nwaku.extraArgs | Additional CLI arguments | list | `["--dns-discovery=true","--dns-discovery-url=enrtree://AOGECG2SPND25EEFMAJ5WF3KSGJNSGV356DSTL2YVLLZWIV6SAYBM@prod.waku.nodes.status.im"]` |
 | nwaku.extraLabels | Extra labels to attach to the Pod for matching against | object | `{}` |
 | nwaku.initChownData.enabled | Init container to set the correct permissions to access data directories | bool | `true` |
 | nwaku.initChownData.image.pullPolicy | Container pull policy | string | `"IfNotPresent"` |
 | nwaku.initChownData.image.repository | Container repository | string | `"busybox"` |
 | nwaku.initChownData.image.tag | Container tag | string | `"1.34.0"` |
 | nwaku.jwt | Key to use to maintain consistent addressing between restarts https://github.com/waku-org/nwaku/blob/master/docs/operators/how-to/configure-key.md#generate-and-configure-a-node-key | object | `{"existingSecret":{"key":"","name":""},"fromLiteral":""}` |
 | nwaku.jwt.existingSecret | Load the JWT from an existing Kubernetes Secret. Takes precedence over `fromLiteral` if set. | object | `{"key":"","name":""}` |
 | nwaku.jwt.existingSecret.key | Data key for the JWT in the Secret | string | `""` |
 | nwaku.jwt.existingSecret.name | Name of the Secret resource in the same namespace | string | `""` |
 | nwaku.jwt.fromLiteral | Use this literal value for the JWT | string | `""` |
 | nwaku.nodeSelector |  | object | `{}` |
 | nwaku.p2pNodePort.enabled | Expose P2P port via NodePort | bool | `false` |
 | nwaku.p2pNodePort.initContainer.image.pullPolicy | Container pull policy | string | `"IfNotPresent"` |
 | nwaku.p2pNodePort.initContainer.image.repository | Container image to fetch nodeport information | string | `"lachlanevenson/k8s-kubectl"` |
 | nwaku.p2pNodePort.initContainer.image.tag | Container tag | string | `"v1.21.3"` |
 | nwaku.p2pNodePort.port | NodePort to be used. Must be unique. | int | `31000` |
 | nwaku.podAnnotations | Annotations for the `Pod` | object | `{}` |
 | nwaku.podSecurityContext | Pod-wide security context | object | `{"fsGroup":101337,"runAsGroup":101337,"runAsNonRoot":true,"runAsUser":101337}` |
 | nwaku.resources |  | object | `{}` |
 | nwaku.service.ports.http-jsonrpc | Service Port to expose JSON-RPC interface on | int | `8545` |
 | nwaku.service.ports.http-metrics | Service Port to expose Prometheus metrics on | int | `8008` |
 | nwaku.service.ports.http-rest |  | int | `8645` |
 | nwaku.service.ports.http-ws | Service Port to expose gRPC interface on | int | `8000` |
 | nwaku.service.type |  | string | `"ClusterIP"` |
 | nwaku.terminationGracePeriodSeconds | Amount of time to wait before force-killing the container | int | `60` |
 | nwaku.tolerations |  | list | `[]` |
 | nwaku.volumeClaimSpec | [PersistentVolumeClaimSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.23/#persistentvolumeclaimspec-v1-core) for storage | object | `{"accessModes":["ReadWriteOnce"],"resources":{"requests":{"storage":"1.5Ti"}},"storageClassName":null}` |
 | nwaku.volumeClaimSpec.resources.requests.storage | The amount of disk space to provision | string | `"1.5Ti"` |
 | nwaku.volumeClaimSpec.storageClassName | The storage class to use when provisioning a persistent volume | string | `nil` |
 | prometheus.serviceMonitors.enabled | Enable monitoring by creating `ServiceMonitor` CRDs ([prometheus-operator](https://github.com/prometheus-operator/prometheus-operator)) | bool | `false` |
 | prometheus.serviceMonitors.interval |  | string | `nil` |
 | prometheus.serviceMonitors.labels |  | object | `{}` |
 | prometheus.serviceMonitors.relabelings |  | list | `[]` |
 | prometheus.serviceMonitors.scrapeTimeout |  | string | `nil` |
 | rbac.clusterRules | Required ClusterRole rules | list | See `values.yaml` |
 | rbac.create | Specifies whether RBAC resources are to be created | bool | `true` |
 | rbac.rules | Required ClusterRole rules | list | See `values.yaml` |
 | serviceAccount.annotations | Annotations to add to the service account | object | `{}` |
 | serviceAccount.create | Specifies whether a service account should be created | bool | `true` |
 | serviceAccount.name | The name of the service account to use. If not set and create is true, a name is generated using the fullname template | string | `""` |

## Contributing

We welcome and appreciate your contributions! Please see the [Contributor Guide](/CONTRIBUTING.md), [Code Of Conduct](/CODE_OF_CONDUCT.md) and [Security Notes](/SECURITY.md) for this repository.
