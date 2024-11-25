{{- $ := index . 0 }}
{{- $input := index . 1 }}

{{- $paths := list
(dict "path" "spec.template.spec.volumes" "indexKey" "name")
}}

{{- $containers := dig "spec" "template" "spec" "containers" dict $input }}
{{- range $containerName, $container := $containers }}
{{- $containerPaths := list
(dict "path" (printf "%s.%s.%s" "spec.template.spec.containers" $containerName "ports") "indexKey" "name")
}}
{{- $paths = concat $paths $containerPaths }}
{{- end }}

{{- list $ $input $paths | include "common.utils.transformMapToList" }}
{{- $output := $.__common.fcallResult }}

{{- $_ := set $.__common "fcallResult" $output }}
