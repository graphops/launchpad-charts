{{/*
Expand the name of the chart.
*/}}
{{- define "graph-network-indexer.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "graph-network-indexer.fullname" -}}
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
{{- define "graph-network-indexer.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "graph-network-indexer.labels" -}}
helm.sh/chart: {{ include "graph-network-indexer.chart" . }}
{{ include "graph-network-indexer.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "graph-network-indexer.selectorLabels" -}}
app.kubernetes.io/name: {{ include "graph-network-indexer.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "graph-network-indexer.componentLabelFor" -}}
app.kubernetes.io/component: {{ . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "graph-network-indexer.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "graph-network-indexer.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Generate the configuration for the given component.
*/}}
{{- define "graph-network-indexer.config" -}}
{{- range $section, $sectionValues := .componentConfig.config }}
[{{ $section }}]
{{- range $key, $value := $sectionValues }}
{{ $key }} = {{ if kindIs "map" $value }}{{ $value | toJson }}{{ else if kindIs "string" $value }}{{ $value | quote }}{{ else }}{{ printf "%v" $value }}{{ end }}
{{- end }}
{{- end }}
{{- if .componentConfig.metrics.enabled }}
[metrics]
enabled = true
port = {{ .componentConfig.metrics.port }}
{{- end }}
{{- end }}