{{/*
Expand the name of the chart.
*/}}
{{- define "heimdall.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "heimdall.fullname" -}}
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
{{- define "heimdall.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "heimdall.labels" -}}
helm.sh/chart: {{ include "heimdall.chart" . }}
{{ include "heimdall.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "heimdall.selectorLabels" -}}
app.kubernetes.io/name: {{ include "heimdall.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "heimdall.componentLabelFor" -}}
app.kubernetes.io/component: {{ . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "heimdall.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "heimdall.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Set the default seed nodes per network, when unspecified
*/}}
{{- define "heimdall.seeds" -}}
{{- with .config }}
{{- if empty .seeds }}
{{- if eq .network "mainnet" -}}
1500161dd491b67fb1ac81868952be49e2509c9f@52.78.36.216:26656,dd4a3f1750af5765266231b9d8ac764599921736@3.36.224.80:26656,8ea4f592ad6cc38d7532aff418d1fb97052463af@34.240.245.39:26656,e772e1fb8c3492a9570a377a5eafdb1dc53cd778@54.194.245.5:26656
{{- else if eq .network "mumbai" -}}
9df7ae4bf9b996c0e3436ed4cd3050dbc5742a28@43.200.206.40:26656,d9275750bc877b0276c374307f0fd7eae1d71e35@54.216.248.9:26656,1a3258eb2b69b235d4749cf9266a94567d6c0199@52.214.83.78:26656
{{- else if eq .network "amoy" -}}
eb57fffe96d74312963ced94a94cbaf8e0d8ec2e@54.217.171.196:26656,080dcdffcc453367684b61d8f3ce032f357b0f73@13.251.184.185:26656
{{- else }}
invalid network
{{- end }}
{{- else }}
{{- printf "%s" .seeds -}}
{{- end }}
{{- end }}
{{- end }}

{{/*
Generate the array of options for heimdall
 */}}
{{- define "heimdall.computedArgs" -}}
{{- $args := list
"--home=\"/storage\""
"--p2p.upnp=false"
}}
{{- $args = concat $args (list (print "--rpc.laddr=" ( print "tcp://127.0.0.1:" ( index .service.ports "http-rpc" ) | quote ))) }}
{{- if .p2pNodePort.enabled }}
{{- $args = concat $args (list (print "--p2p.laddr=" ( print "tcp://0.0.0.0:" .p2pNodePort.port | quote ))) }}
{{- $args = concat $args (list (print "--seeds=" ( include "heimdall.seeds" . | quote ) )) }}
{{- end }}
{{- with .config }}
{{- $args = concat $args (list (print "--chain=" ( print .network | quote ) )) }}
{{- $args = concat $args (list (print "--log_level=" ( print .logLevel | quote ) )) }}
{{- $args = concat $args (list (print "--logs-type=" ( print .logsType | quote ) )) }}
{{- if .borRpcUrl }}
{{- $args = concat $args (list (print "--bor_rpc_url=" ( print .borRpcUrl | quote ) )) }}
{{- end }}
{{- if .ethRpcUrl }}
{{- $args = concat $args (list (print "--eth_rpc_url=" ( print .ethRpcUrl | quote ) )) }}
{{- end }}
{{- $args = concat $args .extraArgs }}
{{- end }}
{{ dict "computedArgs" $args | toJson }}
{{- end }}

{{/*
Generate the array of options for heimdall rest server
 */}}
{{- define "heimdall.computedRestArgs" -}}
{{- $args := list
"--home=\"/storage\""
}}
{{- $args = concat $args (list (print "--laddr=" ( print "tcp://0.0.0.0:" ( index .service.ports "http-rest" ) | quote ))) }}
{{- $args = concat $args (list (print "--node=" ( print "tcp://127.0.0.1:" ( index .service.ports "http-rpc" ) | quote ))) }}
{{- $args = concat $args (list (print "--seeds=" ( include "heimdall.seeds" . | quote ) )) }}
{{- with .config }}
{{- $args = concat $args (list (print "--chain=" ( print .network | quote ) )) }}
{{- $args = concat $args .restServer.extraArgs }}
{{- end }}
{{ dict "computedRestArgs" $args | toJson }}
{{- end }}
