{{/*
  This helper function processes and merges init containers for a Kubernetes pod.
  It combines built-in containers with user-defined containers, applying templating and conditional inclusion.
  Parameters:
    . (map): A map containing three keys with the standard templating context:
      - Root: The root context of the chart
      - Pod: The context specific to the pod
      - containerName: The name of the container being processed
  Usage:
    {{ include "resources.initContainers" (dict "Root" $ "Pod" $values "componentName" $componentName) | nindent 8 }}
  The helper does the following:
  1. Templates and parses built-in containers
  2. Templates and parses user-defined containers
  3. Merges built-in and user-defined containers, with user-defined taking precedence
  4. Processes the merged containers, applying the enabled condition and removing internal keys
  5. Outputs the final containers as YAML
*/}}
{{- define "resources.initContainers" -}}
{{- $rootCtx := .Root }}
{{- $podCtx := .Pod }}
{{- $componentName := .componentName }}
{{- $templateCtx := deepCopy $ }}
{{/* Get chart-defined init containers */}}
{{- $chartInitContainers := include "def.chartInitContainers" $templateCtx | fromYaml }}

{{/* Process user-defined containers, merging with chart-defined if they exist */}}
{{- $finalContainers := list }}
{{- range $name, $container := $podCtx.initContainers }}
  {{- if ne $container.enabled false }}
    {{- $chartContainer := get $chartInitContainers $name }}
    {{- $mergedContainer := dict }}
    {{- if $chartContainer }}
      {{- $mergedContainer = include "utils.deepMerge" (list $chartContainer $container) | fromYaml }}
    {{- else }}
      {{- $mergedContainer = $container }}
    {{- end }}
    {{- $cleanedContainer := dict }}
    {{- if not ( hasKey $mergedContainer "name" ) }}
      {{- $_ := set $mergedContainer "name" $name }}
    {{- end }}
    {{- range $key, $value := (omit $mergedContainer "enabled") }}
      {{- if not ( hasPrefix "_" $key ) }}
        {{- $_ := set $cleanedContainer $key $value }}
      {{- end }}
    {{- end }}
    {{- $finalContainers = append $finalContainers $cleanedContainer }}
  {{- end }}
{{- end }}

{{- $finalContainers | toYaml }}
{{- end }}


{{- define "resources.serviceMonitorConfig" -}}
{{/*
serviceMonitorConfig: Merges ServiceMonitor configurations with special handling for endpoints list.
Purpose:
- Merges default and override ServiceMonitor configurations.
- Provides special handling for the 'endpoints' list, allowing overrides based on the 'port' property.

Parameters:
- . (list): List containing two elements:
  1. defaults (map): Default ServiceMonitor configuration.
  2. overrides (map): Override ServiceMonitor configuration.

Behavior:
- Performs deep merge of default and override configurations.
- For 'endpoints' list, allows overriding specific endpoints based on their 'port' value.
- Endpoints not specified in override are kept from default configuration.
- New endpoints in override are added to the result.

Usage:
- list $defaults $overrides | include "firehose-evm.serviceMonitorConfig"

Example:
- Input: {
    "defaults": {"spec": {"endpoints": [{"port": "http", "path": "/metrics"}]}},
    "overrides": {"spec": {"endpoints": {"http": {"interval": "30s"}}}}
  }
- Result: {
    "spec": {"endpoints": [{"port": "http", "path": "/metrics", "interval": "30s"}]}
  }
*/}}
{{- $defaults := index . 0 -}}
{{- $overrides := index . 1 -}}

{{- $specialPaths := list (dict "path" "spec.endpoints" "indexKey" "port") -}}

{{- list $defaults $overrides $specialPaths | include "utils.smartMerge" -}}
{{- end -}}

{{- define "resources.serviceConfig" -}}
{{/*
serviceConfig: Merges Service configurations with special handling for ports list.
Purpose:
- Merges default and override Service configurations.
- Provides special handling for the 'ports' list, allowing overrides based on the 'port' property.

Parameters:
- . (list): List containing two elements:
  1. defaults (map): Default ServiceMonitor configuration.
  2. overrides (map): Override ServiceMonitor configuration.

Behavior:
- Performs deep merge of default and override configurations.
- For 'ports' list, allows overriding specific endpoints based on their 'name' value.
- Endpoints not specified in override are kept from default configuration.
- New endpoints in override are added to the result.

Usage:
- list $defaults $overrides | include "firehose-evm.serviceMonitorConfig"

Example:
- Input: {
    "defaults": {"spec": {"endpoints": [{"port": "http", "path": "/metrics"}]}},
    "overrides": {"spec": {"endpoints": {"http": {"interval": "30s"}}}}
  }
- Result: {
    "spec": {"endpoints": [{"port": "http", "path": "/metrics", "interval": "30s"}]}
  }
*/}}
{{- $defaults := index . 0 -}}
{{- $overrides := index . 1 -}}

{{- $specialPaths := list (dict "path" "spec.ports" "indexKey" "name") -}}

{{- list $defaults $overrides $specialPaths | include "utils.smartMerge" -}}
{{- end -}}


{{- define "resources.generateConfigMap" -}}
{{ .Pod.configMap.options.template }}
{{- end }}


{{- define "resources.mergeValues" }}
{{- $rootCtx := deepCopy .Root }}
{{- $componentName := .componentName }}

{{- $commonValues := .Root.Values.firehoseComponentDefaults }}
{{- $componentValues := index .Root.Values.firehoseComponents $componentName }}
{{- $perServiceDefaults := list }}
{{- range $service := $componentValues.fireeth.services | default list }}
{{- $perServiceDefaults = append $perServiceDefaults (index $rootCtx.Values.firehoseServiceDefaults $service) }}
{{- end }}
{{- $mergedValues := concat (list $commonValues) $perServiceDefaults (list $componentValues) | include "utils.deepMerge" | fromYaml }}

{{ $_ := set $rootCtx "Chart" ( $rootCtx.Chart | toYaml | fromYaml ) }}
{{- range $key, $value := $rootCtx.Chart }}

{{ $newKey := printf "%s%s" ( $key | substr 0 1 | upper ) ( $key | substr 1 -1 ) }}
{{ $_ := set $rootCtx.Chart $newKey $value }}
{{ $_ := unset $rootCtx.Chart $key }}
{{- end }}
{{ $_ := set $rootCtx.Chart "APIVersion" $rootCtx.Chart.ApiVersion }}
{{ $_ := unset $rootCtx.Chart "ApiVersion" }}

{{- $templateCtx := dict "Root" $rootCtx "Pod" $mergedValues "componentName" $componentName }}

{{- $configMapTemplate := deepCopy $templateCtx.Pod.configMap.options.template }}
{{- $_ := set $templateCtx.Pod.configMap "options" (unset $templateCtx.Pod.configMap.options "template") }}

{{- $1stPassPod := get (include "utils.templateCollection" (list $templateCtx.Pod $templateCtx) | fromYaml) "result" }}
{{- $_ := set $templateCtx "Pod" $1stPassPod }}

{{- $tplConfigMap := get (include "utils.templateCollection" (list $configMapTemplate $templateCtx) | fromYaml) "result" }}
{{- $_ := set $templateCtx.Pod.configMap.options "template" $tplConfigMap }}

{{- $templateCtx | toYaml }}
{{- end }}
