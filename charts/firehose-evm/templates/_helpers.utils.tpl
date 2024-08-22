{{/*
This helper merges additional flags into the main configuration and constructs the computed template variables.
*/}}
{{- define "firehose-evm.generateConfigmap" -}}
{{- $componentMapping := dict
    "grpc" "firehose"
-}}
{{- $fireethConfig := "" }}
{{- if not (empty ( .Pod.fireeth.config | default dict ) ) }}
{{- $fireethConfig = tpl ( .Pod.fireeth.config | toYaml) . }}
{{- end }}
start:
  args:
    - {{ get $componentMapping .componentName | default .componentName }}
  flags:
    {{- $fireethConfig | nindent 4 }}
    {{- if eq .componentName "reader-node" }}
    {{- $readerNodeArgs := include "utils.generateArgsList" (dict "object" ( .Pod.node.args | default dict ) ) | fromYamlArray }}
    reader-node-arguments: |
    {{- range $readerNodeArgs }}
      - {{ . | quote }}
    {{- end }}
    {{- end }}
{{- end }}









{{- define "firehose-evm.mergeLabelsOrAnnotations" -}}
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



