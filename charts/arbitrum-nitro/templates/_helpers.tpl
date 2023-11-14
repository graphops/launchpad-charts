{{/*
Expand the name of the chart.
*/}}
{{- define "arbitrum-nitro.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "arbitrum-nitro.fullname" -}}
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
{{- define "arbitrum-nitro.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "arbitrum-nitro.labels" -}}
helm.sh/chart: {{ include "arbitrum-nitro.chart" . }}
{{ include "arbitrum-nitro.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "arbitrum-nitro.selectorLabels" -}}
app.kubernetes.io/name: {{ include "arbitrum-nitro.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "arbitrum-nitro.componentLabelFor" -}}
app.kubernetes.io/component: {{ . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "arbitrum-nitro.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (printf "%s-%s" (include "arbitrum-nitro.fullname" .) .Release.Namespace) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "arbitrum-nitro.replicas" -}}
{{- default 1 .replicaCount  }}
{{- end -}}

{{/*
Generate the array of options for nitro
 */}}
{{- define "arbitrum-nitro.computedArgs" -}}
{{- $args := list
"--persistent.chain=/storage/data"
"--persistent.global-config=/storage"
}}
{{- with .config }}
{{- $args = concat $args (list (print "--parent-chain.connection.url=" .parentChainURL)) }}
{{- $args = concat $args (list (print "--chain.id=" .chain)) }}
{{- $args = concat $args (list (print "--http.api=" .httpRPC.api)) }}
{{- $args = concat $args (list (print "--http.addr=" .httpRPC.addr)) }}
{{- $args = concat $args (list (print "--http.vhosts=" .httpRPC.vhosts)) }}
{{- $args = concat $args (list (print "--http.corsdomain=" .httpRPC.cors)) }}
{{- if not (empty .classicURL) }}
{{- $args = concat $args (list (print "--node.rpc.classic-redirect=" .classicURL)) }}
{{- end }}
{{- if .metrics.enabled }}
{{- $args = concat $args (list "--metrics" (print "--metrics-server-addr" .metrics.addr)) }}
{{- end }}
{{- $args = concat $args .defaultArgs }}
{{- $args = concat $args .extraArgs }}
{{- end }}
{{ dict "computedArgs" $args | toJson }}
{{- end }}
