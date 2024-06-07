{{/*
Expand the name of the chart.
*/}}
{{- define "subgraph-availability-oracle.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "subgraph-availability-oracle.fullname" -}}
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
{{- define "subgraph-availability-oracle.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "subgraph-availability-oracle.labels" -}}
helm.sh/chart: {{ include "subgraph-availability-oracle.chart" . }}
{{ include "subgraph-availability-oracle.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "subgraph-availability-oracle.selectorLabels" -}}
app.kubernetes.io/name: {{ include "subgraph-availability-oracle.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "subgraph-availability-oracle.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (printf "%s-%s" (include "subgraph-availability-oracle.fullname" .) .Release.Namespace) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "subgraph-availability-oracle.p2pPort.wakuPort" -}}
{{- if .p2pNodePort.enabled }}
{{- print .p2pNodePort.wakuPort }}
{{- else }}
{{- printf "60000" -}}
{{- end }}
{{- end -}}

{{- define "subgraph-availability-oracle.p2pPort.discv5Port" -}}
{{- if .p2pNodePort.enabled }}
{{- print .p2pNodePort.discv5Port }}
{{- else }}
{{- printf "9000" -}}
{{- end }}
{{- end -}}

{{- define "arbitrum-classic.replicas" -}}
{{- if .p2pNodePort.enabled }}
{{- print 1 }}
{{ else }}
{{- default 1 .replicaCount  }}
{{- end}}
{{- end -}}
