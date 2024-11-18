{{- define "lib.render" }}
{{- $_ := include "lib.init._init" $ }}
{{- $templateCtx := $.__lib.config.templateCtx }}
{{- range $component, $componentValues := $templateCtx.ComponentValues }}
{{- $_ := set $templateCtx "Self" $componentValues }}
{{- range $resourceName, $keys := $.__lib.resourceKeysMap }}
{{- range $resourceKey := $keys }}
{{- if hasKey $componentValues $resourceKey }}
{{- $resource := index $componentValues $resourceKey }}
{{- $resourcesList := list }}
{{- if eq (kindOf $resource) "map" }}
{{- $resourcesList = append $resourcesList $resource }}
{{- else if eq (kindOf $resource) "slice" }}
{{- $resourcesList = concat $resourcesList $resource }}
{{- end }}
{{- $base := tpl (index $.__lib.resources $resourceName "defaults") $templateCtx | fromYaml }}
{{- $result := list $base $resource | include "lib.utils.deepMerge" | fromJson }}
{{- if hasKey (index $.__lib.resources $resourceName) "render" }}
{{- $transformsTpl := index $.__lib.resources $resourceName "transforms" }}
{{- $_ := tpl $transformsTpl (list $ $result) }}
{{- $result = $.__lib.fcallResult }}
{{- end }}
{{- if $result }}
{{ $result | toYaml }}
---
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{- end }}
