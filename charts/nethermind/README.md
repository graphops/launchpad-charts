# Nethermind Helm Chart

Deploy and scale [Nethermind](https://github.com/NethermindEth/nethermind) inside Kubernetes with ease

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) ![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.14.2](https://img.shields.io/badge/AppVersion-1.14.2-informational?style=flat-square)

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
$ helm repo add graphops http://graphops.github.io/helm-charts
$ helm install my-release graphops/nethermind
```

## Specifying the Engine API JWT

To use Nethermind on a network that requires a Consensus Client, you will need to configure a JWT that is used by the Consensus Client to authenticate with the Engine API on port `8551`. You will need to pass the same JWT to your Consensus Client.

You can specify the JWT for Nethermind either as a literal value, or as a reference to a key in an existing Kubernetes Secret. If you specify a literal value, it will be wrapped into a new Kubernetes Secret and passed into the Nethermind Pod.

Using a literal value:

```yaml
# values.yaml

nethermind:
  jwt:
    fromLiteral: some-secure-random-value-that-you-generate # You can generate this with: openssl rand -hex 32
```

Using an existing Kubernetes Secret:

```yaml
# values.yaml

nethermind:
  jwt:
    existingSecret:
      name: my-ethereum-mainnet-jwt-secret
      key: jwt
```

## Enabling inbound P2P dials

By default, your Nethermind node will not have an internet-accessible port for P2P traffic. This makes it harder for your node to establish a strong set of peers because you cannot accept inbound P2P dials. To change this behaviour, you can set `nethermind.p2pNodePort.enabled` to `true`. This will make your node accessible via the Internet using a `Service` of type `NodePort`. When using `nethermind.p2pNodePort.enabled`, the exposed IP address on your Nethermind ENR record will be the "External IP" of the Node where the Pod is running. When using this mode, `nethermind.replicaCount` will be locked to `1`.

```yaml
# values.yaml

nethermind:
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
 | fullnameOverride |  | string | `""` |
 | grafana.dashboards | Enable creation of Grafana dashboards. [Grafana chart](https://github.com/grafana/helm-charts/tree/main/charts/grafana#grafana-helm-chart) must be configured to search this namespace, see `sidecar.dashboards.searchNamespace` | bool | `false` |
 | grafana.dashboardsConfigMapLabel | Must match `sidecar.dashboards.label` value for the [Grafana chart](https://github.com/grafana/helm-charts/tree/main/charts/grafana#grafana-helm-chart) | string | `"grafana_dashboard"` |
 | grafana.dashboardsConfigMapLabelValue | Must match `sidecar.dashboards.labelValue` value for the [Grafana chart](https://github.com/grafana/helm-charts/tree/main/charts/grafana#grafana-helm-chart) | string | `"1"` |
 | image.pullPolicy |  | string | `"IfNotPresent"` |
 | image.repository | Image for Nethermind | string | `"nethermind/nethermind"` |
 | image.tag | Overrides the image tag | string | Chart.appVersion |
 | imagePullSecrets | Pull secrets required to fetch the Image | list | `[]` |
 | nameOverride |  | string | `""` |
 | nethermind.affinity |  | object | `{}` |
 | nethermind.affinityPresets.antiAffinityByHostname | Configure anti-affinity rules to prevent multiple instances on the same host | bool | `true` |
 | nethermind.extraArgs | Additional CLI arguments | list | `[]` |
 | nethermind.initChownData.enabled | Init container to set the correct permissions to access data directories | bool | `true` |
 | nethermind.initChownData.image.pullPolicy | Container pull policy | string | `"IfNotPresent"` |
 | nethermind.initChownData.image.repository | Container repository | string | `"busybox"` |
 | nethermind.initChownData.image.tag | Container tag | string | `"1.34.0"` |
 | nethermind.jwt | JWT for clients to authenticate with the Engine API. Specify either `existingSecret` OR `fromLiteral`. | object | `{"existingSecret":{"key":"","name":""},"fromLiteral":""}` |
 | nethermind.jwt.existingSecret | Load the JWT from an existing Kubernetes Secret. Takes precedence over `fromLiteral` if set. | object | `{"key":"","name":""}` |
 | nethermind.jwt.existingSecret.key | Data key for the JWT in the Secret | string | `""` |
 | nethermind.jwt.existingSecret.name | Name of the Secret resource in the same namespace | string | `""` |
 | nethermind.jwt.fromLiteral | Use this literal value for the JWT | string | `""` |
 | nethermind.nodeSelector |  | object | `{}` |
 | nethermind.p2pNodePort.enabled | Expose P2P port via NodePort | bool | `false` |
 | nethermind.p2pNodePort.initContainer.image.pullPolicy | Container pull policy | string | `"IfNotPresent"` |
 | nethermind.p2pNodePort.initContainer.image.repository | Container image to fetch nodeport information | string | `"lachlanevenson/k8s-kubectl"` |
 | nethermind.p2pNodePort.initContainer.image.tag | Container tag | string | `"v1.21.3"` |
 | nethermind.p2pNodePort.port | NodePort to be used. Must be unique. | int | `31000` |
 | nethermind.podAnnotations | Annotations for the `Pod` | object | `{}` |
 | nethermind.podSecurityContext | Pod-wide security context | object | `{"fsGroup":0,"runAsGroup":0,"runAsNonRoot":false,"runAsUser":0}` |
 | nethermind.resources |  | object | `{}` |
 | nethermind.service.ports.http-engineapi | Service Port to expose engineAPI interface on | int | `8551` |
 | nethermind.service.ports.http-jsonrpc | Service Port to expose JSON-RPC interface on | int | `8545` |
 | nethermind.service.ports.http-metrics | Service Port to expose Prometheus metrics on | int | `6060` |
 | nethermind.service.type |  | string | `"ClusterIP"` |
 | nethermind.terminationGracePeriodSeconds | Amount of time to wait before force-killing the container | int | `60` |
 | nethermind.tolerations |  | list | `[]` |
 | nethermind.volumeClaimSpec | [PersistentVolumeClaimSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.23/#persistentvolumeclaimspec-v1-core) for storage | object | `{"accessModes":["ReadWriteOnce"],"resources":{"requests":{"storage":"300Gi"}},"storageClassName":null}` |
 | nethermind.volumeClaimSpec.resources.requests.storage | The amount of disk space to provision | string | `"300Gi"` |
 | nethermind.volumeClaimSpec.storageClassName | The storage class to use when provisioning a persistent volume | string | `nil` |
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
