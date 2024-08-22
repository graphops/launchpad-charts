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

{{/*
Common annotations
*/}}
{{- define "firehose-evm.annotations" -}}
{{- with .Values.global.annotations }}
{{ toYaml . }}
{{- end }}
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
{{- with .Values.global.labels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "firehose-evm.selectorLabels" -}}
app.kubernetes.io/name: {{ include "firehose-evm.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use for a specific component
*/}}
{{- define "firehose-evm.serviceAccountName" -}}
{{- if .Pod.serviceAccount.create -}}
  {{- default (printf "%s-%s" (include "firehose-evm.fullname" .Root) .componentName) .Pod.serviceAccount.name -}}
{{- else -}}
  {{- default "default" .Pod.serviceAccount.name -}}
{{- end -}}
{{- end }}

{{/*
Create the name of the role or cluster role for a specific component
*/}}
{{- define "firehose-evm.roleName" -}}
{{- $rootCtx := .Root -}}
{{- $componentName := .componentName -}}
{{- printf "%s-%s-role" (include "firehose-evm.fullname" .Root) $componentName -}}
{{- end }}

{{- define "firehose-evm.allLabels" -}}
{{- include "firehose-evm.mergeLabelsOrAnnotations" (dict "Root" .Root "Pod" .Pod "specific" .labels "componentName" .componentName "type" "labels") -}}
{{- end -}}

{{- define "firehose-evm.allAnnotations" -}}
{{- include "firehose-evm.mergeLabelsOrAnnotations" (dict "Root" .Root "Pod" .Pod "specific" .annotations "componentName" .componentName "type" "annotations") -}}
{{- end -}}
