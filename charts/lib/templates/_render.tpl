{{ define "lib.render" }}
{{ include "lib.init._loadConfig" $ }}
{{ include "lib.init._loadResources" $ }}
{{ include "lib.resources.mergeValues" $ }}
{{- $templateCtx := $.__lib.config.templateCtx }}
{{- range $component, $componentValues := $templateCtx.ComponentValues }}
{{- $_ := set $templateCtx "Self" $componentValues }}
{{- range $resourceName, $keys := $.__lib.resourceKeysMap }}
{{- range $resourceKey := $keys }}
{{- if hasKey $componentValues $resourceKey }}
{{- $resource := index $componentValues $resourceKey }}
{{- $resourcesList := list }}
{{- if eq (kindOf $resource) "map" }}
{{- $resourcesList := append $resourcesList $resource }}
{{- else if eq (kindOf $resource) "slice" }}
{{- $resourcesList := concat $resourcesList $resource }}
{{- end }}
{{- $base := tpl (index $.__lib.resources $resourceName "skeleton") $templateCtx }}
{{- $result := list $base $resource | include "lib.utils.deepMerge" | fromYaml -}}
{{ fail (printf "%v" $base) }}
{{ $result | toYaml }}
-----------
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{- end }}
