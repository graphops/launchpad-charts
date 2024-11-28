{{- define "common.utils.deepMerge" -}}
{{/*
deepMerge: A versatile helper function for deep merging of multiple maps.
Purpose:
- Performs a deep merge of two or more maps.
- Accepts a variable number of input maps. Later maps in the input list take precedence over earlier ones.
  (i.e., values from maps listed last will override those from maps listed first)
- Removes keys set to null in higher-precedence maps.
- Maintains empty maps and slices from higher-precedence maps.
Usage:
- For two maps: list $map1 $map2 | include "utils.deepMerge"
- For multiple maps: list $map1 $map2 $map3 ... | include "utils.deepMerge"
*/ -}}
{{- $length := len . -}}
{{- if eq $length 0 -}}
  {{- dict | toJson -}}
{{- else if eq $length 1 -}}
  {{- get ( include "common.utils.removeNulls" ( index . 0 ) | fromJson ) "result" | toJson -}}
{{- else -}}
  {{- $last := index . (sub $length 1) -}}
  {{- $initial := slice . 0 (sub $length 1) | include "common.utils.deepMerge" | fromJson -}}

{{/* Merge two maps excluding keys set to null */}}
  {{- $merged := dict -}}

  {{- range $key, $baseValue := $initial -}}
    {{- if ne $baseValue nil }}
      {{- if hasKey $last $key -}}
        {{- $overrideValue := index $last $key -}}
        {{- if and (kindIs "map" $baseValue) (kindIs "map" $overrideValue) -}}
          {{- $nestedMerge := list $baseValue $overrideValue | include "common.utils.deepMerge" | fromJson -}}
          {{- $_ := set $merged $key $nestedMerge -}}
        {{- else -}}
          {{- $_ := set $merged $key $overrideValue -}}
        {{- end -}}
      {{- else -}}
        {{- $_ := set $merged $key $baseValue -}}
      {{- end -}}
    {{- end }}
  {{- end -}}

  {{- range $key, $value := $last -}}
    {{- if and (not (hasKey $initial $key)) (ne $value nil) -}}
      {{- $_ := set $merged $key $value -}}
    {{- end -}}
  {{- end -}}

  {{- $merged | toJson -}}
{{- end -}}
{{- end -}}


