# Reth Helm Chart

Deploy and scale [Reth](https://github.com/paradigmxyz/reth) inside Kubernetes with ease

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) ![Version: 0.1.0-canary.1](https://img.shields.io/badge/Version-0.1.0--canary.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v2.1.0](https://img.shields.io/badge/AppVersion-v2.1.0-informational?style=flat-square)

## Chart Features

- Actively maintained by [GraphOps](https://graphops.xyz) and contributors
- Official [`ghcr.io/paradigmxyz/reth`](https://github.com/paradigmxyz/reth/pkgs/container/reth) image pinned to the current chart app version
- Defaults aligned with Reth v2.1.x, including Storage V2 for new databases
- Support for JWT-managed Engine API authentication for pairing with Consensus Clients
- Dedicated Services for user RPC, Engine API, metrics, and optional P2P exposure
- Support for exposing inbound P2P via `NodePort` or `LoadBalancer`
- Support for `ServiceMonitor`s to configure Prometheus to scrape metrics ([prometheus-operator](https://github.com/prometheus-operator/prometheus-operator))
- Support for provenance-marked upstream Reth Grafana dashboards aligned with the chart's Reth metrics workload

## Quickstart

To install the chart with the release name `my-release`:

```console
$ helm repo add graphops http://graphops.github.io/launchpad-charts
$ helm install my-release graphops/reth
```

## Specifying the Engine API JWT

To use Reth on a network that requires a Consensus Client, you will generally want to configure a JWT that is shared with that Consensus Client and used to authenticate against the Engine API on port `8551`.

You can specify the JWT for Reth either as a literal value, or as a reference to a key in an existing Kubernetes Secret. If you specify a literal value, it will be wrapped into a new Kubernetes Secret and passed into the Reth Pod.

Using a literal value:

```yaml
# values.yaml

reth:
  jwt:
    fromLiteral: 0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef # Generate with: openssl rand -hex 32
```

Using an existing Kubernetes Secret:

```yaml
# values.yaml

reth:
  jwt:
    existingSecret:
      name: my-ethereum-mainnet-jwt-secret
      key: jwt
```

If no JWT is configured, Reth will generate one inside its data directory on first start. That works for standalone nodes, but a user-managed Secret is usually the better fit when pairing Reth with a separate Consensus Client.

## Storage and Pruning

Reth v2.1.x defaults new databases to Storage V2. This chart keeps that default explicit with `reth.storage.v2=true`. Existing databases continue using the storage layout recorded in their metadata.

By default this chart leaves Reth in its archive-style pruning mode. If you want to enable Reth's `--full` pruning mode, set:

```yaml
# values.yaml

reth:
  pruning:
    mode: full
```

You can also set `reth.pruning.mode=minimal` for Reth's minimal storage mode. Advanced pruning segment configuration should be supplied through a Reth TOML config file, either by setting `reth.configFile.inline`, mounting an existing ConfigMap/Secret through `reth.configFile`, or mounting your own file and pointing `reth.config` at it.

## Reth configuration file

For chart-managed Reth TOML, use one of the config file sources under `reth.configFile`:

```yaml
# values.yaml

reth:
  configFile:
    inline: |
      [stages.headers]
      downloader_max_buffered_responses = 100
```

Existing ConfigMaps and Secrets are also supported:

```yaml
# values.yaml

reth:
  configFile:
    existingSecret:
      name: my-reth-config
      key: reth.toml
```

The chart mounts the managed file at `reth.configFile.path` and passes that path to `reth node --config`.

## Runtime Security

The Reth container runs as a non-root UID/GID by default and relies on Kubernetes `fsGroup` volume ownership handling for writable PVC access. The chart does not run a root `chown` init container by default because new PVCs should be handled by the kubelet and CSI driver. If you are migrating an old root-owned PVC or restoring data with restrictive ownership, use `extraInitContainers` for that one-off migration.

Reth's file log sink is disabled by default with `--log.file.max-files=0` so the container can keep `readOnlyRootFilesystem=true`. Logs are emitted to stdout in `log-fmt` without ANSI color.

The regular JSON-RPC IPC server is disabled by default with `--ipcdisable`. Enable `reth.ipc.enabled` only when another container in the same Pod needs the IPC socket.

## Services and monitoring

The chart keeps service trust boundaries separate:

- `<release>-reth` exposes user-facing HTTP/WS JSON-RPC when those transports are enabled.
- `<release>-reth-engine` exposes the authenticated Engine API as a ClusterIP Service for Consensus Clients.
- `<release>-reth-metrics` exposes Prometheus metrics as a ClusterIP Service.
- Optional P2P Services are created only when `reth.p2p.service.enabled=true`.

The metrics Service is the only Service labelled `serviceMonitorTarget: "true"`, matching the convention used by other charts in this repository. The ServiceMonitor selects that label and scrapes the `http-metrics` port.

## Grafana dashboards

The chart vendors upstream Reth Grafana dashboards from `paradigmxyz/reth` at commit `d577814eb1c3bbf6393448dcabd0d152ce45ccc4`. The dashboard JSON files include provenance metadata in their descriptions, tags, and dashboard source links, and rendered dashboard ConfigMaps/GrafanaDashboard resources carry `dashboards.launchpad.graphops.xyz/*` provenance annotations.

Only dashboards aligned with the Reth workload deployed by this chart are included. The upstream `metrics-exporter.json` dashboard is intentionally omitted because it requires the separate `ethereum-metrics-exporter` workload, which this chart does not deploy. See `dashboards/PROVENANCE.md` for the source commit and workload-alignment table.

## Workload lifecycle

The chart enables readiness, liveness, and startup probes by default. These use Kubernetes-native probes because the Reth image does not ship curl/wget-style healthcheck tools.

By default probes hit the Reth metrics endpoint on `http-metrics` with HTTP GET `/`. If metrics are disabled, the chart automatically falls back to a TCP probe against an enabled Reth service port: HTTP JSON-RPC, Engine API, WebSocket, then P2P. You can replace any generated probe with the corresponding `*.custom` value.

## Advanced Reth tuning

The chart exposes first-class values for Kubernetes wiring, common operator workflows, and safety controls for exposed services. More specialized Reth runtime tuning should use `reth.extraArgs` or a Reth TOML config supplied through `reth.configFile` or mounted separately and referenced by `reth.config`.

In practice this means regular RPC keeps first-class values for authentication and common public-endpoint guardrails, while specialized tracing, cache, transaction pool, database, and most Engine execution tuning stays in `extraArgs`. The Engine section intentionally keeps only `crossBlockCacheSize`, because it is directly tied to pod memory sizing.

## Enabling inbound P2P dials

By default, your Reth node will not have an internet-accessible port for P2P traffic. This makes it harder to establish a strong set of peers because you cannot accept inbound P2P dials.

To expose P2P you can use either `NodePort` or `LoadBalancer`:

- `NodePort`: set `reth.p2p.service.enabled=true`, `reth.p2p.service.type=NodePort`, and a fixed `reth.p2p.service.nodePort`. This mode locks `reth.replicaCount` to `1` and discovers the Node's external IP to advertise it to peers. The Service still uses named `targetPort`s (`tcp-p2p` and `udp-p2p`) for Service-to-Pod wiring; the fixed NodePort is required because Reth cannot advertise a different P2P port from the one it listens on.
- `LoadBalancer`: set `reth.p2p.service.enabled=true` and `reth.p2p.service.type=LoadBalancer`. Reth's `--nat=extip` only accepts IP addresses, so the chart waits for a LoadBalancer IP address. LoadBalancers that expose only a hostname require you to set `reth.p2p.service.advertiseIP` to a stable external IP or configure the LoadBalancer to allocate one.

Example:

```yaml
# values.yaml

reth:
  p2p:
    service:
      enabled: true
      type: NodePort
      nodePort: 31000
```

## Upgrading

We recommend that you pin the version of the Chart that you deploy. You can use the `--version` flag with `helm install` and `helm upgrade` to specify a chart version constraint.

This project uses [Semantic Versioning](https://semver.org/). Changes to the version of the application (the `appVersion`) that the Chart deploys will generally result in a patch version bump for the Chart. Breaking changes to the Chart or its `values.yaml` interface will be reflected with a major version bump.

We do not recommend that you upgrade the application by overriding `image.tag`. Instead, use the version of the Chart that is built for your desired `appVersion`.

## Values

| Key | Description | Type | Default |
|-----|-------------|------|---------|
 | fullnameOverride |  | string | `""` |
 | grafana.dashboards | Enable creation of bundled workload-aligned Reth Grafana dashboards. [Grafana chart](https://github.com/grafana/helm-charts/tree/main/charts/grafana#grafana-helm-chart) must be configured to search this namespace, see `sidecar.dashboards.searchNamespace` | bool | `false` |
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
 | image.repository | Image for Reth | string | `"ghcr.io/paradigmxyz/reth"` |
 | image.tag | Overrides the image tag | string | Chart.appVersion |
 | imagePullSecrets | Pull secrets required to fetch the Image | list | `[]` |
 | nameOverride |  | string | `""` |
 | prometheus.serviceMonitors.enabled | Enable monitoring by creating `ServiceMonitor` CRDs ([prometheus-operator](https://github.com/prometheus-operator/prometheus-operator)) | bool | `false` |
 | prometheus.serviceMonitors.interval |  | string | `nil` |
 | prometheus.serviceMonitors.labels |  | object | `{}` |
 | prometheus.serviceMonitors.metricRelabelings |  | list | `[]` |
 | prometheus.serviceMonitors.relabelings |  | list | `[]` |
 | prometheus.serviceMonitors.scrapeTimeout |  | string | `nil` |
 | rbac.clusterRules | Required ClusterRole rules | list | See `values.yaml` |
 | rbac.create | Specifies whether RBAC resources are to be created when P2P endpoint discovery needs Kubernetes API access | bool | `true` |
 | rbac.rules | Required Role rules | list | See `values.yaml` |
 | reth.affinity |  | object | `{}` |
 | reth.affinityPresets.antiAffinityByHostname | Configure anti-affinity rules to prevent multiple instances on the same host | bool | `true` |
 | reth.authrpc.addr | Listen address for the authenticated Engine API server | string | `"0.0.0.0"` |
 | reth.authrpc.enabled | Enable the authenticated Engine API server | bool | `true` |
 | reth.authrpc.ipc | Enable the authenticated Engine API over IPC | bool | `false` |
 | reth.authrpc.ipcPath | Authenticated Engine API IPC path | string | `""` |
 | reth.authrpc.service.annotations | Additional annotations for the Engine API Service | object | `{}` |
 | reth.authrpc.service.enabled | Create a dedicated ClusterIP Service for the authenticated Engine API | bool | `true` |
 | reth.authrpc.service.labels | Additional labels for the Engine API Service | object | `{}` |
 | reth.authrpc.service.publishNotReadyAddresses | Publish not-ready addresses on the Engine API Service | bool | `false` |
 | reth.automountServiceAccountToken | Automount the service account token. Forced on only when P2P endpoint discovery needs Kubernetes API access. | bool | `false` |
 | reth.chain |  | string | `"mainnet"` |
 | reth.config |  | string | `""` |
 | reth.configFile.existingConfigMap.key | Existing ConfigMap key containing the Reth TOML configuration | string | `"reth.toml"` |
 | reth.configFile.existingConfigMap.name | Existing ConfigMap name containing the Reth TOML configuration | string | `nil` |
 | reth.configFile.existingSecret.key | Existing Secret key containing the Reth TOML configuration | string | `"reth.toml"` |
 | reth.configFile.existingSecret.name | Existing Secret name containing the Reth TOML configuration | string | `nil` |
 | reth.configFile.inline | Inline Reth TOML configuration. Mutually exclusive with `existingConfigMap` and `existingSecret`. | string | `""` |
 | reth.configFile.path | Mount path used when the chart manages the Reth TOML configuration file | string | `"/etc/reth/reth.toml"` |
 | reth.containerSecurityContext | Container security context | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":true}` |
 | reth.datadir | The path to the Reth data directory | string | `"/storage"` |
 | reth.engine.crossBlockCacheSize | Cross-block execution cache size in megabytes. Leave unset to use the Reth default. | string | `nil` |
 | reth.env | Environment variables to pass to the Reth container | object | `{}` |
 | reth.extraArgs | Additional CLI arguments to pass to `reth node` | list | `[]` |
 | reth.extraContainers | Additional sidecar containers to inject into the Reth StatefulSet | list | `[]` |
 | reth.extraInitContainers | Additional init containers to inject into the Reth StatefulSet | list | `[]` |
 | reth.extraLabels | Extra labels to attach to the Pod for matching against | object | `{}` |
 | reth.extraVolumeMounts | Additional volume mounts to inject into the Reth container | list | `[]` |
 | reth.extraVolumes | Additional volumes to inject into the Reth StatefulSet | list | `[]` |
 | reth.http.addr | Listen address for HTTP JSON-RPC | string | `"0.0.0.0"` |
 | reth.http.api | Comma-separated list of HTTP JSON-RPC modules | string | `"eth,net,web3"` |
 | reth.http.corsDomain | Optional CORS domain configuration | string | `""` |
 | reth.http.disableCompression | Disable compression for HTTP JSON-RPC responses | bool | `false` |
 | reth.http.enabled | Enable the HTTP JSON-RPC server | bool | `true` |
 | reth.ipc.enabled | Enable the regular JSON-RPC IPC server. Disabled by default so only explicitly exposed RPC transports are available. | bool | `false` |
 | reth.ipc.path | IPC socket path for the regular JSON-RPC server | string | `""` |
 | reth.ipc.permissions | Optional octal permissions for the regular JSON-RPC IPC socket | string | `""` |
 | reth.jwt | JWT for clients to authenticate with the Engine API. Specify either `existingSecret` OR `fromLiteral`. | object | `{"existingSecret":{"key":null,"name":null},"fromLiteral":null}` |
 | reth.jwt.existingSecret | Load the JWT from an existing Kubernetes Secret. Takes precedence over `fromLiteral` if set. | object | `{"key":null,"name":null}` |
 | reth.jwt.existingSecret.key | Data key for the JWT in the Secret | string | `nil` |
 | reth.jwt.existingSecret.name | Name of the Secret resource in the same namespace | string | `nil` |
 | reth.jwt.fromLiteral | Use this literal value for the JWT | string | `nil` |
 | reth.livenessProbe.custom | Full Kubernetes livenessProbe override. Leave empty to use the chart's workload-aware default. | object | `{}` |
 | reth.livenessProbe.enabled | Enable the default Reth liveness probe. Uses the metrics endpoint when enabled, otherwise falls back to TCP on an enabled Reth service port. | bool | `true` |
 | reth.livenessProbe.failureThreshold | Consecutive liveness probe failures before Kubernetes restarts the container | int | `6` |
 | reth.livenessProbe.periodSeconds | How often to run the liveness probe | int | `30` |
 | reth.livenessProbe.timeoutSeconds | Seconds after which the liveness probe times out | int | `5` |
 | reth.logging.color | ANSI color mode for logs (`always`, `auto`, or `never`) | string | `"never"` |
 | reth.logging.file.directory | Directory for Reth file logs | string | `""` |
 | reth.logging.file.maxFiles | Maximum number of Reth log files. Defaults to `0` to disable file logging under read-only root filesystems. | int | `0` |
 | reth.logging.stdout.filter | Filter directive for logs written to stdout | string | `""` |
 | reth.logging.stdout.format | Format for logs written to stdout (`json`, `log-fmt`, or `terminal`) | string | `"log-fmt"` |
 | reth.metrics.addr | Listen address for Prometheus metrics | string | `"0.0.0.0"` |
 | reth.metrics.enabled | Enable Prometheus metrics | bool | `true` |
 | reth.metrics.service.annotations | Additional annotations for the metrics Service | object | `{}` |
 | reth.metrics.service.labels | Additional labels for the metrics Service | object | `{}` |
 | reth.metrics.service.publishNotReadyAddresses | Publish not-ready addresses on the metrics Service | bool | `false` |
 | reth.nodeSelector |  | object | `{}` |
 | reth.p2p.addr | Network listening address | string | `"0.0.0.0"` |
 | reth.p2p.bootnodes | Comma-separated enode URLs for P2P discovery bootstrap | string | `""` |
 | reth.p2p.disableNat | Disable NAT discovery | bool | `false` |
 | reth.p2p.disableTxGossip | Disable transaction pool gossip | bool | `false` |
 | reth.p2p.discovery.addr | UDP address for devp2p discovery v4 | string | `"0.0.0.0"` |
 | reth.p2p.discovery.discv4 | Enable discv4 discovery | bool | `true` |
 | reth.p2p.discovery.discv5 | Enable discv5 discovery | bool | `false` |
 | reth.p2p.discovery.dns | Enable DNS discovery | bool | `true` |
 | reth.p2p.discovery.enabled | Enable P2P discovery | bool | `true` |
 | reth.p2p.initContainer.image.pullPolicy | Container pull policy used to discover the externally reachable P2P endpoint | string | `"IfNotPresent"` |
 | reth.p2p.initContainer.image.repository | Container image used to discover the externally reachable P2P endpoint | string | `"lachlanevenson/k8s-kubectl"` |
 | reth.p2p.initContainer.image.tag | Container tag used to discover the externally reachable P2P endpoint | string | `"v1.25.4"` |
 | reth.p2p.initContainer.securityContext | Security context for the P2P endpoint discovery init container | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"runAsGroup":1000,"runAsNonRoot":true,"runAsUser":1000}` |
 | reth.p2p.maxInboundPeers | Maximum number of inbound peers | string | `nil` |
 | reth.p2p.maxOutboundPeers | Maximum number of outbound peers | string | `nil` |
 | reth.p2p.maxPeers | Maximum number of total peers | string | `nil` |
 | reth.p2p.netrestrict | Restrict network communication to the given CIDR ranges | string | `""` |
 | reth.p2p.noPersistPeers | Do not persist known peers | bool | `false` |
 | reth.p2p.port | TCP/UDP port for Reth P2P traffic | int | `30303` |
 | reth.p2p.service.advertiseIP | Optional external IP address to advertise instead of auto-discovery. Reth requires an IP address here; hostnames are not accepted. | string | `""` |
 | reth.p2p.service.annotations | Additional annotations for the P2P Service | object | `{}` |
 | reth.p2p.service.enabled | Enable exposing P2P traffic with a dedicated Service | bool | `false` |
 | reth.p2p.service.externalIPs | Optional `externalIPs` for the P2P Service | list | `[]` |
 | reth.p2p.service.externalTrafficPolicy | `externalTrafficPolicy` for the P2P Service | string | `"Local"` |
 | reth.p2p.service.labels | Additional labels for the P2P Service | object | `{}` |
 | reth.p2p.service.loadBalancerIP | Optional `loadBalancerIP` for `LoadBalancer` mode | string | `""` |
 | reth.p2p.service.loadBalancerSourceRanges | Optional `loadBalancerSourceRanges` for `LoadBalancer` mode | list | `[]` |
 | reth.p2p.service.nodePort | Fixed external NodePort. Required when `type=NodePort` because Reth cannot advertise a different port from the one it listens on. | string | `nil` |
 | reth.p2p.service.publishNotReadyAddresses | Publish not-ready addresses on the P2P Service | bool | `false` |
 | reth.p2p.service.type | Service type for the P2P endpoint (`NodePort` or `LoadBalancer`) | string | `"NodePort"` |
 | reth.p2p.trustedOnly | Only connect to or accept connections from trusted peers | bool | `false` |
 | reth.p2p.trustedPeers | Comma-separated enode URLs of trusted peers | string | `""` |
 | reth.podAnnotations | Annotations for the `Pod` | object | `{}` |
 | reth.podDisruptionBudget.enabled | Create a PodDisruptionBudget for voluntary disruption protection | bool | `false` |
 | reth.podDisruptionBudget.maxUnavailable | Maximum unavailable Reth Pods during voluntary disruptions. Mutually exclusive with `minAvailable`. | string | `nil` |
 | reth.podDisruptionBudget.minAvailable | Minimum available Reth Pods during voluntary disruptions. Mutually exclusive with `maxUnavailable`. | string | `nil` |
 | reth.podSecurityContext | Pod-wide security context | object | `{"fsGroup":1000,"fsGroupChangePolicy":"OnRootMismatch","runAsGroup":1000,"runAsNonRoot":true,"runAsUser":1000}` |
 | reth.priorityClassName | PriorityClass name for the Reth Pod | string | `""` |
 | reth.pruning.mode | Storage pruning mode (`archive`, `full`, or `minimal`) | string | `"archive"` |
 | reth.readinessProbe.custom | Full Kubernetes readinessProbe override. Leave empty to use the chart's workload-aware default. | object | `{}` |
 | reth.readinessProbe.enabled | Enable the default Reth readiness probe. Uses the metrics endpoint when enabled, otherwise falls back to TCP on an enabled Reth service port. | bool | `true` |
 | reth.readinessProbe.failureThreshold | Consecutive readiness probe failures before the Pod is marked not ready | int | `3` |
 | reth.readinessProbe.periodSeconds | How often to run the readiness probe | int | `10` |
 | reth.readinessProbe.timeoutSeconds | Seconds after which the readiness probe times out | int | `5` |
 | reth.replicaCount | Number of Reth Pods to run when dedicated P2P exposure is disabled | int | `1` |
 | reth.resources | Kubernetes resource requirements for the Reth container. Mainnet production nodes should set CPU, memory, and ephemeral-storage requests deliberately. | object | `{}` |
 | reth.rollingUpdatePartition | When using a RollingUpdate update strategy in the StatefulSet, sets a partition index to only update PODs with that index or higher | int | `0` |
 | reth.rpc.gasCap | Maximum gas limit for `eth_call` and call tracing RPC methods | string | `nil` |
 | reth.rpc.jwtSecret | Hex encoded JWT secret to authenticate regular HTTP/WS RPC servers. Not used for Engine API auth. | string | `""` |
 | reth.rpc.jwtSecretFromExistingSecret.key | Existing Secret key containing the regular HTTP/WS RPC JWT secret | string | `"jwt.hex"` |
 | reth.rpc.jwtSecretFromExistingSecret.name | Existing Secret name containing the regular HTTP/WS RPC JWT secret | string | `nil` |
 | reth.rpc.maxBlocksPerFilter | Maximum number of blocks scanned per filter request | string | `nil` |
 | reth.rpc.maxConnections | Maximum RPC server connections | string | `nil` |
 | reth.rpc.maxLogsPerResponse | Maximum logs returned in a single response | string | `nil` |
 | reth.rpc.txFeeCap | Maximum transaction fee in ether accepted by RPC APIs | string | `nil` |
 | reth.service.annotations | Additional annotations for the user-facing HTTP/WS RPC Service | object | `{}` |
 | reth.service.externalIPs | Optional `externalIPs` for the user-facing HTTP/WS RPC Service | list | `[]` |
 | reth.service.externalTrafficPolicy | Optional `externalTrafficPolicy` for `NodePort` or `LoadBalancer` mode | string | `""` |
 | reth.service.labels | Additional labels for the user-facing HTTP/WS RPC Service | object | `{}` |
 | reth.service.loadBalancerClass | Optional `loadBalancerClass` for `LoadBalancer` mode | string | `""` |
 | reth.service.loadBalancerIP | Optional `loadBalancerIP` for `LoadBalancer` mode | string | `""` |
 | reth.service.loadBalancerSourceRanges | Optional `loadBalancerSourceRanges` for `LoadBalancer` mode | list | `[]` |
 | reth.service.nodePorts | Optional fixed NodePorts for the user-facing HTTP/WS RPC Service when `type=NodePort` or `type=LoadBalancer` | object | `{"http-jsonrpc":null,"ws-rpc":null}` |
 | reth.service.ports.http-engineapi | Service port to expose the Engine API on | int | `8551` |
 | reth.service.ports.http-jsonrpc | Service port to expose JSON-RPC over HTTP on | int | `8545` |
 | reth.service.ports.http-metrics | Service port to expose Prometheus metrics on | int | `9001` |
 | reth.service.ports.ws-rpc | Service port to expose JSON-RPC over WebSocket on | int | `8546` |
 | reth.service.publishNotReadyAddresses.headless | Toggle publishing not ready addresses for the headless service | bool | `false` |
 | reth.service.publishNotReadyAddresses.main | Toggle publishing not ready addresses for the user-facing RPC service | bool | `false` |
 | reth.service.topologyAwareRouting.enabled | Toggle for topology aware routing | bool | `false` |
 | reth.service.type | Service type for the user-facing HTTP/WS RPC Service (`ClusterIP`, `NodePort`, or `LoadBalancer`) | string | `"ClusterIP"` |
 | reth.startupProbe.custom | Full Kubernetes startupProbe override. Leave empty to use the chart's workload-aware default. | object | `{}` |
 | reth.startupProbe.enabled | Enable the default Reth startup probe. Keeps liveness/readiness gated while Reth opens its database and starts serving endpoints. | bool | `true` |
 | reth.startupProbe.failureThreshold | Consecutive startup probe failures before Kubernetes restarts the container | int | `120` |
 | reth.startupProbe.periodSeconds | How often to run the startup probe | int | `10` |
 | reth.startupProbe.timeoutSeconds | Seconds after which the startup probe times out | int | `5` |
 | reth.storage.datadir.pprofDumps | Absolute path to store pprof dumps separately from `reth.datadir` | string | `""` |
 | reth.storage.datadir.rocksdb | Absolute path to store RocksDB separately from `reth.datadir` | string | `""` |
 | reth.storage.datadir.staticFiles | Absolute path to store static files separately from `reth.datadir` | string | `""` |
 | reth.storage.v2 | Enable Storage V2 for new databases. Existing database metadata always takes precedence. | bool | `true` |
 | reth.terminationGracePeriodSeconds | Amount of time to wait before force-killing the Reth process | int | `60` |
 | reth.tolerations |  | list | `[]` |
 | reth.topologySpreadConstraints | Pod topology spread constraints | list | `[]` |
 | reth.updateStrategyType | Choice of StatefulSet updateStrategy (OnDelete|RollingUpdate) | string | `"RollingUpdate"` |
 | reth.volumeClaimSpec | [PersistentVolumeClaimSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.23/#persistentvolumeclaimspec-v1-core) for Reth storage | object | `{"accessModes":["ReadWriteOnce"],"resources":{"requests":{"storage":"3Ti"}},"storageClassName":null}` |
 | reth.volumeClaimSpec.resources.requests.storage | The amount of disk space to provision for Reth | string | `"3Ti"` |
 | reth.volumeClaimSpec.storageClassName | The storage class to use when provisioning a persistent volume for Reth | string | `nil` |
 | reth.ws.addr | Listen address for WebSocket JSON-RPC | string | `"0.0.0.0"` |
 | reth.ws.api | Comma-separated list of WebSocket JSON-RPC modules | string | `"eth,net,web3"` |
 | reth.ws.enabled | Enable the WebSocket JSON-RPC server | bool | `false` |
 | reth.ws.origins | Optional WebSocket origins configuration | string | `""` |
 | serviceAccount.annotations | Annotations to add to the service account | object | `{}` |
 | serviceAccount.create | Specifies whether a service account should be created | bool | `true` |
 | serviceAccount.name | The name of the service account to use. If not set and create is true, a name is generated using the fullname template | string | `""` |

## Contributing

We welcome and appreciate your contributions! Please see the [Contributor Guide](/CONTRIBUTING.md), [Code Of Conduct](/CODE_OF_CONDUCT.md) and [Security Notes](/SECURITY.md) for this repository.
