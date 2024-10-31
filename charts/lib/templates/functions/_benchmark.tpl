{{- define "lib.benchmark" -}}
  {{/* Create large test data */}}
  {{- $largeData := dict -}}
  {{- range untilStep 0 1000 1 -}}
    {{- $_ := set $largeData (printf "key%d" .) (dict "nestedKey" (printf "value%d" .)) -}}
  {{- end -}}

  {{/* Approach 1: JSON serialization
   */}}
  {{- range untilStep 0 100 1 -}}
    {{- $serialized := $largeData | toYaml -}}
    {{- $deserialized := fromYaml $serialized -}}
  {{- end -}}

  {{/* Approach 2: Direct context
  {{- range untilStep 0 100 1 -}}
    {{- $_ := set . "__lib_data" $largeData -}}
    {{- $accessed := .__lib_data -}}
  {{- end -}}
   */}}
{{- end -}}
