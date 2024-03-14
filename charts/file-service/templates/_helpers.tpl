{{/*
Expand the name of the chart.
*/}}
{{- define "file-service.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "file-service.fullname" -}}
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
{{- define "file-service.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "file-service.labels" -}}
helm.sh/chart: {{ include "file-service.chart" . }}
{{ include "file-service.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "file-service.selectorLabels" -}}
app.kubernetes.io/name: {{ include "file-service.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}


{{/*
Create the name of the service account to use
*/}}
{{- define "file-service.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (printf "%s-%s" (include "file-service.fullname" .) .Release.Namespace) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Determine the workload kind
*/}}
{{- define "file-service.kind" -}}
{{- if .Values.storage.filesystem.enabled -}}
StatefulSet
{{- else -}}
Deployment
{{- end }}
{{- end }}

{{/*
is the service kind a StatefulSet
*/}}
{{- define "file-service.kindIsStatefulSet" -}}
{{- eq ( include "file-service.kind" . ) "StatefulSet" | toJson }}
{{- end }}

{{/*
is the service kind a Deployment
*/}}
{{- define "file-service.kindIsDeployment" -}}
{{- eq ( include "file-service.kind" . ) "Deployment" | toJson }}
{{- end }}
