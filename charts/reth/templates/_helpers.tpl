{{/*
Expand the name of the chart.
*/}}
{{- define "reth.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "reth.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "reth.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "reth.labels" -}}
helm.sh/chart: {{ include "reth.chart" . }}
{{ include "reth.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "reth.selectorLabels" -}}
app.kubernetes.io/name: {{ include "reth.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "reth.componentLabelFor" -}}
app.kubernetes.io/component: {{ . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "reth.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (printf "%s-%s" (include "reth.fullname" .) .Release.Namespace) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "reth.p2p.enabled" -}}
{{- if and .p2p .p2p.service .p2p.service.enabled -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}

{{- define "reth.p2p.isNodePort" -}}
{{- if and .p2p .p2p.service .p2p.service.enabled (eq (default "NodePort" .p2p.service.type) "NodePort") -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}

{{- define "reth.p2p.isLoadBalancer" -}}
{{- if and .p2p .p2p.service .p2p.service.enabled (eq (default "" .p2p.service.type) "LoadBalancer") -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}

{{- define "reth.p2p.containerPort" -}}
{{- if and .p2p .p2p.service .p2p.service.enabled (eq (default "NodePort" .p2p.service.type) "NodePort") .p2p.service.nodePort -}}
{{- .p2p.service.nodePort -}}
{{- else -}}
{{- .p2p.port -}}
{{- end -}}
{{- end -}}

{{- define "reth.configFile.enabled" -}}
{{- if or .configFile.inline .configFile.existingConfigMap.name .configFile.existingSecret.name -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}

{{- define "reth.configPath" -}}
{{- if (include "reth.configFile.enabled" . | trim | eq "true") -}}
{{- default "/etc/reth/reth.toml" .configFile.path -}}
{{- else -}}
{{- .config -}}
{{- end -}}
{{- end -}}

{{- define "reth.rpcJwtSecretFromExistingSecret.enabled" -}}
{{- if .rpc.jwtSecretFromExistingSecret.name -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}

{{- define "reth.mainService.hasPorts" -}}
{{- if or .http.enabled .ws.enabled -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}

{{- define "reth.isIPAddress" -}}
{{- $value := . | toString -}}
{{- $ipv4 := "^((25[0-5]|2[0-4][0-9]|1?[0-9]?[0-9])\\.){3}(25[0-5]|2[0-4][0-9]|1?[0-9]?[0-9])$" -}}
{{- $ipv6 := "^[0-9A-Fa-f:]+$" -}}
{{- if or (regexMatch $ipv4 $value) (and (contains ":" $value) (regexMatch $ipv6 $value)) -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}

{{- define "reth.replicas" -}}
{{- if (include "reth.p2p.enabled" . | trim | eq "true") -}}
{{- print 1 -}}
{{- else -}}
{{- print (default 1 .replicaCount) -}}
{{- end -}}
{{- end -}}

{{/*
Select the best built-in probe target for the enabled Reth endpoints.

Reth's image does not include curl/wget/nc, so defaults use Kubernetes-native
HTTP/TCP probes. Metrics are preferred because that endpoint is cheap and exists
for the whole process; if metrics are disabled, fall back to an enabled service
port so the chart remains sound across common endpoint combinations.
*/}}
{{- define "reth.defaultProbeTarget" -}}
{{- if .metrics.enabled }}
httpGet:
  path: /
  port: http-metrics
{{- else if .http.enabled }}
tcpSocket:
  port: http-jsonrpc
{{- else if .authrpc.enabled }}
tcpSocket:
  port: http-engineapi
{{- else if .ws.enabled }}
tcpSocket:
  port: ws-rpc
{{- else }}
tcpSocket:
  port: tcp-p2p
{{- end }}
{{- end -}}

{{- define "reth.renderProbe" -}}
{{- $values := .values -}}
{{- $probe := .probe -}}
{{- if $probe.custom }}
{{- toYaml $probe.custom }}
{{- else }}
{{ include "reth.defaultProbeTarget" $values }}
{{- with $probe.initialDelaySeconds }}
initialDelaySeconds: {{ . }}
{{- end }}
{{- with $probe.periodSeconds }}
periodSeconds: {{ . }}
{{- end }}
{{- with $probe.timeoutSeconds }}
timeoutSeconds: {{ . }}
{{- end }}
{{- with $probe.successThreshold }}
successThreshold: {{ . }}
{{- end }}
{{- with $probe.failureThreshold }}
failureThreshold: {{ . }}
{{- end }}
{{- end }}
{{- end -}}

{{/*
Generate static argv for `reth node`.

Keep this as a data helper, following the computedArgs pattern used by charts
such as arbitrum-nitro and heimdall. Workload templates stay focused on Pod
wiring and can render the final list with `toYaml`.

When a P2P Service is enabled without an explicit `advertiseIP`, only the NAT
external IP is runtime-discovered. The listen and discovery ports are still
static chart values and belong in this argv list.
*/}}
{{- define "reth.computedArgs" -}}
{{- $values := . -}}
{{- $jwtEnabled := or $values.jwt.existingSecret.name $values.jwt.fromLiteral -}}
{{- $p2pEnabled := (include "reth.p2p.enabled" $values | trim | eq "true") -}}
{{- $p2pPort := (include "reth.p2p.containerPort" $values) -}}
{{- $configPath := include "reth.configPath" $values | trim -}}
{{- $pruningMode := default "archive" $values.pruning.mode -}}
{{- $args := list -}}

{{/* Base node identity and storage. */}}
{{- if $configPath }}
{{- $args = concat $args (list (printf "--config=%s" $configPath)) -}}
{{- end }}
{{- $args = concat $args (list (printf "--chain=%s" $values.chain)) -}}
{{- $args = concat $args (list (printf "--datadir=%s" $values.datadir)) -}}
{{- with $values.storage.datadir.staticFiles }}
{{- $args = concat $args (list (printf "--datadir.static-files=%s" .)) -}}
{{- end }}
{{- with $values.storage.datadir.rocksdb }}
{{- $args = concat $args (list (printf "--datadir.rocksdb=%s" .)) -}}
{{- end }}
{{- with $values.storage.datadir.pprofDumps }}
{{- $args = concat $args (list (printf "--datadir.pprof-dumps=%s" .)) -}}
{{- end }}
{{- $args = concat $args (list (printf "--storage.v2=%v" $values.storage.v2)) -}}

{{/* P2P networking. */}}
{{- $args = concat $args (list (printf "--addr=%s" $values.p2p.addr)) -}}
{{- $args = concat $args (list (printf "--port=%v" $p2pPort)) -}}
{{- if and $p2pEnabled $values.p2p.service.advertiseIP }}
{{- $args = concat $args (list (printf "--nat=extip:%s" $values.p2p.service.advertiseIP)) -}}
{{- end }}
{{- $args = concat $args (list (printf "--discovery.addr=%s" $values.p2p.discovery.addr)) -}}
{{- if not $values.p2p.discovery.enabled }}
{{- $args = concat $args (list "--disable-discovery") -}}
{{- end }}
{{- if not $values.p2p.discovery.dns }}
{{- $args = concat $args (list "--disable-dns-discovery") -}}
{{- end }}
{{- if not $values.p2p.discovery.discv4 }}
{{- $args = concat $args (list "--disable-discv4-discovery") -}}
{{- end }}
{{- if $values.p2p.discovery.discv5 }}
{{- $args = concat $args (list "--enable-discv5-discovery") -}}
{{- end }}
{{- $args = concat $args (list (printf "--discovery.port=%v" $p2pPort)) -}}
{{- if $values.p2p.disableNat }}
{{- $args = concat $args (list "--disable-nat") -}}
{{- end }}
{{- with $values.p2p.bootnodes }}
{{- $args = concat $args (list (printf "--bootnodes=%s" .)) -}}
{{- end }}
{{- with $values.p2p.trustedPeers }}
{{- $args = concat $args (list (printf "--trusted-peers=%s" .)) -}}
{{- end }}
{{- if $values.p2p.trustedOnly }}
{{- $args = concat $args (list "--trusted-only") -}}
{{- end }}
{{- if $values.p2p.noPersistPeers }}
{{- $args = concat $args (list "--no-persist-peers") -}}
{{- end }}
{{- if ne $values.p2p.maxOutboundPeers nil }}
{{- $args = concat $args (list (printf "--max-outbound-peers=%v" $values.p2p.maxOutboundPeers)) -}}
{{- end }}
{{- if ne $values.p2p.maxInboundPeers nil }}
{{- $args = concat $args (list (printf "--max-inbound-peers=%v" $values.p2p.maxInboundPeers)) -}}
{{- end }}
{{- if ne $values.p2p.maxPeers nil }}
{{- $args = concat $args (list (printf "--max-peers=%v" $values.p2p.maxPeers)) -}}
{{- end }}
{{- with $values.p2p.netrestrict }}
{{- $args = concat $args (list (printf "--netrestrict=%s" .)) -}}
{{- end }}
{{- if $values.p2p.disableTxGossip }}
{{- $args = concat $args (list "--disable-tx-gossip") -}}
{{- end }}

{{/* User-facing RPC servers. */}}
{{- if $values.http.enabled }}
{{- $args = concat $args (list "--http") -}}
{{- $args = concat $args (list (printf "--http.addr=%s" $values.http.addr)) -}}
{{- $args = concat $args (list (printf "--http.port=%v" (index $values.service.ports "http-jsonrpc"))) -}}
{{- $args = concat $args (list (printf "--http.api=%s" $values.http.api)) -}}
{{- if $values.http.disableCompression }}
{{- $args = concat $args (list "--http.disable-compression") -}}
{{- end }}
{{- if $values.http.corsDomain }}
{{- $args = concat $args (list (printf "--http.corsdomain=%s" $values.http.corsDomain)) -}}
{{- end }}
{{- end }}
{{- if $values.ws.enabled }}
{{- $args = concat $args (list "--ws") -}}
{{- $args = concat $args (list (printf "--ws.addr=%s" $values.ws.addr)) -}}
{{- $args = concat $args (list (printf "--ws.port=%v" (index $values.service.ports "ws-rpc"))) -}}
{{- $args = concat $args (list (printf "--ws.api=%s" $values.ws.api)) -}}
{{- if $values.ws.origins }}
{{- $args = concat $args (list (printf "--ws.origins=%s" $values.ws.origins)) -}}
{{- end }}
{{- end }}
{{- with $values.rpc.jwtSecret }}
{{- $args = concat $args (list (printf "--rpc.jwtsecret=%s" .)) -}}
{{- end }}
{{- if ne $values.rpc.maxConnections nil }}
{{- $args = concat $args (list (printf "--rpc.max-connections=%v" $values.rpc.maxConnections)) -}}
{{- end }}
{{- if ne $values.rpc.maxBlocksPerFilter nil }}
{{- $args = concat $args (list (printf "--rpc.max-blocks-per-filter=%v" $values.rpc.maxBlocksPerFilter)) -}}
{{- end }}
{{- if ne $values.rpc.maxLogsPerResponse nil }}
{{- $args = concat $args (list (printf "--rpc.max-logs-per-response=%v" $values.rpc.maxLogsPerResponse)) -}}
{{- end }}
{{- if ne $values.rpc.gasCap nil }}
{{- $args = concat $args (list (printf "--rpc.gascap=%v" $values.rpc.gasCap)) -}}
{{- end }}
{{- if ne $values.rpc.txFeeCap nil }}
{{- $args = concat $args (list (printf "--rpc.txfeecap=%v" $values.rpc.txFeeCap)) -}}
{{- end }}
{{- if $values.ipc.enabled }}
{{- with $values.ipc.path }}
{{- $args = concat $args (list (printf "--ipcpath=%s" .)) -}}
{{- end }}
{{- with $values.ipc.permissions }}
{{- $args = concat $args (list (printf "--ipc.permissions=%s" .)) -}}
{{- end }}
{{- else }}
{{- $args = concat $args (list "--ipcdisable") -}}
{{- end }}

{{/* Engine API. */}}
{{- if $values.authrpc.enabled }}
{{- $args = concat $args (list (printf "--authrpc.addr=%s" $values.authrpc.addr)) -}}
{{- $args = concat $args (list (printf "--authrpc.port=%v" (index $values.service.ports "http-engineapi"))) -}}
{{- if $jwtEnabled }}
{{- $args = concat $args (list "--authrpc.jwtsecret=/jwt/jwt.hex") -}}
{{- end }}
{{- if $values.authrpc.ipc }}
{{- $args = concat $args (list "--auth-ipc") -}}
{{- end }}
{{- with $values.authrpc.ipcPath }}
{{- $args = concat $args (list (printf "--auth-ipc.path=%s" .)) -}}
{{- end }}
{{- else }}
{{- $args = concat $args (list "--disable-auth-server") -}}
{{- end }}

{{/* Metrics. */}}
{{- if $values.metrics.enabled }}
{{- $args = concat $args (list "--metrics") -}}
{{- $args = concat $args (list (printf "%s:%v" $values.metrics.addr (index $values.service.ports "http-metrics"))) -}}
{{- end }}

{{/* Pruning and storage policy. */}}
{{- if eq $pruningMode "full" }}
{{- $args = concat $args (list "--full") -}}
{{- else if eq $pruningMode "minimal" }}
{{- $args = concat $args (list "--minimal") -}}
{{- end }}

{{/* Logging. */}}
{{- with $values.logging.stdout.format }}
{{- $args = concat $args (list (printf "--log.stdout.format=%s" .)) -}}
{{- end }}
{{- with $values.logging.stdout.filter }}
{{- $args = concat $args (list (printf "--log.stdout.filter=%s" .)) -}}
{{- end }}
{{- with $values.logging.file.directory }}
{{- $args = concat $args (list (printf "--log.file.directory=%s" .)) -}}
{{- end }}
{{- $args = concat $args (list (printf "--log.file.max-files=%v" (default 0 $values.logging.file.maxFiles))) -}}
{{- with $values.logging.color }}
{{- $args = concat $args (list (printf "--color=%s" .)) -}}
{{- end }}

{{/* Engine execution tuning. */}}
{{- if ne $values.engine.crossBlockCacheSize nil }}
{{- $args = concat $args (list (printf "--engine.cross-block-cache-size=%v" $values.engine.crossBlockCacheSize)) -}}
{{- end }}

{{/* Last-mile extension point. */}}
{{- $args = concat $args (default (list) $values.extraArgs) -}}
{{ dict "computedArgs" $args | toJson }}
{{- end -}}

{{/*
Provenance annotations for Reth Grafana dashboards vendored into this chart.
*/}}
{{- define "reth.dashboardProvenanceAnnotations" -}}
dashboards.launchpad.graphops.xyz/source-repository: "https://github.com/paradigmxyz/reth"
dashboards.launchpad.graphops.xyz/source-directory: "etc/grafana/dashboards"
dashboards.launchpad.graphops.xyz/source-commit: "d577814eb1c3bbf6393448dcabd0d152ce45ccc4"
dashboards.launchpad.graphops.xyz/workload: "reth"
dashboards.launchpad.graphops.xyz/workload-aligned: "true"
{{- end -}}
