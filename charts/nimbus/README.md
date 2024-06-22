# Nimbus Helm Chart

Deploy and scale [Nimbus](https://github.com/status-im/nimbus-eth2) inside Kubernetes with ease

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) ![Version: 0.5.13](https://img.shields.io/badge/Version-0.5.13-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: multiarch-v24.5.1](https://img.shields.io/badge/AppVersion-multiarch--v24.5.1-informational?style=flat-square)

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
$ helm install my-release graphops/nimbus
```

## Specifying the Engine API JWT

To drive block progression of an Execution Client, you will need to configure a JWT that is used by Nimbus to authenticate with the Execution Client's Engine API on port `8551`. You will need to pass the same JWT to your Execution Client.

You can specify the JWT for Nimbus either as a literal value, or as a reference to a key in an existing Kubernetes Secret. If you specify a literal value, it will be wrapped into a new Kubernetes Secret and passed into the Nimbus Pod.

Using a literal value:

```yaml
# values.yaml

nimbus:
  jwt:
    fromLiteral: some-secure-random-value-that-you-generate # You can generate this with: openssl rand -hex 32
```

Using an existing Kubernetes Secret:

```yaml
# values.yaml

nimbus:
  jwt:
    existingSecret:
      name: my-ethereum-mainnet-jwt-secret
      key: jwt
```

## Trusted node sync

By default, your Nimbus node will sync from scratch and verify all transactions on the beacon chain from genesis. This process can take several days/weeks.

[Trusted node sync](https://nimbus.guide/trusted-node-sync.html) allows you to get started more quickly by fetching a recent checkpoint from a trusted node, allowing you to get up and running in minutes. To use trusted node sync, you must have access to a node that you trust that exposes the Beacon API.

```yaml
# values.yaml

nimbus:
  extraArgs:
    - --network=goerli
  trustedNodeSync:
    enabled: true
    extraArgs:
      - --network=goerli
    trustedNodeUrl: http://a-trusted-goerli-nimbus-node:5052 # example
```

When enabled, trusted sync will happen in an init container named `init-trusted-node-sync` that runs before the normal Nimbus process starts.

## Enabling inbound P2P dials

By default, your Nimbus node will not have an internet-accessible port for P2P traffic. This makes it harder for your node to establish a strong set of peers because you cannot accept inbound P2P dials. To change this behaviour, you can set `nimbus.p2pNodePort.enabled` to `true`. This will make your node accessible via the Internet using a `Service` of type `NodePort`. When using `nimbus.p2pNodePort.enabled`, the exposed IP address on your Nimbus ENR record will be the "External IP" of the Node where the Pod is running. When using this mode, `nimbus.replicaCount` will be locked to `1`.

```yaml
# values.yaml

nimbus:
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
 | image.repository | Image for Nimbus | string | `"statusim/nimbus-eth2"` |
 | image.tag | Overrides the image tag | string | Chart.appVersion |
 | imagePullSecrets | Pull secrets required to fetch the Image | list | `[]` |
 | nameOverride |  | string | `""` |
 | nimbus.affinity |  | object | `{}` |
 | nimbus.affinityPresets.antiAffinityByHostname | Configure anti-affinity rules to prevent multiple instances on the same host | bool | `true` |
 | nimbus.executionClientUrl | URL to the Execution Client Engine API. Will use configured JWT to authenticate. | string | `""` |
 | nimbus.extraArgs | Additional CLI arguments | list | `[]` |
 | nimbus.extraLabels | Extra labels to attach to the Pod for matching against | object | `{}` |
 | nimbus.initChownData.enabled | Init container to set the correct permissions to access data directories | bool | `true` |
 | nimbus.initChownData.image.pullPolicy | Container pull policy | string | `"IfNotPresent"` |
 | nimbus.initChownData.image.repository | Container repository | string | `"busybox"` |
 | nimbus.initChownData.image.tag | Container tag | string | `"1.36.1"` |
 | nimbus.jwt | JWT to use to authenticate with Execution Client. Specify either `existingSecret` OR `fromLiteral`. | object | `{"existingSecret":{"key":"","name":""},"fromLiteral":""}` |
 | nimbus.jwt.existingSecret | Load the JWT from an existing Kubernetes Secret. Takes precedence over `fromLiteral` if set. | object | `{"key":"","name":""}` |
 | nimbus.jwt.existingSecret.key | Data key for the JWT in the Secret | string | `""` |
 | nimbus.jwt.existingSecret.name | Name of the Secret resource in the same namespace | string | `""` |
 | nimbus.jwt.fromLiteral | Use this literal value for the JWT | string | `""` |
 | nimbus.nodeSelector |  | object | `{}` |
 | nimbus.p2pNodePort.enabled | Expose P2P port via NodePort | bool | `false` |
 | nimbus.p2pNodePort.initContainer.image.pullPolicy | Container pull policy | string | `"IfNotPresent"` |
 | nimbus.p2pNodePort.initContainer.image.repository | Container image to fetch nodeport information | string | `"lachlanevenson/k8s-kubectl"` |
 | nimbus.p2pNodePort.initContainer.image.tag | Container tag | string | `"v1.21.11"` |
 | nimbus.p2pNodePort.port | NodePort to be used. Must be unique. | int | `31000` |
 | nimbus.podAnnotations | Annotations for the `Pod` | object | `{}` |
 | nimbus.podSecurityContext | Pod-wide security context | object | `{"fsGroup":101337,"runAsGroup":101337,"runAsNonRoot":true,"runAsUser":101337}` |
 | nimbus.resources |  | object | `{}` |
 | nimbus.service.ports.http-metrics | Service Port to expose Prometheus metrics on | int | `8008` |
 | nimbus.service.ports.http-nimbus | Service Port to expose JSON-RPC interface on | int | `5052` |
 | nimbus.service.topologyAwareRouting.enabled |  | bool | `false` |
 | nimbus.service.type |  | string | `"ClusterIP"` |
 | nimbus.terminationGracePeriodSeconds | Amount of time to wait before force-killing the container | int | `60` |
 | nimbus.tolerations |  | list | `[]` |
 | nimbus.trustedNodeSync.enabled | Enable init container to do a trusted checkpoint sync from another Consensus Client (be careful) | bool | `false` |
 | nimbus.trustedNodeSync.extraArgs | Additional CLI arguments | list | `[]` |
 | nimbus.trustedNodeSync.trustedNodeUrl | URL to the Trusted Consensus Client Node URL. See https://eth-clients.github.io/checkpoint-sync-endpoints/ | string | `""` |
 | nimbus.volumeClaimSpec | [PersistentVolumeClaimSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.23/#persistentvolumeclaimspec-v1-core) for storage | object | `{"accessModes":["ReadWriteOnce"],"resources":{"requests":{"storage":"300Gi"}},"storageClassName":null}` |
 | nimbus.volumeClaimSpec.resources.requests.storage | The amount of disk space to provision | string | `"300Gi"` |
 | nimbus.volumeClaimSpec.storageClassName | The storage class to use when provisioning a persistent volume | string | `nil` |
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
