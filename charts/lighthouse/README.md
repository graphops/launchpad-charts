# Lighthouse Helm Chart

Deploy and scale [Lighthouse](https://github.com/sigp/lighthouse) inside Kubernetes with ease

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) ![Version: 0.8.3](https://img.shields.io/badge/Version-0.8.3-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v8.1.0](https://img.shields.io/badge/AppVersion-v8.1.0-informational?style=flat-square)

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
$ helm install my-release graphops/lighthouse
```

## Specifying the Engine API JWT

To drive block progression of an Execution Client, you will need to configure a JWT that is used by Lighthouse to authenticate with the Execution Client's Engine API on port `8551`. You will need to pass the same JWT to your Execution Client.

You can specify the JWT for Lighthouse either as a literal value, or as a reference to a key in an existing Kubernetes Secret. If you specify a literal value, it will be wrapped into a new Kubernetes Secret and passed into the Lighthouse Pod.

Using a literal value:

```yaml
# values.yaml

lighthouse:
  jwt:
    fromLiteral: some-secure-random-value-that-you-generate # You can generate this with: openssl rand -hex 32
```

Using an existing Kubernetes Secret:

```yaml
# values.yaml

lighthouse:
  jwt:
    existingSecret:
      name: my-ethereum-mainnet-jwt-secret
      key: jwt
```
## Enabling inbound P2P dials

By default, your Lighthouse node will not have an internet-accessible port for P2P traffic. This makes it harder for your node to establish a strong set of peers because you cannot accept inbound P2P dials. To change this behaviour, you can set `lighthouse.p2pNodePort.enabled` to `true`. This will make your node accessible via the Internet using a `Service` of type `NodePort`. When using `lighthouse.p2pNodePort.enabled`, the exposed IP address on your Lighthouse ENR record will be the "External IP" of the Node where the Pod is running. When using this mode, `lighthouse.replicaCount` will be locked to `1`.

```yaml
# values.yaml

lighthouse:
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
 | grafana.operatorDashboards | Create GrafanaDashboard CRDs via Grafana Operator from files in `dashboards/` | object | `{"allowCrossNamespaceImport":false,"annotations":{},"enabled":false,"extraSpec":{},"folder":"","folderUID":"","instanceSelector":{"matchLabels":{}},"labels":{},"namespace":"","resyncPeriod":"","suspend":false,"uid":""}` |
 | grafana.operatorDashboards.allowCrossNamespaceImport | Allow matching Grafana instances outside current namespace | bool | `false` |
 | grafana.operatorDashboards.extraSpec | Additional spec fields to merge into GrafanaDashboard.spec | object | `{}` |
 | grafana.operatorDashboards.folder | Optional folder metadata | string | `""` |
 | grafana.operatorDashboards.instanceSelector | Selector to match Grafana instances managed by the operator | object | `{"matchLabels":{}}` |
 | grafana.operatorDashboards.labels | Extra labels and annotations on the GrafanaDashboard resources | object | `{}` |
 | grafana.operatorDashboards.namespace | Optional target namespace for the GrafanaDashboard CRDs (defaults to release namespace) | string | `""` |
 | grafana.operatorDashboards.resyncPeriod | Operator sync behavior | string | `""` |
 | image.pullPolicy |  | string | `"IfNotPresent"` |
 | image.repository | Image for lighthouse | string | `"sigp/lighthouse"` |
 | image.tag | Overrides the image tag | string | Chart.appVersion |
 | imagePullSecrets | Pull secrets required to fetch the Image | list | `[]` |
 | lighthouse.affinity |  | object | `{}` |
 | lighthouse.affinityPresets.antiAffinityByHostname | Configure anti-affinity rules to prevent multiple instances on the same host | bool | `true` |
 | lighthouse.executionClientUrl | URL to the Execution Client Engine API. Will use configured JWT to authenticate. | string | `""` |
 | lighthouse.extraArgs | Additional CLI arguments | list | `[]` |
 | lighthouse.extraLabels | Extra labels to attach to the Pod for matching against | object | `{}` |
 | lighthouse.jwt | JWT to use to authenticate with Execution Client. Specify either `existingSecret` OR `fromLiteral`. | object | `{"existingSecret":{"key":"","name":""},"fromLiteral":""}` |
 | lighthouse.jwt.existingSecret | Load the JWT from an existing Kubernetes Secret. Takes precedence over `fromLiteral` if set. | object | `{"key":"","name":""}` |
 | lighthouse.jwt.existingSecret.key | Data key for the JWT in the Secret | string | `""` |
 | lighthouse.jwt.existingSecret.name | Name of the Secret resource in the same namespace | string | `""` |
 | lighthouse.jwt.fromLiteral | Use this literal value for the JWT | string | `""` |
 | lighthouse.nodeSelector |  | object | `{}` |
 | lighthouse.p2p.service.advertiseIP | IP address to explicitly advertise in ENR (overrides autodetection and LB IP) | string | `""` |
 | lighthouse.p2p.service.annotations | Annotations to add to the P2P Service (e.g., Cilium sharing keys) | object | `{}` |
 | lighthouse.p2p.service.enabled | Enable a dedicated P2P Service | bool | `false` |
 | lighthouse.p2p.service.externalIPs | Fixed external IPs to bind the Service to (requires upstream routing) | list | `[]` |
 | lighthouse.p2p.service.externalTrafficPolicy | External traffic policy | string | `"Local"` |
 | lighthouse.p2p.service.labels | Additional labels to add to the P2P Service | object | `{}` |
 | lighthouse.p2p.service.loadBalancerIP | When using a LoadBalancer and your cloud supports it, set a specific LB IP | string | `""` |
 | lighthouse.p2p.service.loadBalancerSourceRanges | Restrict which source ranges can access the LoadBalancer (CIDRs) | list | `[]` |
 | lighthouse.p2p.service.type | Service type for P2P exposure | string | `"LoadBalancer"` |
 | lighthouse.p2pHostPort.enabled | Expose P2P ports via hostPort | bool | `false` |
 | lighthouse.p2pHostPort.initContainer.image.pullPolicy | Container pull policy | string | `"IfNotPresent"` |
 | lighthouse.p2pHostPort.initContainer.image.repository | Container image to fetch IP/port information | string | `"lachlanevenson/k8s-kubectl"` |
 | lighthouse.p2pHostPort.initContainer.image.tag | Container tag | string | `"v1.25.4"` |
 | lighthouse.p2pHostPort.port | First port of the 2-port range to be used. The ports must be unique | int | `31000` |
 | lighthouse.podAnnotations | Annotations for the `Pod` | object | `{}` |
 | lighthouse.podSecurityContext | Pod-wide security context | object | `{"fsGroup":0,"runAsGroup":0,"runAsUser":0}` |
 | lighthouse.pruneBlobs | Prune blobs? leave false for an archive node that retains hisotrical blobs | bool | `false` |
 | lighthouse.resources |  | object | `{}` |
 | lighthouse.service.ports.http-lighthouse | Service Port to expose REST http interface on | int | `5052` |
 | lighthouse.service.ports.http-metrics | Service Port to expose Prometheus metrics on | int | `5054` |
 | lighthouse.service.ports.tcp-transport | TCP transport for P2P | int | `9000` |
 | lighthouse.service.ports.udp-discovery | UDP discovery protocol for P2P | int | `9000` |
 | lighthouse.service.ports.udp-transport | For experimental QUIC protocol support | int | `9001` |
 | lighthouse.service.topologyAwareRouting.enabled |  | bool | `false` |
 | lighthouse.service.type |  | string | `"ClusterIP"` |
 | lighthouse.superNode | Super Node? post Fusaka, to subscribe and acquire all data one must run a super node | bool | `true` |
 | lighthouse.terminationGracePeriodSeconds | Amount of time to wait before force-killing the container | int | `60` |
 | lighthouse.tolerations |  | list | `[]` |
 | lighthouse.volumeClaimSpec | [PersistentVolumeClaimSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.23/#persistentvolumeclaimspec-v1-core) for storage | object | `{"accessModes":["ReadWriteOnce"],"resources":{"requests":{"storage":"3Ti"}},"storageClassName":null}` |
 | lighthouse.volumeClaimSpec.resources.requests.storage | The amount of disk space to provision | string | `"3Ti"` |
 | lighthouse.volumeClaimSpec.storageClassName | The storage class to use when provisioning a persistent volume | string | `nil` |
 | nameOverride |  | string | `""` |
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
