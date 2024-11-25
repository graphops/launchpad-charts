{{- $ := index . 0 }}
{{- $input := index . 1 }}

{{- $paths := list
(dict "path" "subjects")
}}

{{- list $ $input $paths | include "common.utils.transformMapToList" }}
{{- $output := $.__common.fcallResult }}

{{- $_ := set $.__common "fcallResult" $output }}
