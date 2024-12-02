{{- define "common.render" }}
{{- if $.Values.debug }}
{{- include "common.init._init" $ }}
{{- else }}
{{- $_ := include "common.init._init" $ }}
{{- end }}
{{- $templateCtx := $.__common.config.templateCtx }}
{{- range $component, $componentValues := $templateCtx.ComponentValues }}
{{- if (default false $componentValues.__enabled) }}
{{- $_ := set $templateCtx "Self" $componentValues }}
{{- $_ := set $templateCtx "name" (printf "%s" $component) }}
{{- range $resourceName, $keysData := $.__common.resourceKeysMap }}
{{- $resourcesList := list }}
{{- if hasKey $keysData "single" }}
{{- range $resourceKey := $keysData.single }}
{{- if hasKey $componentValues $resourceKey }}
{{- $resource := index $componentValues $resourceKey }}
{{- if and (hasKey $resource "__enabled") (eq $resource.__enabled true) }}
{{- $resourcesList = append $resourcesList $resource }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- if hasKey $keysData "multiple" }}
{{- range $resourceKey := $keysData.multiple }}
{{- if hasKey $componentValues $resourceKey }}
{{- range $resourceName, $resource := (index $componentValues $resourceKey) }}
{{- if and (hasKey $resource "__enabled") (eq $resource.__enabled true) }}
{{- $resourcesList = append $resourcesList $resource }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- range $resource := $resourcesList }}
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
