{{- define "common.render" }}
{{- $_ := include "common.init._init" $ }}
{{- $templateCtx := $.__common.config.templateCtx }}
{{- range $component, $componentValues := $templateCtx.ComponentValues }}
{{- $_ := set $templateCtx "Self" $componentValues }}
{{- range $resourceName, $keys := $.__common.resourceKeysMap }}
{{- range $resourceKey := $keys }}
{{- if hasKey $componentValues $resourceKey }}
{{- $resource := index $componentValues $resourceKey }}
{{- if and (hasKey $resource "__enabled") (eq $resource.__enabled true) }}
{{- $resourcesList := list }}
{{- if eq (kindOf $resource) "map" }}
{{- $resourcesList = append $resourcesList $resource }}
{{- else if eq (kindOf $resource) "slice" }}
{{- $resourcesList = concat $resourcesList $resource }}
{{- end }}
{{- $base := tpl (index $.__common.resources $resourceName "defaults") $templateCtx | fromYaml }}
{{- $result := list $base $resource | include "common.utils.deepMerge" | fromJson }}
{{- if hasKey (index $.__common.resources $resourceName) "transforms" }}
{{- $transformsTpl := index $.__common.resources $resourceName "transforms" }}
{{- $_ := tpl $transformsTpl (list $ $result) }}
{{- $result = $.__common.fcallResult }}
{{- end }}
{{- $prunedResult := index (include "common.utils.pruneOutput" $result | fromJson) "result" }}
{{ $prunedResult | toYaml }}
---
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{- end }}
