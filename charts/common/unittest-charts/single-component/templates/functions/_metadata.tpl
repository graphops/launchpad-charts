{{- define "common.metadata.fullname" }}
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

{{- define "common.metadata.chart" -}}
{{- printf "%s-%s" .Root.Chart.Name .Root.Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}
