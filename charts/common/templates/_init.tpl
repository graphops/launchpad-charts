{{/* Performs initialization, loading of resources and initial merges */}}
{{- define "common.init._init" -}}
{{/* Initialize state store */}}
{{- $_ := set $ "__common" dict }}
{{/* Define the ordered steps */}}
{{- $initSteps := list
"common.init._setTemplateCtx"
"common.init._loadConfig"
"common.init._loadResources"
"common.resources.mergeValues"
}}
{{/* execute them with conditional output omission */}}
{{- range $step := $initSteps }}
{{- if $.Values.__debug }}
{{- include (printf "%s" $step) $ -}}
{{- else }}
{{- $_ := include (printf "%s" $step) $ -}}
{{- end }}
{{- end }}
{{- end }}

{{/*
Load and validate the library configuration.
Returns the validated config as a dict.
Usage: {{ include "common.loadConfig" . }}
*/}}
{{- define "common.init._loadConfig" }}
  {{/* First try to load from common.config.yaml */}}
  {{- $configFile := .Files.Get "_common.config.yaml" }}
  {{- if not $configFile }}
    {{- include "common.error.fail" "_common.config.yaml is required but was not found in the chart root dir" }}
  {{- end }}

  {{/* Parse YAML */}}
  {{- $config := fromYaml $configFile }}
  {{- if $config.Error }}
    {{- include "common.error.fail" (printf "%s\n%s" "_common.config.yaml failed unserializing with:" $config.Error) }}
  {{- end }}
  {{- $_ := set $.__common "config" $config }}

  {{- if $.Values.debug }}
    {{- include "common.debug.function" (dict
      "name" "init._loadConfig"
      "args" (list "_common.config.yaml")
      "result" $config)
    }}
  {{- end }}

  {{/* Process Config */}}
  {{- include "common.init._processConfig" $ }}
{{- end -}}

{{- define "common.init._processConfig" }}
{{- $config := $.__common.config }}

{{/* Process components layout */}}

{{- if and
    (hasKey $config "components")
    (kindIs "slice" $config.components) }}
  {{- $_ := set $.__common.config "components" $config.components }}
  {{- $_ := set $.__common.config "componentLayering" $config.componentLayering }}
{{- else if and
    (eq $config.dynamicComponents true)
    (hasKey $config "componentsKey") }}
  {{- $_ := set $.__common.config "structureType" "dynamic-components" }}
  {{/* components will be the subkeys found in componentsKey */}}
  {{- $components := keys (index $.Values $config.componentsKey) }}
  {{/* componentLayering is expected to be a template that returns the layering map for the components, JSON Serialized.
      the templating context, at this moment, does not include .Self or .ComponentValues for obvious reasons.
      As such, this is templated with the global context $ */}}
  {{- $componentLayering := tpl $config.componentLayering $ | fromJson }}
  {{- $_ := set $.__common.config "components" $components }}
  {{- $_ := set $.__common.config "componentLayering" $componentLayering }}
{{- else }}
  {{- fail (printf "\n\n!!ERROR!! %s\n" "Failed _common.config.yaml validation of components section") }}
{{- end }}

{{- if $.Values.debug }}
  {{- include "common.debug.function" (dict
    "name" "init._processConfig"
    "args" list
    "result" $config)
  }}
{{- end }}

{{- end }}

{{- define "common.init._loadResources" }}
{{- $resources := dict }}

{{- $files := $.Subcharts.common.Files.Glob "kubernetesResources/**/config.yaml" }}
{{- range $path, $_ := $files }}
  {{/* Split path into segments */}}
  {{- $segments := splitList "/" $path }}
  {{/* Get directory name (4th segment since path starts with charts/common/kubernetesResources/) */}}
  {{- $dirName := index $segments 1 }}
  {{/* Get file name (last segment) */}}
  {{- $fileName := base $path }}
  {{- $res := ($.Subcharts.common.Files.Get $path | fromYaml) }}
  {{- $_ := set $resources $dirName $res }}
  {{- range $path, $_ := $.Subcharts.common.Files.Glob (printf "%s/%s/*" "kubernetesResources" $dirName) }}
  {{- $fileName := base $path }}
  {{- if eq $fileName "base.yaml" }}
  {{- $_ := set $res "defaults" ($.Subcharts.common.Files.Get $path) }}
  {{- end }}
  {{- if eq $fileName "transforms.tpl" }}
  {{- $_ := set $res "transforms" ($.Subcharts.common.Files.Get $path) }}
  {{- end }}
  {{- end }}
  {{- $_ := set $resources $dirName $res }}
{{- end }}

{{- $_ := set $.__common "resources" $resources }}

{{- $_ := set $.__common "resourceKeysMap" dict }}
{{- range $resKey, $res := $resources }}
{{- $_ := set $.__common.resourceKeysMap $resKey $res.resourceKeys }}

{{- if $.Values.debug }}
  {{- include "common.debug.function" (dict
    "name" "init._loadResources"
    "args" list
    "result" (list $resources $.__common.resourceKeysMap))
  }}
{{- end }}
{{- end }}

{{- $_ := set $.__common "initContainers" dict }}
{{- $files := $.Subcharts.common.Files.Glob "initContainers/*.{yaml,yml}" }}
{{- range $path, $_ := $files }}
{{- $initContainer := $.Subcharts.common.Files.Get $path | fromYaml }}
{{- $initContainerName := regexReplaceAll "\\.(yaml|yml)$" (base $path) "" }}
{{- $_ := set $.__common.initContainers $initContainerName $initContainer }}
{{- end }}

{{- end }}

{{- define "common.init._setTemplateCtx" }}

{{- $rootCtx := deepCopy (omit $ "__common") }}
{{ $_ := set $rootCtx "Chart" ( $rootCtx.Chart | toJson | fromJson ) }}
{{- range $key, $value := $rootCtx.Chart }}
{{ $newKey := printf "%s%s" ( $key | substr 0 1 | upper ) ( $key | substr 1 -1 ) }}
{{ $_ := set $rootCtx.Chart $newKey $value }}
{{ $_ := unset $rootCtx.Chart $key }}
{{- end }}
{{ $_ := set $rootCtx.Chart "APIVersion" $rootCtx.Chart.ApiVersion }}
{{ $_ := unset $rootCtx.Chart "ApiVersion" }}

{{- $templateCtx := dict "Root" $rootCtx "ComponentValues" dict }}

{{ $_ := set $.__common "templateCtx" $templateCtx }}

{{- end }}
