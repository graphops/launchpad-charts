{{- define "lib.error.fail" }}
{{- $message := . -}}
{{- printf "\n\n!!ERROR!! %s \n\n" $message | fail }}
{{- end }}


{{- define "lib.init._init" -}}
{{/* Initialize state store */}}
{{- $_ := set $ "__lib" dict }}
{{- include "lib.init._setTemplateCtx" $ -}}
{{- include "lib.init._loadConfig" $ -}}
{{- include "lib.init._loadResources" $ -}}
{{- include "lib.resources.mergeValues" $ -}}
{{- end }}

{{/*
Load and validate the library configuration.
Returns the validated config as a dict.
Usage: {{ include "lib.loadConfig" . }}
*/}}
{{- define "lib.init._loadConfig" }}
  {{/* First try to load from lib.config.yaml */}}
  {{- $configFile := .Files.Get "_lib.config.yaml" }}
  {{- if not $configFile }}
    {{- include "lib.error.fail" "_lib.config.yaml is required but was not found in the chart root dir" }}
  {{- end }}

  {{/* Parse YAML */}}
  {{- $config := fromYaml $configFile }}
  {{- if $config.Error }}
    {{- include "lib.error.fail" (printf "%s\n%s" "_lib.config.yaml failed unserializing with:" $config.Error) }}
  {{- end }}
  {{- $_ := set $.__lib "config" $config }}

  {{- if $.Values.debug }}
    {{- include "lib.debug.function" (dict
      "name" "init._loadConfig"
      "args" (list "_lib.config.yaml")
      "result" $config)
    }}
  {{- end }}

  {{/* Process Config */}}
  {{- include "lib.init._processConfig" $ }}
{{- end -}}

{{- define "lib.init._processConfig" }}
{{- $config := $.__lib.config }}

{{/* Process components layout */}}
{{- if and
    (hasKey $config "components")
    (kindIs "slice" $config.components) }}
  {{- $_ := set $.__lib.config "components" $config.components }}
  {{- $_ := set $.__lib.config "componentLayering" $config.componentLayering }}
{{- else if and
    (eq $config.dynamicComponents true)
    (hasKey $config "tlkComponents") }}
  {{- $_ := set $.__lib.config "structureType" "dynamic-components" }}
{{- else }}
  {{- fail (printf "\n\n!!ERROR!! %s\n" "Failed _lib.config.yaml validation of components section") }}
{{- end }}

{{- if $.Values.debug }}
  {{- include "lib.debug.function" (dict
    "name" "init._processConfig"
    "args" list
    "result" $config)
  }}
{{- end }}

{{- end }}

{{- define "lib.init._loadResources" }}
{{- $resources := dict }}

{{- $files := $.Subcharts.lib.Files.Glob "kubernetesResources/**/config.yaml" }}
{{- range $path, $_ := $files }}
  {{/* Split path into segments */}}
  {{- $segments := splitList "/" $path }}
  {{/* Get directory name (4th segment since path starts with charts/lib/kubernetesResources/) */}}
  {{- $dirName := index $segments 1 }}
  {{/* Get file name (last segment) */}}
  {{- $fileName := base $path }}
  {{- $res := ($.Subcharts.lib.Files.Get $path | fromYaml) }}
  {{- $_ := set $resources $dirName $res }}
  {{- range $path, $_ := $.Subcharts.lib.Files.Glob (printf "%s/%s/*" "kubernetesResources" $dirName) }}
  {{- $fileName := base $path }}
  {{- if eq $fileName "base.yaml" }}
  {{- $_ := set $res "defaults" ($.Subcharts.lib.Files.Get $path) }}
  {{- end }}
  {{- if eq $fileName "transforms.tpl" }}
  {{- $_ := set $res "transforms" ($.Subcharts.lib.Files.Get $path) }}
  {{- end }}
  {{- end }}
  {{- $_ := set $resources $dirName $res }}
{{- end }}

{{- $_ := set $.__lib "resources" $resources }}

{{- $_ := set $.__lib "resourceKeysMap" dict }}
{{- range $resKey, $res := $resources }}
{{- $_ := set $.__lib.resourceKeysMap $resKey $res.resourceKeys }}

{{- if $.Values.debug }}
  {{- include "lib.debug.function" (dict
    "name" "init._loadResources"
    "args" list
    "result" (list $resources $.__lib.resourceKeysMap))
  }}
{{- end }}
{{- end }}

{{- end }}

{{- define "lib.init._setTemplateCtx" }}

{{- $rootCtx := deepCopy (omit $ "__lib") }}
{{ $_ := set $rootCtx "Chart" ( $rootCtx.Chart | toJson | fromJson ) }}
{{- range $key, $value := $rootCtx.Chart }}
{{ $newKey := printf "%s%s" ( $key | substr 0 1 | upper ) ( $key | substr 1 -1 ) }}
{{ $_ := set $rootCtx.Chart $newKey $value }}
{{ $_ := unset $rootCtx.Chart $key }}
{{- end }}
{{ $_ := set $rootCtx.Chart "APIVersion" $rootCtx.Chart.ApiVersion }}
{{ $_ := unset $rootCtx.Chart "ApiVersion" }}

{{- $templateCtx := dict "Root" $rootCtx "ComponentValues" dict }}

{{ $_ := set $.__lib "templateCtx" $templateCtx }}

{{- end }}
