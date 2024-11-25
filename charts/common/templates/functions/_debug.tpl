{{/* Function debugger */}}
{{- define "common.debug.function" }}
### Function Call: {{ .name }} ###
Arguments: {{ .args | toYaml | nindent 2 }}
Result: {{ .result | toYaml | nindent 2 }}
### End Function ###
{{- end }}
