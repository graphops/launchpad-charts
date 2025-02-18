{{/* vim: set filetype=mustache: */}}

{{/* Define the main init template that other templates will call */}}
{{- define "common.init" -}}
{{- include "common.init._init" . -}}
{{- end -}}

{{/* Performs initialization, loading of resources and initial merges */}}
{{- define "common.init._init" -}}
{{/* Initialize state store */}}
{{- $_ := set $ "__common" dict }}
{{- $_ := set $.__common "cache" dict }}
{{- $_ := set $.__common "config" $.Values._common }}
{{- end -}}
