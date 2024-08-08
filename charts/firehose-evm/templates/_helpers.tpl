{{/*
Expand the name of the chart.
*/}}
{{- define "firehose-evm.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "firehose-evm.fullname" -}}
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
{{- define "firehose-evm.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "firehose-evm.componentLabelFor" -}}
app.kubernetes.io/component: {{ . }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "firehose-evm.labels" -}}
helm.sh/chart: {{ include "firehose-evm.chart" . }}
{{ include "firehose-evm.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "firehose-evm.selectorLabels" -}}
app.kubernetes.io/name: {{ include "firehose-evm.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "firehose-evm.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (printf "%s-%s" (include "firehose-evm.fullname" .) .Release.Namespace) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "reader.p2pPort" -}}
{{- if .p2pNodePort.enabled }}
{{- print .p2pNodePort.port }}
{{- else }}
{{- printf "30303" -}}
{{- end }}
{{- end -}}

{{/*
This helper merges additional flags into the main configuration and constructs the computed template variables.
*/}}
{{- define "firehose-evm.mergeConfig" -}}
{{- $values := . }}
{{- $baseConfig := deepCopy $values.config }}
{{- $componentName := index . "componentName" }}
{{- $componentConfig := index $values $componentName "config" }}
{{- $mergedConfig := mustMerge $baseConfig $componentConfig }}
{{- if eq $componentName "reader" }}
  {{- $mergedConfig = mustMerge $mergedConfig (dict "reader-node-data-dir" $values.reader.dataDir "reader-node-path" $values.reader.nodePath ) }}
{{- end }}
{{- tpl $values.configTemplate $mergedConfig }}
{{- end }}

{{- define "firehose-evm.readerArgs" -}}
{{- $values := . -}}
{{- $args := list
"--authrpc.port=8551"
"--authrpc.jwtsecret=/jwt/jwt.hex"
"--authrpc.addr=0.0.0.0"
"--authrpc.vhosts=*"
"--datadir={node-data-dir}"
"--firehose-enabled"
"--http"
"--http.vhosts=*"
}}
{{- with .readerConfig }}
{{- $args = concat $args (list (print "--syncmode=" .syncMode)) }}
{{- $args = concat $args (list (print "--http.api=" .httpRpc.api)) }}
{{- $args = concat $args (list (print "--http.addr=" .httpRpc.addr)) }}
{{- if .metrics.enabled }}
{{- $args = concat $args (list "--metrics" (print "--metrics.addr=" .metrics.addr) (print "--metrics.port=" .metrics.port)) }}
{{- end }}
{{- if not .snapshot.enabled }}
{{- $args := list "--snapshot=" "false" }}
{{- end }}
{{- if $values.p2pNodePort.enabled }}
{{- $args = concat $args (list
"--port=EXTERNAL_PORT" 
"--discovery.port=EXTERNAL_PORT"
"--nat=extip:EXTERNAL_IP"
) }}
{{- end }}
{{- $args = concat $args (splitList " " .extraArgs) }}
{{- end }}
{{- $argsStr := join "\n" $args -}}
{{- $argsStr -}}
{{- end }}
