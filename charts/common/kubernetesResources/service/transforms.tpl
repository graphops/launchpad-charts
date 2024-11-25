{{- $ := index . 0 }}
{{- $input := index . 1 }}

{{/* name in spec.ports is optional, we're enforcing as a unique key */}}
{{- $paths := list
(dict "path" "spec.ports" "indexKey" "name")
}}

{{- list $ $input $paths | include "common.utils.transformMapToList" }}
{{- $output := $.__common.fcallResult }}

{{- $_ := set $.__common "fcallResult" $output }}
