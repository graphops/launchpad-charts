{{- $ := index . 0 }}
{{- $input := index . 1 }}

{{/* name in spec.endpoints is optional, we're enforcing as a unique key */}}
{{- $paths := list
(dict "path" "spec.endpoints" "indexKey" "port")
}}

{{- list $ $input $paths | include "common.utils.transformMapToList" }}
{{- $output := $.__common.fcallResult }}

{{- $_ := set $.__common "fcallResult" $output }}
