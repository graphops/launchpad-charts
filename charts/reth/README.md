# Reth Helm Chart

Reth (short for Rust Ethereum, pronunciation) is a new Ethereum full node implementation that is focused on being user-friendly, highly modular, as well as being fast and efficient. Reth is an Execution Layer (EL) and is compatible with all Ethereum Consensus Layer (CL) implementations that support the Engine API. It is originally built and driven forward by Paradigm, and is licensed under the Apache and MIT licenses.

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) ![Version: 0.0.1](https://img.shields.io/badge/Version-0.0.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

## Features

- Actively maintained by [GraphOps](https://graphops.xyz) [and contributors](https://github.com/graphops/launchpad-charts/graphs/contributors)
- Deploys a scalable pool of `rpcdaemon` instances, with auto-scaling support, for automatic elastic JSON-RPC
- Strong security defaults (non-root execution, ready-only root filesystem, drops all capabilities)
- Readiness checks to ensure traffic only hits `Pod`s that are healthy and ready to serve requests
- Support for `ServiceMonitor`s to configure Prometheus to scrape metrics ([prometheus-operator](https://github.com/prometheus-operator/prometheus-operator))
- Support for configuring Grafana dashboards for Erigon ([grafana](https://github.com/grafana/helm-charts/tree/main/charts/grafana))
- Support for exposing a NodePort to enable inbound P2P dials for better peering

## Quickstart

To install the chart with the release name `my-release`:

```console
$ helm repo add graphops http://graphops.github.io/launchpad-charts
$ helm install my-release graphops/reth
```

Once the release is installed, the node will begin syncing. You can use `kubectl logs` to monitor the sync status. See the Values section to install Prometheus `ServiceMonitor`s and a Grafana dashboard.

## Specifying the Engine API JWT

You can specify the JWT for Reth either as a literal value, or as a reference to a key in an existing Kubernetes Secret. If you specify a literal value, it will be wrapped into a new Kubernetes Secret and passed into the Reth Pod.

Using a literal value:

```yaml
# values.yaml

jwt:
  fromLiteral: some-secure-random-value-that-you-generate # You can generate this with: openssl rand -hex 32
```

Using an existing Kubernetes Secret:

```yaml
# values.yaml

  jwt:
    existingSecret:
      name: my-ethereum-mainnet-jwt-secret
      key: jwt
```

## Enabling inbound P2P dials

By default, your node will not have an internet-accessible port for P2P traffic. This makes it harder for your node to establish a strong set of peers because you cannot accept inbound P2P dials. To change this behaviour, you can set `statefulNode.p2pNodePort.enabled` to `true`. This will make your node accessible via the Internet using a `Service` of type `NodePort`. When using `statefulNode.p2pNodePort.enabled`, the exposed IP address on your Erigon ENR record will be the "External IP" of the Node where the Pod is running. When using this mode, `statefulNode.replicaCount` will be locked to `1`.

```yaml
# values.yaml

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
 | affinity | Affinity configuration for pods | object | `{}` |
 | annotations | Annotations for the StatefulSet | object | `{}` |
 | authPort | Engine Port (Auth Port) | int | `8551` |
 | containerSecurityContext | The security context for containers | object | See `values.yaml` |
 | extraArgs | Extra args for the reth container | list | `[]` |
 | extraContainerPorts | Additional ports for the main container | list | `[]` |
 | extraContainers | Additional containers | list | `[]` |
 | extraEnv | Additional env variables | list | `[]` |
 | extraPorts | Additional ports. Useful when using extraContainers or extraContainerPorts | list | `[]` |
 | extraVolumeMounts | Additional volume mounts | list | `[]` |
 | extraVolumes | Additional volumes | list | `[]` |
 | fullnameOverride | Overrides the chart's computed fullname | string | `""` |
 | grafana.dashboards | Enable creation of Grafana dashboards. [Grafana chart](https://github.com/grafana/helm-charts/tree/main/charts/grafana#grafana-helm-chart) must be configured to search this namespace, see `sidecar.dashboards.searchNamespace` | bool | `false` |
 | grafana.dashboardsConfigMapLabel | Must match `sidecar.dashboards.label` value for the [Grafana chart](https://github.com/grafana/helm-charts/tree/main/charts/grafana#grafana-helm-chart) | string | `"grafana_dashboard"` |
 | grafana.dashboardsConfigMapLabelValue | Must match `sidecar.dashboards.labelValue` value for the [Grafana chart](https://github.com/grafana/helm-charts/tree/main/charts/grafana#grafana-helm-chart) | string | `"1"` |
 | httpPort | HTTP Port | int | `8545` |
 | image.pullPolicy | reth container pull policy | string | `"IfNotPresent"` |
 | image.repository | reth container image repository | string | `"ethpandaops/reth"` |
 | image.tag | reth container image tag | string | `"main"` |
 | imagePullSecrets | Image pull secrets for Docker images | list | `[]` |
 | initChownData.enabled | Init container to set the correct permissions to access data directories | bool | `true` |
 | initChownData.image.pullPolicy | Container pull policy | string | `"IfNotPresent"` |
 | initChownData.image.repository | Container repository | string | `"busybox"` |
 | initChownData.image.tag | Container tag | string | `"1.34.0"` |
 | initChownData.resources | Resource requests and limits | object | `{}` |
 | initContainers | Additional init containers | list | `[]` |
 | jwt.existingSecret | Load the JWT from an existing Kubernetes Secret. Takes precedence over `fromLiteral` if set. | object | `{"key":null,"name":null}` |
 | jwt.existingSecret.key | Data key for the JWT in the Secret | string | `nil` |
 | jwt.existingSecret.name | Name of the Secret resource in the same namespace | string | `nil` |
 | jwt.fromLiteral | Use this literal value for the JWT | string | `"ecb22bc24e7d4061f7ed690ccd5846d7d73f5d2b9733267e12f56790398d908a"` |
 | livenessProbe | Liveness probe | object | See `values.yaml` |
 | metricsPort | Metrics Port | int | `9001` |
 | nameOverride | Overrides the chart's name | string | `""` |
 | nodeSelector | Node selector for pods | object | `{}` |
 | p2pNodePort.enabled | Expose P2P port via NodePort | bool | `false` |
 | p2pNodePort.initContainer.image.pullPolicy | Container pull policy | string | `"IfNotPresent"` |
 | p2pNodePort.initContainer.image.repository | Container image to fetch nodeport information | string | `"lachlanevenson/k8s-kubectl"` |
 | p2pNodePort.initContainer.image.tag | Container tag | string | `"v1.21.3"` |
 | p2pNodePort.port | NodePort to be used | int | `31000` |
 | p2pNodePort.portForwardContainer.image.pullPolicy | Container pull policy | string | `"IfNotPresent"` |
 | p2pNodePort.portForwardContainer.image.repository | Container image for the port forwarder | string | `"alpine/socat"` |
 | p2pNodePort.portForwardContainer.image.tag | Container tag | string | `"latest"` |
 | p2pPort | P2P Port | int | `30303` |
 | persistence.accessModes | Access mode for the volume claim template | list | `["ReadWriteOnce"]` |
 | persistence.annotations | Annotations for volume claim template | object | `{}` |
 | persistence.enabled | Uses an EmptyDir when not enabled | bool | `false` |
 | persistence.existingClaim | Use an existing PVC when persistence.enabled | string | `nil` |
 | persistence.selector | Selector for volume claim template | object | `{}` |
 | persistence.size | Requested size for volume claim template | string | `"20Gi"` |
 | persistence.storageClassName | Use a specific storage class E.g 'local-path' for local storage to achieve best performance Read more (https://github.com/rancher/local-path-provisioner) | string | `nil` |
 | podAnnotations | Pod annotations | object | `{}` |
 | podDisruptionBudget | Define the PodDisruptionBudget spec If not set then a PodDisruptionBudget will not be created | object | `{}` |
 | podLabels | Pod labels | object | `{}` |
 | podManagementPolicy | Pod management policy | string | `"OrderedReady"` |
 | priorityClassName | Pod priority class | string | `nil` |
 | rbac.clusterRules | Required ClusterRole rules | list | See `values.yaml` |
 | rbac.create | Specifies whether RBAC resources are to be created | bool | `true` |
 | rbac.rules | Required ClusterRole rules | list | See `values.yaml` |
 | readinessProbe | Readiness probe | object | See `values.yaml` |
 | replicas | Number of replicas | int | `1` |
 | resources | Resource requests and limits | object | `{}` |
 | secretEnv | Additional env variables injected via a created secret | object | `{}` |
 | securityContext | The security context for pods | object | See `values.yaml` |
 | serviceAccount.annotations | Annotations to add to the service account | object | `{}` |
 | serviceAccount.create | Specifies whether a service account should be created | bool | `true` |
 | serviceAccount.name | The name of the service account to use. If not set and create is true, a name is generated using the fullname template | string | `""` |
 | serviceMonitor.annotations | Additional ServiceMonitor annotations | object | `{}` |
 | serviceMonitor.enabled | If true, a ServiceMonitor CRD is created for a prometheus operator https://github.com/coreos/prometheus-operator | bool | `false` |
 | serviceMonitor.interval | ServiceMonitor scrape interval | string | `"1m"` |
 | serviceMonitor.labels | Additional ServiceMonitor labels | object | `{}` |
 | serviceMonitor.namespace | Alternative namespace for ServiceMonitor | string | `nil` |
 | serviceMonitor.path | Path to scrape | string | `"/debug/metrics/prometheus"` |
 | serviceMonitor.relabelings | ServiceMonitor relabelings | list | `[]` |
 | serviceMonitor.scheme | ServiceMonitor scheme | string | `"http"` |
 | serviceMonitor.scrapeTimeout | ServiceMonitor scrape timeout | string | `"30s"` |
 | serviceMonitor.tlsConfig | ServiceMonitor TLS configuration | object | `{}` |
 | terminationGracePeriodSeconds | How long to wait until the pod is forcefully terminated | int | `300` |
 | tolerations | Tolerations for pods # ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ | list | `[]` |
 | topologySpreadConstraints | Topology Spread Constraints for pods # ref: https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/ | list | `[]` |
 | updateStrategy | Update stategy for the Statefulset | object | `{"type":"RollingUpdate"}` |
 | updateStrategy.type | Update stategy type | string | `"RollingUpdate"` |
 | wsPort | WS Port | int | `8546` |

## Contributing

We welcome and appreciate your contributions! Please see the [Contributor Guide](/CONTRIBUTING.md), [Code Of Conduct](/CODE_OF_CONDUCT.md) and [Security Notes](/SECURITY.md) for this repository.
