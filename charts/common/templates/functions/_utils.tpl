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

{{- $ = index . 0 }}
{{- $collection := index . 1 }}
{{- if not (empty $collection) }}
{{- $collection = deepCopy $collection -}}
{{- end }}
{{- $templateCtx := index . 2 -}}

{{/* Process the collection */}}
{{- if kindIs "string" $collection -}}
{{- if not (regexMatch ".*\\{\\{.*" $collection) -}}
{{- $_ := set $.__common "fcallResult" (dict "result" $collection) -}}
{{- else -}}
  {{- $templatedVal := tpl $collection $templateCtx }}
  {{- if contains "\n" (trim $templatedVal) }}
    {{- $_ := set $.__common "fcallResult" (dict "result" $templatedVal) }}
  {{- else }}
    {{- $_ := set $.__common "fcallResult" (printf "result: %v" $templatedVal | fromYaml) }}
  {{- end }}
{{- end }}
{{- else if kindIs "map" $collection -}}
  {{- $result := dict -}}
  {{- range $key, $value := $collection -}}
    {{- $_ := list $ $value $templateCtx | include "common.utils.templateCollection" -}}
    {{- $processedValue := $.__common.fcallResult.result -}}
    {{- $result = set $result $key $processedValue -}}
  {{- end -}}
  {{- $_ := set $.__common "fcallResult" (dict "result" $result) -}}
{{- else if kindIs "slice" $collection -}}
  {{- $result := list -}}
  {{- range $value := $collection -}}
    {{- $_ := list $ $value $templateCtx | include "common.utils.templateCollection" -}}
    {{- $processedValue := $.__common.fcallResult.result -}}
    {{- $result = append $result $processedValue -}}
  {{- end -}}
  {{- $_ := set $.__common "fcallResult" (dict "result" $result) -}}
{{- else -}}
  {{- $_ := set $.__common "fcallResult" (dict "result" $collection) -}}
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
{{- $_ := include "common.utils.templateCollection" (list $ $values $templateCtx) }}
{{- $templatedValues := $.__common.fcallResult.result }}
{{/* TODO: Temporarily template thrice until future work */}}
{{- $_ := include "common.utils.templateCollection" (list $ $templatedValues $templateCtx) }}
{{- $templatedValues = $.__common.fcallResult.result }}
{{- $_ := include "common.utils.templateCollection" (list $ $templatedValues $templateCtx) }}
{{- $templatedValues = $.__common.fcallResult.result }}
{{- if $.Values.debug -}}
  {{- include "common.debug.function" (dict
    "name" (printf "%s%s" "Templating component values for " $component)
    "args" (list $templateCtx)
    "result" $templatedValues)
  -}}
{{- end -}}
{{- $_ := set $templateCtx.ComponentValues (printf "%v" $component) $templatedValues }}
{{- end }}

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
                    {{- $hasIndexKey := and (hasKey $pathObj "indexKey") (not (empty $pathObj.indexKey)) -}}
                    {{- $defaults := index $pathObj "defaultFor" | default list -}}
                    {{- range $key, $value := $current -}}
                        {{/* We need deepCopy here to prevent reference sharing between list items */}}
                        {{- $newObj := deepCopy $value -}}
                        {{- if $hasIndexKey -}}
                        {{/* Strip any suffix after @ from the key, the
                             driver here is that often there is no single
                             unique parameter to use as indexKey */}}
                        {{- $baseKey := regexReplaceAll "@.*$" $key "" -}}
                        {{- $_ := set $newObj $pathObj.indexKey $baseKey -}}
                        {{/* Apply defaults if any exist */}}
                        {{- if $hasDefaults -}}
                            {{- range $defaultKey := $defaults -}}
                                {{- if not (hasKey $newObj $defaultKey) -}}
                                    {{- $_ := set $newObj $defaultKey $baseKey -}}
                                {{- end -}}
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

{{- define "common.utils.generateArgsList" -}}
{{/*
generateArgsList: A helper function to generate command-line arguments from a dictionary.
Purpose:
- Converts a dictionary of key-value pairs into a list of formatted command-line arguments.
- Handles special "__none" value to generate flags without values.
- Allows custom prefixing and separation of key-value pairs.
- Supports explicit custom ordering of some arguments with a list of keys.
  Ordered args come first, followed by remaining ones in the order provided by range.
- Optionally evaluates templating on the resulting strings
Parameters:
- map: Map of key-value pairs to convert to arguments
- orderList: List of keys to determine argument order (optional, default: [])
- <map>.__prefix: String to prepend to each key (optional, default: "")
- <map>.__separator: String to separate key and value (optional, default: " ")
Usage example:
  {{- $args := dict ".__prefix" "--" ".__separator" "=" "map" (dict "foo" "bar" "flag" "__none" "num" 42) "orderList" (list "flag" "foo") -}}
  {{- $result := include "utils.generateArgsList" $args | fromJson -}}
  Result: ["--flag", "--foo=bar", "--num=42"]
*/}}
{{- $map := .map -}}
{{- $orderList := default list .orderList -}}
{{- $prefix := default "" $map.__prefix -}}
{{- $separator := default " " $map.__separator -}}
{{- $templateCtx := deepCopy ( .templateCtx | default dict ) }}

{{- $result := list -}}
{{/* Process ordered arguments first */}}
{{- range $key := $orderList -}}
  {{- if hasKey $map $key -}}
    {{- $value := index $map $key -}}
    {{- if eq (printf "%v" $value) "__none" -}}
      {{- $result = append $result (printf "%s%s" $prefix $key) -}}
    {{- else -}}
      {{- $result = append $result (printf "%s%s%s%v" $prefix $key $separator $value) -}}
    {{- end -}}
    {{- $map = omit $map $key -}}
  {{- end -}}
{{- end -}}

{{/* Process remaining arguments excluding the internal "__" ones */}}
{{- range $key, $value := $map -}}
  {{- if not (hasPrefix "__" $key) -}}
    {{- if eq (printf "%v" $value) "__none" -}}
      {{- $result = append $result (printf "%s%s" $prefix $key) -}}
    {{- else -}}
      {{- $result = append $result (printf "%s%s%s%v" $prefix $key $separator $value) -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- $result | toJson -}}
{{- end -}}
