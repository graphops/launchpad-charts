{{/*
Expand the name of the chart.
*/}}
{{- define "lighthouse.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "lighthouse.fullname" -}}
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
{{- define "lighthouse.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "lighthouse.labels" -}}
helm.sh/chart: {{ include "lighthouse.chart" . }}
{{ include "lighthouse.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "lighthouse.selectorLabels" -}}
app.kubernetes.io/name: {{ include "lighthouse.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "lighthouse.componentLabelFor" -}}
app.kubernetes.io/component: {{ . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "lighthouse.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (printf "%s-%s" (include "lighthouse.fullname" .) .Release.Namespace) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "lighthouse.port" -}}
{{- if .p2pHostPort.enabled }}
{{- print .p2pHostPort.port }}
{{- else }}
{{- print (index .service.ports "tcp-transport") -}}
{{- end }}
{{- end -}}

{{- define "lighthouse.discoveryPort" -}}
{{- if .p2pHostPort.enabled }}
{{- print .p2pHostPort.port }}
{{- else }}
{{- print (index .service.ports "udp-discovery") -}}
{{- end }}
{{- end -}}

{{- define "lighthouse.quicPort" -}}
{{- if .p2pHostPort.enabled }}
{{- print (add .p2pHostPort.port 1) }}
{{- else }}
{{- print (index .service.ports "udp-transport") -}}
{{- end }}
{{- end -}}

{{- define "lighthouse.replicas" -}}
{{- if .p2pHostPort.enabled }}
{{- print 1 }}
{{ else }}
{{- default 1 .replicaCount  }}
{{- end}}
{{- end -}}
