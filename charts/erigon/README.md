# erigon

![Version: 0.9.7](https://img.shields.io/badge/Version-0.9.7-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v2.58.1](https://img.shields.io/badge/AppVersion-v2.58.1-informational?style=flat-square)

Deploy and scale [Erigon](https://github.com/ledgerwatch/erigon) inside Kubernetes with ease

## Values

| Key | Description | Type | Default |
|-----|-------------|------|---------|
 | fullnameOverride |  | string | `""` |
 | grafana.dashboards | Enable creation of Grafana dashboards. [Grafana chart](https://github.com/grafana/helm-charts/tree/main/charts/grafana#grafana-helm-chart) must be configured to search this namespace, see `sidecar.dashboards.searchNamespace` | bool | `false` |
 | grafana.dashboardsConfigMapLabel | Must match `sidecar.dashboards.label` value for the [Grafana chart](https://github.com/grafana/helm-charts/tree/main/charts/grafana#grafana-helm-chart) | string | `"grafana_dashboard"` |
 | grafana.dashboardsConfigMapLabelValue | Must match `sidecar.dashboards.labelValue` value for the [Grafana chart](https://github.com/grafana/helm-charts/tree/main/charts/grafana#grafana-helm-chart) | string | `"1"` |
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
 | rbac.clusterRules | Required ClusterRole rules | list | See `values.yaml` |
 | rbac.create | Specifies whether RBAC resources are to be created | bool | `true` |
 | rbac.rules | Required ClusterRole rules | list | See `values.yaml` |
 | rpcdaemon.affinity |  | object | `{}` |
 | rpcdaemon.affinityPresets.antiAffinityByHostname | Configure anti-affinity rules to prevent multiple Erigon instances on the same host | bool | `true` |
 | rpcdaemon.autoscaling.enabled | Enable auto-scaling of the rpcdaemon Deployment. Be sure to set resources.requests for rpcdaemon. | bool | `false` |
 | rpcdaemon.autoscaling.maxReplicas | Maximum number of replicas | int | `10` |
 | rpcdaemon.autoscaling.minReplicas | Minimum number of replicas | int | `2` |
 | rpcdaemon.autoscaling.targetCPUUtilizationPercentage |  | int | `75` |
 | rpcdaemon.autoscaling.targetMemoryUtilizationPercentage |  | string | `nil` |
 | rpcdaemon.enabled | Enable a Deployment of rpcdaemon that can be scaled independently | bool | `true` |
 | rpcdaemon.extraArgs | Additional CLI arguments to pass to `rpcdaemon` | list | `[]` |
 | rpcdaemon.extraLabels | Extra labels to attach to the Pod for matching against | object | `{}` |
 | rpcdaemon.nodeSelector |  | object | `{}` |
 | rpcdaemon.podAnnotations | Annotations for the `Pod` | object | `{}` |
 | rpcdaemon.podSecurityContext | Pod-wide security context | object | `{"fsGroup":101337,"runAsGroup":101337,"runAsNonRoot":true,"runAsUser":101337}` |
 | rpcdaemon.replicaCount | Number of replicas to run | int | `2` |
 | rpcdaemon.resources.limits |  | object | `{}` |
 | rpcdaemon.resources.requests | Requests must be specified if you are using autoscaling | object | `{"cpu":"500m","memory":"4Gi"}` |
 | rpcdaemon.service.ports.http-jsonrpc | Service Port to expose rpcdaemon JSON-RPC interface on | int | `8545` |
 | rpcdaemon.service.ports.http-metrics | Service Port to expose Prometheus metrics on | int | `6060` |
 | rpcdaemon.service.type |  | string | `"ClusterIP"` |
 | rpcdaemon.tolerations |  | list | `[]` |
 | serviceAccount.annotations | Annotations to add to the service account | object | `{}` |
 | serviceAccount.create | Specifies whether a service account should be created | bool | `true` |
 | serviceAccount.name | The name of the service account to use. If not set and create is true, a name is generated using the fullname template | string | `""` |
 | statefulNode.affinity |  | object | `{}` |
 | statefulNode.affinityPresets.antiAffinityByHostname | Configure anti-affinity rules to prevent multiple Erigon instances on the same host | bool | `true` |
 | statefulNode.extraArgs | Additional CLI arguments to pass to `erigon` | list | `[]` |
 | statefulNode.extraLabels | Extra labels to attach to the Pod for matching against | object | `{}` |
 | statefulNode.jwt | JWT for clients to authenticate with the Engine API. Specify either `existingSecret` OR `fromLiteral`. | object | `{"existingSecret":{"key":null,"name":null},"fromLiteral":null}` |
 | statefulNode.jwt.existingSecret | Load the JWT from an existing Kubernetes Secret. Takes precedence over `fromLiteral` if set. | object | `{"key":null,"name":null}` |
 | statefulNode.jwt.existingSecret.key | Data key for the JWT in the Secret | string | `nil` |
 | statefulNode.jwt.existingSecret.name | Name of the Secret resource in the same namespace | string | `nil` |
 | statefulNode.jwt.fromLiteral | Use this literal value for the JWT | string | `nil` |
 | statefulNode.nodeSelector |  | object | `{}` |
 | statefulNode.p2pNodePort.enabled | Expose P2P port via NodePort | bool | `false` |
 | statefulNode.p2pNodePort.initContainer.image.pullPolicy | Container pull policy | string | `"IfNotPresent"` |
 | statefulNode.p2pNodePort.initContainer.image.repository | Container image to fetch nodeport information | string | `"lachlanevenson/k8s-kubectl"` |
 | statefulNode.p2pNodePort.initContainer.image.tag | Container tag | string | `"v1.25.4"` |
 | statefulNode.p2pNodePort.port | NodePort to be used. Must be unique. | int | `31000` |
 | statefulNode.podAnnotations | Annotations for the `Pod` | object | `{}` |
 | statefulNode.podSecurityContext | Pod-wide security context | object | `{"fsGroup":101337,"runAsGroup":101337,"runAsNonRoot":true,"runAsUser":101337}` |
 | statefulNode.resources |  | object | `{}` |
 | statefulNode.restoreSnapshot.enabled | Enable initialising Erigon state from a remote snapshot | bool | `false` |
 | statefulNode.restoreSnapshot.snapshotUrl | URL for snapshot to download and extract to restore state | string | `""` |
 | statefulNode.service.ports.grpc-erigon | Service Port to expose Erigon GRPC interface on | int | `9090` |
 | statefulNode.service.ports.http-engineapi | Service Port to expose engineAPI interface on | int | `8551` |
 | statefulNode.service.ports.http-jsonrpc | Service Port to expose JSON-RPC interface on | int | `8545` |
 | statefulNode.service.ports.http-metrics | Service Port to expose Prometheus metrics on | int | `6060` |
 | statefulNode.service.ports.ws-rpc | Service Port to expose WS-RPC interface on | int | `8546` |
 | statefulNode.service.topologyAwareRouting.enabled |  | bool | `false` |
 | statefulNode.service.type |  | string | `"ClusterIP"` |
 | statefulNode.terminationGracePeriodSeconds | Amount of time to wait before force-killing the Erigon process | int | `60` |
 | statefulNode.tolerations |  | list | `[]` |
 | statefulNode.volumeClaimSpec | [PersistentVolumeClaimSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.23/#persistentvolumeclaimspec-v1-core) for Erigon storage | object | `{"accessModes":["ReadWriteOnce"],"resources":{"requests":{"storage":"3Ti"}},"storageClassName":null}` |
 | statefulNode.volumeClaimSpec.resources.requests.storage | The amount of disk space to provision for Erigon | string | `"3Ti"` |
 | statefulNode.volumeClaimSpec.storageClassName | The storage class to use when provisioning a persistent volume for Erigon | string | `nil` |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.3](https://github.com/norwoodj/helm-docs/releases/v1.11.3)
