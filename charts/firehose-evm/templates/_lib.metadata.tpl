{{/*
Expand the name of the chart.
*/}}
{{- define "metadata.name" -}}
{{- default .Root.Chart.Name .Root.Values.global.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "metadata.fullname" -}}
{{- if not ( empty .Root.Values.global.fullnameOverride ) }}
{{- .Root.Values.global.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := "" }}
{{- if not ( empty .Root.Values.global.nameOverride ) }}
{{- $name = .Root.Values.global.nameOverride }}
{{- else }}
{{- $name = .Root.Chart.Name }}
{{- end }}
{{- if contains $name .Root.Release.Name }}
{{- .Root.Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Root.Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "metadata.chart" -}}
{{- printf "%s-%s" .Root.Chart.Name .Root.Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common annotations
*/}}
{{- define "metadata.annotations" -}}
{{- with .Root.Values.global.annotations }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "metadata.labels" -}}
helm.sh/chart: {{ include "metadata.chart" . }}
{{ include "metadata.selectorLabels" . }}
{{- if .Root.Chart.AppVersion }}
app.kubernetes.io/version: {{ .Root.Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Root.Release.Service }}
{{- with .Root.Values.global.labels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "metadata.selectorLabels" -}}
app.kubernetes.io/name: {{ include "metadata.name" . }}
app.kubernetes.io/instance: {{ .Root.Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use for a specific component
*/}}
{{- define "metadata.serviceAccountName" -}}
{{- if .Pod.serviceAccount.enabled -}}
  {{- default (printf "%s-%s" (include "metadata.fullname" .) .componentName) .Pod.serviceAccount.metadata.name -}}
{{- else -}}
  {{- default "default" .Pod.serviceAccount.metadata.name -}}
{{- end -}}
{{- end }}

{{/*
Create the name of the role or cluster role for a specific component
*/}}
{{- define "metadata.roleName" -}}
{{- $rootCtx := .Root -}}
{{- printf "%s-%s-role" (include "metadata.fullname" $) .componentName -}}
{{- end }}

{{- define "metadata.clusterRoleName" -}}
{{- $rootCtx := .Root -}}
{{- printf "%s-%s-%s-role" ( .Root.Release.Namespace ) (include "metadata.fullname" $) .componentName -}}
{{- end }}

{{- define "metadata.allLabels" -}}
{{- include "metadata.mergeLabelsOrAnnotations" (dict "Root" .Root "Pod" .Pod "specific" .labels "componentName" .componentName "type" "labels") -}}
{{- end -}}

{{- define "metadata.allAnnotations" -}}
{{- include "metadata.mergeLabelsOrAnnotations" (dict "Root" .Root "Pod" .Pod "specific" .annotations "componentName" .componentName "type" "annotations") -}}
{{- end -}}

{{- define "metadata.mergeLabelsOrAnnotations" -}}
{{- $result := dict -}}
{{- $root := .Root -}}
{{- $pod := .Pod -}}
{{- $specific := .specific | default dict -}}
{{- $componentName := .componentName -}}
{{- $isLabels := eq .type "labels" -}}

{{- $global := index $root.Values.global (ternary "labels" "annotations" $isLabels) | default dict -}}
{{- $component := index $pod (ternary "labels" "annotations" $isLabels) | default dict -}}

{{- $result = include "utils.deepMerge" (list $result $global) | fromYaml -}}
{{- $result = include "utils.deepMerge" (list $result $component) | fromYaml -}}

{{- if kindIs "slice" $specific -}}
  {{- range $specific -}}
    {{- $result = include "utils.deepMerge" (list $result .) | fromYaml -}}
  {{- end -}}
{{- else -}}
  {{- $result = include "utils.deepMerge" (list $result $specific) | fromYaml -}}
{{- end -}}

{{- $ctx := dict "Root" $root "Pod" $pod "componentName" $componentName -}}
{{- $templated := tpl ($result | toYaml) $ctx | fromYaml -}}

{{- $templated | toYaml -}}
{{- end -}}
