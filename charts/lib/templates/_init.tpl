{{- define "lib.error.fail" }}
{{- $message := . -}}
{{- printf "\n\n!!ERROR!! %s \n\n" $message | fail }}
{{- end }}


{{- define "lib.init._init" -}}
{{ include "lib.init._loadConfig" $ }}
{{ include "lib.init._loadResources" $ }}
{{ include "lib.resources.mergeValues" $ }}
{{- end -}}

{{/*
Load and validate the library configuration.
Returns the validated config as a dict.
Usage: {{ include "lib.loadConfig" . }}
*/}}
{{- define "lib.init._loadConfig" }}
  {{/* Initialize state store */}}
  {{- $_ := set $ "__lib" dict }}

  {{/* First try to load from lib.config.yaml */}}
  {{- $configFile := .Files.Get "_lib.config.yaml" -}}
  {{- if not $configFile -}}
    {{- include "lib.error.fail" "_lib.config.yaml is required but was not found in the chart root dir" }}
  {{- end -}}

  {{/* Parse YAML */}}
  {{- $config := fromYaml $configFile }}
  {{- if $config.Error }}
    {{- include "lib.error.fail" (printf "%s\n%s" "_lib.config.yaml failed unserializing with:" $config.Error) }}
  {{- end }}
  {{- $_ := set $.__lib "config" $config }}

  {{/* Process Config */}}
  {{- include "lib.init._processConfig" $ }}
{{- end -}}


{{- define "lib.init._processConfig" }}
{{- $config := $.__lib.config }}

{{/* Process components layout */}}
{{- if and
    (hasKey $config "components")
    (kindIs "slice" $config.components) -}}
  {{- $_ := set $.__lib.config "structureType" "static-components" }}
{{- else if and
    (eq $config.dynamicComponents true)
    (hasKey $config "tlkComponents") }}
  {{- $_ := set $.__lib.config "structureType" "dynamic-components" }}
{{- else }}
  {{- fail (printf "\n\n!!ERROR!! %s\n" "Failed _lib.config.yaml validation of components section") }}
{{- end }}

{{- $_ := set $.__lib.config "inheritLists" (dict "statefulNode" (list "erigonDefaults" "statefulNode") "rpcdaemon" (list "erigonDefaults" "rpcdaemon")) }}

{{- end }}

{{- define "lib.init._loadResources" }}
{{- $resources := dict }}

{{- $_ := set $resources "secret" (include "lib.resources.secret" $ | fromYaml) }}
{{- $_ := set $resources.secret "defaults" (include "lib.resources.secret.defaults" $) }}

{{- $_ := set $resources "workload" (include "lib.resources.workload" $ | fromYaml) }}
{{- $_ := set $resources.workload "defaults" (include "lib.resources.workload.defaults" $) }}

{{- $_ := set $.__lib "resources" $resources }}

{{- $_ := set $.__lib "resourceKeysMap" dict }}
{{- range $resKey, $res := $resources }}
{{- $_ := set $.__lib.resourceKeysMap $resKey $res.resourceKeys }}
{{- end }}

{{- end }}
