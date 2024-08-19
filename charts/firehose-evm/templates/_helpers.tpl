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
    {{- $readerNodeArgs := include "generateArgs" (dict "object" ( .Pod.node.args | default dict ) ) | fromYaml }}
    reader-node-arguments: |
    {{- range $readerNodeArgs }}
      - {{ . | quote }}
    {{- end }}
    {{- end }}
{{- end }}

{{- define "firehose-evm.fullImage" -}}
{{- $imageParts := list .repository -}}
{{- if .digest -}}
{{- $imageParts = append $imageParts (print "@" .digest) -}}
{{- else -}}
{{- $imageParts = append $imageParts (print ":" .tag) -}}
{{- end -}}
{{- join "" $imageParts -}}
{{- end -}}

{{- /* Helper function to generate environment variables from a nested object */ -}}
{{- define "objectToEnvVarsList" -}}
{{- $prefix := .prefix | default "NODE_CONFIG" -}}
{{- $obj := .obj -}}
{{- $result := dict -}}
{{- range $key, $val := $obj }}
{{- if not (hasPrefix "__" $key) }}
{{- if kindIs "map" $val }}
{{- $_prefix := printf "%s_%s" $prefix (upper $key) }}
{{- $nestedResult := include "objectToEnvVarsList" (dict "obj" $val "prefix" $_prefix) | fromJson }}
{{- $result = merge $result $nestedResult }}
{{- else }}
{{- $_ := set $result (printf "%s_%s" $prefix (upper $key)) ($val | toString) }}
{{- end }}
{{- end }}
{{- end }}
{{- $result | toJson }}
{{- end }}

{{- define "generateArgs" -}}
{{- $prefix := "" -}}
{{- $separator := " " -}}
{{- $object := .object -}}
{{- $orderList := .order | default list -}}

{{- /* Extract and remove custom prefix and separator if defined */ -}}
{{- if hasKey $object "__prefix" -}}
  {{- $prefix = $object.__prefix -}}
  {{- $object = omit $object "__prefix" -}}
{{- end -}}
{{- if hasKey $object "__separator" -}}
  {{- $separator = $object.__separator -}}
  {{- $object = omit $object "__separator" -}}
{{- end -}}

{{- /* Process the object and create initial list */ -}}
{{- $result := list -}}
{{- range $key, $value := $object -}}
  {{- if kindIs "string" $value -}}
    {{- if eq $value "__none" -}}
      {{- $result = append $result (printf "%s%s" $prefix $key) -}}
    {{- else -}}
      {{- $result = append $result (printf "%s%s %s" $prefix $key $value) -}}
    {{- end -}}
  {{- else if kindIs "bool" $value -}}
    {{- if $value -}}
      {{- $result = append $result (printf "%s%s" $prefix $key) -}}
    {{- end -}}
  {{- else if or (kindIs "float64" $value) (kindIs "int" $value) -}}
    {{- $result = append $result (printf "%s%s %v" $prefix $key $value) -}}
  {{- else -}}
    {{- $result = append $result (printf "%s%s %v" $prefix $key $value) -}}
  {{- end -}}
{{- end -}}

{{- /* Sort the result based on custom order if provided */ -}}
{{- if $orderList -}}
  {{- $sortedResult := list -}}
  {{- range $key := $orderList -}}
    {{- range $arg := $result -}}
      {{- if hasPrefix (printf "%s%s" $prefix $key) $arg -}}
        {{- $sortedResult = append $sortedResult $arg -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- range $arg := $result -}}
    {{- if not (has $arg $sortedResult) -}}
      {{- $sortedResult = append $sortedResult $arg -}}
    {{- end -}}
  {{- end -}}
  {{- $result = $sortedResult -}}
{{- end -}}

{{- /* Output as YAML */ -}}
{{- $result | toYaml -}}
{{- end -}}


{{- define "firehose-evm.unsetNullKeys" -}}
  {{- $obj := . -}}
  {{- range $key, $value := $obj -}}
    {{- if eq $value nil -}}
      {{- $_ := unset $obj $key -}}
    {{- else if kindIs "map" $value -}}
      {{- include "firehose-evm.unsetNullKeys" $value -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- define "firehose-evm.genericMerge" -}}
{{- $base := index . 0 -}}
{{- $override := index . 1 -}}

{{- /* Perform the deep merge, where the override object overwrites the base object */ -}}
{{- $merged := mergeOverwrite (deepCopy $base) $override -}}

{{- /* Now handle the keys explicitly set to null in the override object */ -}}
{{- range $key, $value := $override -}}
  {{- if eq $value nil -}}
    {{- $_ := unset $merged $key -}}
  {{- end -}}
{{- end -}}

{{- /* Preserve empty maps or lists by reverting to the base object if override has them */ -}}
{{- range $key, $value := $override -}}
  {{- if or (and (kindIs "map" $value) (eq (len $value) 0)) (and (kindIs "slice" $value) (eq (len $value) 0)) -}}
    {{- $baseValue := get $base $key -}}
    {{- if not (eq $baseValue nil) -}}
      {{- $_ := set $merged $key $baseValue -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- include "firehose-evm.unsetNullKeys" $merged -}}
{{- $merged | toYaml -}}
{{- end -}}

{{- define "firehose-evm.mergeListsByIdentifier" -}}
{{- $defaultList := index . 0 -}}
{{- $overrideList := index . 1 -}}
{{- $identifierField := index . 2 -}}

{{- $result := list -}}
{{- $overrideMap := dict -}}

{{- range $override := $overrideList -}}
  {{- $identifier := index $override $identifierField -}}
  {{- $_ := set $overrideMap $identifier $override -}}
{{- end -}}

