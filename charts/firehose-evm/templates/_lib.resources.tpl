{{/*
  This helper function processes and merges init containers for a Kubernetes pod.
  It combines built-in containers with user-defined containers, applying templating and conditional inclusion.
  Parameters:
    . (map): A map containing three keys with the standard templating context:
      - Root: The root context of the chart
      - Pod: The context specific to the pod
      - containerName: The name of the container being processed
  Usage:
    {{ include "resources.initContainers" (dict "Root" $ "Pod" $values "containerName" $containerName) | nindent 8 }}
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
{{- $templateCtx := dict "Root" $rootCtx "Pod" $podCtx "componentName" $componentName }}
{{/* Template and parse container definitions */}}
{{- $chartInitContainers := include "def.chartInitContainers" $templateCtx | fromYaml }}
{{- $podContainers := list $podCtx.initContainers $templateCtx | include "utils.templateCollection" | fromYaml }}
{{/* Merge built-in and user-defined containers */}}
{{- $mergedContainers := include "utils.deepMerge" (list $chartInitContainers $podContainers) | fromYaml }}
{{/* Process merged containers */}}
{{- $finalContainers := list }}
{{- range $name, $container := $mergedContainers }}
  {{- if eq ( get $container "enabled" | default "true" ) "true" }}
    {{- $cleanedContainer := dict }}
    {{- if not ( hasKey $container "name" ) }}
      {{- $_ := set $container "name" $name }}
    {{- end }}
    {{- range $key, $value := $container }}
      {{- if not ( hasPrefix "_" $key ) }}
        {{- $_ := set $cleanedContainer $key $value }}
      {{- end }}
    {{- end }}
    {{- $finalContainers = append $finalContainers $cleanedContainer }}
  {{- end }}
{{- end }}
{{- $finalContainers | toYaml }}
{{- end }}


{{- define "firehose-evm.serviceMonitorConfig" -}}
{{/*
serviceMonitorConfig: Merges ServiceMonitor configurations with special handling for endpoints.
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

{{- $specialPaths := list (dict "path" "spec.endpoints" "indexProperty" "port") -}}

{{- $mergeInput := dict "base" $defaults "override" $overrides "specialPaths" $specialPaths -}}
{{- list $defaults $overrides $specialPaths | include "utils.smartMerge" -}}
{{- end -}}
