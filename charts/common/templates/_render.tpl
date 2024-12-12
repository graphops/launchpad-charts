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
{{- $base := tpl (index $.__common.resources $resourceName "defaults") (list $ $templateCtx) | fromYaml }}
{{- $_ := (list $ $base $resource) | include "common.utils.deepMerge" }}
{{- $result := $.__common.fcallResult }}
{{- if hasKey (index $.__common.resources $resourceName) "transforms" }}
{{- $transformsTpl := index $.__common.resources $resourceName "transforms" }}
{{- $_ := tpl $transformsTpl (list $ $result) }}
{{- $result = $.__common.fcallResult }}
{{- end }}
{{/* FIXME: Corner case is forcing prunning twice to mitigate */}}
{{- $_ := (list $ $result) | include "common.utils.pruneOutput" }}
{{- $prunedResult := $.__common.fcallResult }}
{{- $_ := (list $ $prunedResult) | include "common.utils.pruneOutput" }}
{{- $prunedResult := $.__common.fcallResult }}
{{ $prunedResult | toYaml }}
---
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{- end }}