{{- define "common.utils.removeNulls" -}}
  {{- $value := . -}}
  {{- $result := dict -}}
  {{- if kindIs "map" $value -}}
    {{- $newMap := dict -}}
    {{- range $k, $v := $value -}}
      {{- if not (eq $v nil) -}}
        {{- $nestedResult := include "common.utils.removeNulls" $v | fromJson -}}
        {{- if $nestedResult -}}
          {{- if kindIs "map" $nestedResult -}}
            {{- if hasKey $nestedResult "result" -}}
              {{- $newMap = set $newMap $k (get $nestedResult "result") -}}
            {{- else -}}
              {{- /* Preserve empty maps */ -}}
              {{- $newMap = set $newMap $k dict -}}
            {{- end -}}
          {{- else -}}
            {{- $newMap = set $newMap $k $nestedResult -}}
          {{- end -}}
        {{- else -}}
          {{- $newMap = set $newMap $k $v -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}
    {{- $result = set $result "result" $newMap -}}
  {{- else if kindIs "slice" $value -}}
    {{- $newSlice := list -}}
    {{- range $v := $value -}}
      {{- if not (eq $v nil) -}}
        {{- $nestedResult := include "common.utils.removeNulls" $v | fromJson -}}
        {{- if $nestedResult -}}
          {{- if kindIs "map" $nestedResult -}}
            {{- if hasKey $nestedResult "result" -}}
              {{- $newSlice = append $newSlice (get $nestedResult "result") -}}
            {{- else -}}
              {{- /* Preserve empty maps */ -}}
              {{- $newSlice = append $newSlice dict -}}
            {{- end -}}
          {{- else -}}
            {{- $newSlice = append $newSlice $nestedResult -}}
          {{- end -}}
        {{- else -}}
          {{- $newSlice = append $newSlice $v -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}
    {{- $result = set $result "result" $newSlice -}}
  {{- else -}}
    {{- if not (eq $value nil) -}}
      {{- $result = set $result "result" $value -}}
    {{- end -}}
  {{- end -}}
  {{- $result | toJson -}}
{{- end -}}

{{- define "common.utils.templateCollection" -}}
{{/*
  This helper function templates all string elements within a collection, element by element.
  It is meant to be used for collections (maps or lists). Can also be used with primitive values.
  When used with a primitive value, returns a templated string or the other types non-templated.

  Parameters:
    . (list): list of two elements:
    0. collection: The collection containing elements to be templated
    1. templateCtx: The context to use for templating

  Usage:
    {{- $templatedCollection := list $myCollection $templateCtx | include "utils.templateCollection" -}}
    If wanting to unserialize it, remember that for a map use:
    {{- $templatedCollection | fromJson }}
    while for an array, fromJsonArray
    {{- $templatedCollection | fromJson }}
*/}}

{{- $collection := index . 0 }}
{{- if not (empty $collection) }}
{{- $collection = deepCopy $collection -}}
{{- end }}
{{- $templateCtx := deepCopy ( index . 1 ) -}}

{{/* Process the collection */}}
{{- if kindIs "string" $collection -}}
{{- if not (regexMatch ".*\\{\\{.*" $collection) -}}
{{- printf "{\"result\": %v}" $collection -}}
{{- else -}}
  {{/* this is to allow to preserve types other than strings */}}
  {{/* to preserve empty strings, relevant for apiGroups in Roles */}}
  {{- if empty $collection }}
    {{- print "{\"result\": \"\"}" }}
  {{- else }}
    {{- $tempStr := printf "%s: %v" "result" ( $collection ) }}
    {{- tpl $tempStr $templateCtx | fromYaml | toJson }}
  {{- end }}
{{- end }}
{{- else if kindIs "map" $collection -}}
  {{- $result := dict -}}
  {{- range $key, $value := $collection -}}
    {{- $processedValue := list $value $templateCtx | include "common.utils.templateCollection" | fromJson -}}
    {{- $result = set $result $key $processedValue.result -}}
  {{- end -}}
  {{- include "common.utils.removeNulls" $result -}}
{{- else if kindIs "slice" $collection -}}
  {{- $result := list -}}
  {{- range $value := $collection -}}
    {{- $processedValue := list $value $templateCtx | include "common.utils.templateCollection" | fromJson -}}
    {{- $result = append $result $processedValue.result -}}
  {{- end -}}
  {{- include "common.utils.removeNulls" $result -}}
{{- else -}}
  {{- dict "result" $collection | toJson -}}
{{- end -}}

{{- end -}}

{{- define "common.resources.mergeValues" }}

{{- $templateCtx := $.__common.templateCtx }}

{{- $mergedValues := dict }}
{{- range $component := $.__common.config.components }}
{{- $mergeList := list }}
{{- range $key := index $.__common.config.componentLayering (printf "%v" $component) }}
{{- $mergeList = append $mergeList (index $.Values $key) }}
{{- end }}
{{- $mergeList = append $mergeList (index $.Values (printf "%v" $component)) }}
{{- $mergedValues = (deepCopy $mergeList) | include "common.utils.deepMerge" | fromJson }}
{{ $_ := set $templateCtx.ComponentValues (printf "%v" $component) $mergedValues }}
{{- end }}

{{- $_ := set $.__common.config "templateCtx" $templateCtx }}

{{- $templatedValues := dict }}
{{- range $component, $values := $templateCtx.ComponentValues }}
{{- $_ := set $templateCtx "Self" $values }}
{{- $templatedValues := get (include "common.utils.templateCollection" (list $values $templateCtx) | fromJson) "result" }}
{{- if $.Values.debug -}}
  {{- include "common.debug.function" (dict
    "name" (printf "%s%s" "Templating component values for " $component)
    "args" (list $templateCtx)
    "result" $templatedValues)
  -}}
{{- end -}}
{{- $_ := set $templateCtx.ComponentValues (printf "%v" $component) $templatedValues }}
{{- end }}

{{- $1stPassPod := get (include "common.utils.templateCollection" (list $templateCtx.ComponentValues $templateCtx) | fromJson) "result" }}
​
{{- if $.Values.debug -}}
  {{- include "common.debug.function" (dict
    "name" "resources.mergeValues"
    "args" list
    "result" $templateCtx)
  -}}
{{- end -}}

{{- $_ := set $.__common.config.templateCtx "ComponentValues" $templateCtx.ComponentValues }}

{{- end }}







{{- define "common.utils.transformMapToList" -}}
{{- $ := index . 0 -}}
{{- $base := index . 1 -}}
{{- $paths := index . 2 -}}

{{- range $pathObj := $paths -}}
    {{- $segments := splitList "." $pathObj.path -}}

    {{/* Try to get to parent, skip if any segment doesn't exist */}}
    {{- $parent := $base -}}
    {{- $validPath := true -}}
    {{- $pathLength := len $segments -}}

    {{- if gt $pathLength 1 -}}
        {{- range $idx, $segment := $segments -}}
            {{- if lt $idx (sub $pathLength 1) -}}
                {{- if not (hasKey $parent $segment) -}}
                    {{- $validPath = false -}}
                {{- else -}}
                    {{- $parent = index $parent $segment -}}
                {{- end -}}
            {{- end -}}
        {{- end -}}

        {{- if $validPath -}}
            {{- $lastKey := index $segments (sub $pathLength 1) -}}
            {{- if hasKey $parent $lastKey -}}
                {{- $current := index $parent $lastKey -}}
                {{/* Only process if we have a map to transform */}}
                {{- if kindIs "map" $current -}}
                    {{/* Pre-allocate resultList */}}
                    {{- $resultList := list -}}
                    {{/* Handle defaultFor outside inner loop if present */}}
                    {{- $hasDefaults := hasKey $pathObj "defaultFor" -}}
                    {{- $defaults := index $pathObj "defaultFor" | default list -}}
                    {{- range $key, $value := $current -}}
                        {{/* We need deepCopy here to prevent reference sharing between list items */}}
                        {{- $newObj := deepCopy $value -}}
                        {{- $_ := set $newObj $pathObj.indexKey $key -}}
                        {{/* Apply defaults if any exist */}}
                        {{- if $hasDefaults -}}
                            {{- range $defaultKey := $defaults -}}
                                {{- if not (hasKey $newObj $defaultKey) -}}
                                    {{- $_ := set $newObj $defaultKey $key -}}
                                {{- end -}}
                            {{- end -}}
                        {{- end -}}
                        {{- $resultList = append $resultList $newObj -}}
                    {{- end -}}
                    {{/* Direct mutation of parent */}}
                    {{- $_ := set $parent $lastKey $resultList -}}
                {{- end -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
{{- end -}}

{{/* Store result directly in global context */}}
{{- $_ := set $.__common "fcallResult" $base -}}
{{- end -}}


{{- define "common.utils.pruneOutput" -}}
{{- if kindIs "map" . -}}
    {{- if hasKey . "__enabled" -}}
        {{- if not .__enabled -}}
        {{- else -}}
            {{- $result := dict -}}
            {{- range $k, $v := . -}}
                {{- if not (hasPrefix "__" $k) -}}
                    {{- if or (kindIs "map" $v) (kindIs "slice" $v) -}}
                        {{- $processed := include "common.utils.pruneOutput" $v | fromJson -}}
                        {{- if or (not (eq $processed.result nil)) (kindIs "map" $v) (kindIs "slice" $v) -}}
                            {{- $_ := set $result $k $processed.result -}}
                        {{- end -}}
                    {{- else -}}
                        {{- if not (eq $v nil) -}}
                            {{- $_ := set $result $k $v -}}
                        {{- end -}}
                    {{- end -}}
                {{- end -}}
            {{- end -}}
            {{- dict "result" $result | toJson -}}
        {{- end -}}
    {{- else -}}
        {{- $result := dict -}}
        {{- range $k, $v := . -}}
            {{- if not (hasPrefix "__" $k) -}}
                {{- if or (kindIs "map" $v) (kindIs "slice" $v) -}}
                    {{- $processed := include "common.utils.pruneOutput" $v | fromJson -}}
                    {{- if or (not (eq $processed.result nil)) (kindIs "map" $v) (kindIs "slice" $v) -}}
                        {{- $_ := set $result $k $processed.result -}}
                    {{- end -}}
                {{- else -}}
                    {{- if not (eq $v nil) -}}
                        {{- $_ := set $result $k $v -}}
                    {{- end -}}
                {{- end -}}
            {{- end -}}
        {{- end -}}
        {{- dict "result" $result | toJson -}}
    {{- end -}}
{{- else if kindIs "slice" . -}}
    {{- $result := list -}}
    {{- range $v := . -}}
        {{- if or (kindIs "map" $v) (kindIs "slice" $v) -}}
            {{- $processed := include "common.utils.pruneOutput" $v | fromJson -}}
            {{- if or (not (eq $processed.result nil)) (kindIs "map" $v) (kindIs "slice" $v) -}}
                {{- $result = append $result $processed.result -}}
            {{- end -}}
        {{- else -}}
            {{- if not (eq $v nil) -}}
                {{- $result = append $result $v -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
    {{- dict "result" $result | toJson -}}
{{- else -}}
    {{- dict "result" . | toJson -}}
{{- end -}}
{{- end -}}
