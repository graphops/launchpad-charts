{{/*
Expand the name of the chart.
*/}}
{{- define "erigon.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "erigon.fullname" -}}
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
{{- define "erigon.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "erigon.labels" -}}
helm.sh/chart: {{ include "erigon.chart" . }}
{{ include "erigon.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "erigon.selectorLabels" -}}
app.kubernetes.io/name: {{ include "erigon.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "erigon.componentLabelFor" -}}
app.kubernetes.io/component: {{ . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "erigon.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (printf "%s-%s" (include "erigon.fullname" .) .Release.Namespace) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
P2P helpers
*/}}
{{- define "erigon.p2p.nodePortBase" -}}
{{- $values := . -}}
{{- if and $values.p2p $values.p2p.service $values.p2p.service.nodePort $values.p2p.service.nodePort.base -}}
{{- $values.p2p.service.nodePort.base -}}
{{- else if and $values.p2pNodePort $values.p2pNodePort.port -}}
{{- $values.p2pNodePort.port -}}
{{- else -}}
31000
{{- end -}}
{{- end -}}

{{/*
Erigon P2P ports: two explicit ports (protocol 68 and 67)
*/}}
{{- define "erigon.p2p.port1" -}}
{{- $v := . -}}
{{- if and $v.p2p $v.p2p.allowedPorts -}}
  {{- index $v.p2p.allowedPorts 0 -}}
{{- else -}}
  {{- include "erigon.p2p.containerPortBase" $v -}}
{{- end -}}
{{- end -}}

{{- define "erigon.p2p.port2" -}}
{{- $v := . -}}
{{- if and $v.p2p $v.p2p.allowedPorts -}}
  {{- if ge (len $v.p2p.allowedPorts) 2 -}}
    {{- index $v.p2p.allowedPorts 1 -}}
  {{- else -}}
    {{- add (include "erigon.p2p.containerPortBase" $v | int) 1 -}}
  {{- end -}}
{{- else -}}
  {{- add (include "erigon.p2p.containerPortBase" $v | int) 1 -}}
{{- end -}}
{{- end -}}

{{- define "erigon.p2p.containerPortBase" -}}
{{- $values := . -}}
{{- if and $values.p2p $values.p2p.port -}}
{{- $values.p2p.port -}}
{{- else -}}
30303
{{- end -}}
{{- end -}}

{{- define "erigon.p2p.isNodePort" -}}
{{- $values := . -}}
{{- if and $values.p2p $values.p2p.service $values.p2p.service.enabled -}}
  {{- if eq (default "NodePort" $values.p2p.service.type) "NodePort" -}}
true
  {{- else -}}
false
  {{- end -}}
{{- else if and $values.p2pNodePort $values.p2pNodePort.enabled -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}

{{- define "erigon.p2p.isLoadBalancer" -}}
{{- $values := . -}}
{{- if and $values.p2p $values.p2p.service $values.p2p.service.enabled (eq (default "" $values.p2p.service.type) "LoadBalancer") -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}

{{- define "erigon.p2pPort" -}}
{{- if (include "erigon.p2p.isNodePort" . | trim | eq "true") -}}
{{- include "erigon.p2p.nodePortBase" . -}}
{{- else -}}
{{- include "erigon.p2p.containerPortBase" . -}}
{{- end -}}
{{- end -}}

{{- define "erigon.replicas" -}}
{{- if (include "erigon.p2p.isNodePort" . | trim | eq "true") -}}
{{- print 1 -}}
{{- else -}}
{{- print (default 1 .replicaCount) -}}
{{- end -}}
{{- end -}}
