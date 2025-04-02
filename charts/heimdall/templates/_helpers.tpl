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
e019e16d4e376723f3adc58eb1761809fea9bee0@35.234.150.253:26656,7f3049e88ac7f820fd86d9120506aaec0dc54b27@34.89.75.187:26656,1f5aff3b4f3193404423c3dd1797ce60cd9fea43@34.142.43.240:26656,2d5484feef4257e56ece025633a6ea132d8cadca@35.246.99.203:26656,17e9efcbd173e81a31579310c502e8cdd8b8ff2e@35.197.233.249:26656,72a83490309f9f63fdca3a0bef16c290e5cbb09c@35.246.95.65:26656,00677b1b2c6282fb060b7bb6e9cc7d2d05cdd599@34.105.180.11:26656,721dd4cebfc4b78760c7ee5d7b1b44d29a0aa854@34.147.169.102:26656,4760b3fc04648522a0bcb2d96a10aadee141ee89@34.89.55.74:26656
{{- else if eq .network "mumbai" -}}
9df7ae4bf9b996c0e3436ed4cd3050dbc5742a28@43.200.206.40:26656,d9275750bc877b0276c374307f0fd7eae1d71e35@54.216.248.9:26656,1a3258eb2b69b235d4749cf9266a94567d6c0199@52.214.83.78:26656
{{- else if eq .network "amoy" -}}
e4eabef3111155890156221f018b0ea3b8b64820@35.197.249.21:26656,811c3127677a4a34df907b021aad0c9d22f84bf4@34.89.39.114:26656,2ec15d1d33261e8cf42f57236fa93cfdc21c1cfb@35.242.167.175:26656,38120f9d2c003071a7230788da1e3129b6fb9d3f@34.89.15.223:26656,2f16f3857c6c99cc11e493c2082b744b8f36b127@34.105.128.110:26656,2833f06a5e33da2e80541fb1bfde2a7229877fcb@34.89.21.99:26656,2e6f1342416c5d758f5ae32f388bb76f7712a317@34.89.101.16:26656,a596f98b41851993c24de00a28b767c7c5ff8b42@34.89.11.233:26656
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
