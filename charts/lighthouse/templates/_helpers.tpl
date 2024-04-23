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
