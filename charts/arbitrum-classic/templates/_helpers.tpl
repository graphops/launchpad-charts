{{/*
Expand the name of the chart.
*/}}
{{- define "arbitrum-classic.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "arbitrum-classic.fullname" -}}
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
{{- define "arbitrum-classic.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "arbitrum-classic.labels" -}}
helm.sh/chart: {{ include "arbitrum-classic.chart" . }}
{{ include "arbitrum-classic.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "arbitrum-classic.selectorLabels" -}}
app.kubernetes.io/name: {{ include "arbitrum-classic.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "arbitrum-classic.componentLabelFor" -}}
app.kubernetes.io/component: {{ . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "arbitrum-classic.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (printf "%s-%s" (include "arbitrum-classic.fullname" .) .Release.Namespace) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "arbitrum-classic.p2pPort" -}}
{{- if .p2pNodePort.enabled }}
{{- print .p2pNodePort.port }}
{{- else }}
{{- printf "30303" -}}
{{- end }}
{{- end -}}

{{- define "arbitrum-classic.replicas" -}}
{{- if .p2pNodePort.enabled }}
{{- print 1 }}
{{ else }}
{{- default 1 .replicaCount  }}
{{- end}}
{{- end -}}