{{- range $default := $defaultList -}}
  {{- $identifier := index $default $identifierField -}}
  {{- if hasKey $overrideMap $identifier -}}
    {{- $merged := mergeOverwrite (deepCopy $default) (index $overrideMap $identifier) -}}
    {{- $result = append $result $merged -}}
    {{- $_ := unset $overrideMap $identifier -}}
  {{- else -}}
    {{- $result = append $result $default -}}
  {{- end -}}
{{- end -}}

{{- range $identifier, $override := $overrideMap -}}
  {{- $result = append $result $override -}}
{{- end -}}

{{- $result | toYaml -}}
{{- end -}}

{{- define "firehose-evm.serviceMonitorConfig" -}}
{{- $defaults := index . 0 -}}
{{- $overrides := index . 1 -}}

{{- $merged := deepCopy $defaults -}}
{{- $merged := mergeOverwrite $merged $overrides -}}

{{- if and (hasKey $merged.spec "endpoints") (hasKey $overrides.spec "endpoints") -}}
  {{- $defaultEndpoints := $defaults.spec.endpoints -}}
  {{- $overrideEndpoints := $overrides.spec.endpoints -}}
  {{- $mergedEndpoints := list -}}

  {{- range $defaultEndpoint := $defaultEndpoints -}}
    {{- $port := $defaultEndpoint.port -}}
    {{- if hasKey $overrideEndpoints $port -}}
      {{- $mergedEndpoint := mergeOverwrite (deepCopy $defaultEndpoint) (index $overrideEndpoints $port) -}}
      {{- $mergedEndpoints = append $mergedEndpoints $mergedEndpoint -}}
    {{- else -}}
      {{- $mergedEndpoints = append $mergedEndpoints $defaultEndpoint -}}
    {{- end -}}
  {{- end -}}

  {{- $_ := set $merged.spec "endpoints" $mergedEndpoints -}}
{{- end -}}

{{- $merged | toYaml -}}
{{- end -}}

{{- define "helpers.initContainers" -}}
{{- $rootCtx := .rootCtx }}
{{- $podCtx := .podCtx }}

{{- /* Template and parse builtinContainers */}}
{{- $builtinContainers := include "chart.builtinInitContainers" (dict "Root" $rootCtx "Pod" $podCtx) | fromYaml }}

{{- /* Template and parse user-defined containers */}}
{{- $podContainers := tpl ( $podCtx.initContainers | toYaml ) (dict "Root" $rootCtx "Pod" $podCtx) | fromYaml }}

{{- /* Merge built-in and user-defined containers */}}
{{- $mergedContainers := dict }}
{{- range $name, $container := $podContainers }}
  {{- $containerDef := dict }}
  {{- if hasKey $builtinContainers $name }}
    {{- $containerDef = include "firehose-evm.genericMerge" (list ( index $builtinContainers $name ) $container) | fromYaml }}
  {{- else }}
    {{- $containerDef = $container }}
  {{- end }}
  {{- if eq ( get $containerDef "__condition" | default "true" ) "true" }}
    {{- $_ := set $mergedContainers $name $containerDef }}
  {{- end }}
{{- end }}

{{- $finalContainers := dict }}
{{- range $name, $container := $mergedContainers }}
  {{- if $container }}
    {{- $cleanedContainer := dict }}
    {{- range $key, $value := $container }}
      {{- if not (hasPrefix "__" $key) }}
        {{- $_ := set $cleanedContainer $key $value }}
      {{- end }}
    {{- end }}
    {{- $_ := set $finalContainers $name $cleanedContainer }}
  {{- end }}
{{- end }}

{{- $finalContainers | toYaml }}
{{- end }}

{{- define "helpers.evalCondition" -}}
{{- $condition := .condition }}
{{- if $condition }}
  {{- if eq (typeOf $condition) "string" }}
    {{- if tpl $condition (dict "Root" .Root "Pod" .Pod) }}true{{ else }}false{{ end }}
  {{- else if eq (typeOf $condition) "bool" }}
    {{- if $condition }}true{{ else }}false{{ end }}
  {{- else }}
    {{- printf "Error: Unsupported condition type: %s" (typeOf $condition) }}
  {{- end }}
{{- else }}
true
{{- end }}

{{- end }}


{{/*
Create the name of the role or cluster role for a specific component
*/}}
{{- define "firehose-evm.roleName" -}}
{{- $rootCtx := .Root -}}
{{- $componentName := .componentName -}}
{{- printf "%s-%s-role" (include "firehose-evm.fullname" .Root) $componentName -}}
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

{{- $result = include "firehose-evm.genericMerge" (list $result $global) | fromYaml -}}
{{- $result = include "firehose-evm.genericMerge" (list $result $component) | fromYaml -}}

{{- if kindIs "slice" $specific -}}
  {{- range $specific -}}
    {{- $result = include "firehose-evm.genericMerge" (list $result .) | fromYaml -}}
  {{- end -}}
{{- else -}}
  {{- $result = include "firehose-evm.genericMerge" (list $result $specific) | fromYaml -}}
{{- end -}}

{{- $ctx := dict "Root" $root "Pod" $pod "componentName" $componentName -}}
{{- $templated := tpl ($result | toYaml) $ctx | fromYaml -}}

{{- $templated | toYaml -}}
{{- end -}}



{{- define "firehose-evm.allLabels" -}}
{{- include "firehose-evm.mergeLabelsOrAnnotations" (dict "Root" .Root "Pod" .Pod "specific" .labels "componentName" .componentName "type" "labels") -}}
{{- end -}}

{{- define "firehose-evm.allAnnotations" -}}
{{- include "firehose-evm.mergeLabelsOrAnnotations" (dict "Root" .Root "Pod" .Pod "specific" .annotations "componentName" .componentName "type" "annotations") -}}
{{- end -}}
