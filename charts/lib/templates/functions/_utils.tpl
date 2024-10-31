{{- define "lib.utils.deepMerge" -}}
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
  {{- get ( include "lib.utils.removeNulls" ( index . 0 ) | fromJson ) "result" | toJson -}}
{{- else -}}
  {{- $last := index . (sub $length 1) -}}
  {{- $initial := slice . 0 (sub $length 1) | include "lib.utils.deepMerge" | fromJson -}}

{{/* Merge two maps excluding keys set to null */}}
  {{- $merged := dict -}}

  {{- range $key, $baseValue := $initial -}}
    {{- if ne $baseValue nil }}
      {{- if hasKey $last $key -}}
        {{- $overrideValue := index $last $key -}}
        {{- if and (kindIs "map" $baseValue) (kindIs "map" $overrideValue) -}}
          {{- $nestedMerge := list $baseValue $overrideValue | include "lib.utils.deepMerge" | fromJson -}}
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


{{- define "lib.utils.removeNulls" -}}
  {{- $value := . -}}
  {{- $result := dict -}}
  {{- if kindIs "map" $value -}}
    {{- $newMap := dict -}}
    {{- range $k, $v := $value -}}
      {{- if not (eq $v nil) -}}
        {{- $nestedResult := include "lib.utils.removeNulls" $v | fromJson -}}
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
        {{- $nestedResult := include "lib.utils.removeNulls" $v | fromJson -}}
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

{{- define "lib.utils.templateCollection" -}}
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
{{- dict "result" $collection | toJson -}}
{{- else -}}
  {{/* this is to allow to preserve types other than strings */}}
  {{- if contains "\n" $collection }}
    {{- dict "result" ( tpl $collection $templateCtx ) | toJson }}
  {{/* to preserve empty strings, relevant for apiGroups in Roles */}}
  {{- else if empty $collection }}
    {{- printf "%s: %s" "result" "\"\"" }}
  {{- else }}
    {{- $tempStr := printf "%s: %v" "result" ( $collection ) }}
    {{- tpl $tempStr $templateCtx }}
  {{- end }}
{{- end }}
{{- else if kindIs "map" $collection -}}
  {{- $result := dict -}}
  {{- range $key, $value := $collection -}}
    {{- $processedValue := list $value $templateCtx | include "lib.utils.templateCollection" | fromJson -}}
    {{- $result = set $result $key $processedValue.result -}}
  {{- end -}}
  {{- include "lib.utils.removeNulls" $result -}}
{{- else if kindIs "slice" $collection -}}
  {{- $result := list -}}
  {{- range $value := $collection -}}
    {{- $processedValue := list $value $templateCtx | include "lib.utils.templateCollection" | fromJson -}}
    {{- $result = append $result $processedValue.result -}}
  {{- end -}}
  {{- include "lib.utils.removeNulls" $result -}}
{{- else -}}
  {{- dict "result" $collection | toJson -}}
{{- end -}}

{{- end -}}

{{- define "lib.resources.mergeValues" }}

{{- $rootCtx := deepCopy (omit $ "__lib") }}
{{ $_ := set $rootCtx "Chart" ( $rootCtx.Chart | toJson | fromJson ) }}
{{- range $key, $value := $rootCtx.Chart }}
{{ $newKey := printf "%s%s" ( $key | substr 0 1 | upper ) ( $key | substr 1 -1 ) }}
{{ $_ := set $rootCtx.Chart $newKey $value }}
{{ $_ := unset $rootCtx.Chart $key }}
{{- end }}
{{ $_ := set $rootCtx.Chart "APIVersion" $rootCtx.Chart.ApiVersion }}
{{ $_ := unset $rootCtx.Chart "ApiVersion" }}

{{- $templateCtx := dict "Root" $rootCtx "ComponentValues" dict }}

{{- $mergedValues := dict }}
{{- range $component, $values := $.__lib.config.component }}
{{- $mergeList := list }}
{{- $mergeList = append $mergeList (index $.Values $values.keyDefaults ) }}
{{- $mergeList = append $mergeList (index $.Values (printf "%v" $component)) }}
{{- $mergedValues = (deepCopy $mergeList) | include "lib.utils.deepMerge" | fromJson }}
{{ $_ := set $templateCtx.ComponentValues (printf "%v" $component) $mergedValues }}
{{- end }}

{{- $_ := set $.__lib.config "templateCtx" $templateCtx }}

{{- $1stPassPod := get (include "lib.utils.templateCollection" (list $templateCtx.ComponentValues $templateCtx) | fromJson) "result" }}

{{- $_ := set $.__lib.config.templateCtx "ComponentValues" $1stPassPod }}

{{/*

{{ $_ := set $rootCtx "Chart" ( $rootCtx.Chart | toJson | fromJson ) }}
{{- range $key, $value := $rootCtx.Chart }}

{{ $newKey := printf "%s%s" ( $key | substr 0 1 | upper ) ( $key | substr 1 -1 ) }}
{{ $_ := set $rootCtx.Chart $newKey $value }}
{{ $_ := unset $rootCtx.Chart $key }}
{{- end }}
{{ $_ := set $rootCtx.Chart "APIVersion" $rootCtx.Chart.ApiVersion }}
{{ $_ := unset $rootCtx.Chart "ApiVersion" }}

{{- $templateCtx := dict "Root" $rootCtx "Pod" $mergedValues "componentName" $componentName }}

{{- $configMapTemplate := deepCopy $templateCtx.Pod.configMap.options.template }}
{{- $_ := set $templateCtx.Pod.configMap "options" (unset $templateCtx.Pod.configMap.options "template") }}

{{- $1stPassPod := get (include "utils.templateCollection" (list $templateCtx.Pod $templateCtx) | fromJson) "result" }}
{{- $_ := set $templateCtx "Pod" $1stPassPod }}

{{- $tplConfigMap := get (include "utils.templateCollection" (list $configMapTemplate $templateCtx) | fromJson) "result" }}
{{- $_ := set $templateCtx.Pod.configMap.options "template" $tplConfigMap }}

{{- $templateCtx | toJson }}
*/}}
{{- end }}



{{- define "lib.utils.smartMerge" -}}
{{/*
Utils.smartMerge: A helper function for advanced merging of two maps with special handling of lists for specified paths.
Purpose:
- Performs a deep merge of two maps.
- Provides special handling for specified paths, allowing map-to-list merges based on a specified index property.
- Maintains the order of existing items in lists and adds new items in the order provided by range.

Parameters:
- . (list): A list of three elements:
  1. base (map): The base map
  2. override (map): The override map to be merged with base
  3. specialPaths (list): List of maps for special paths, each a map of:
    - path (string): Path to the special merge location.
    - indexKey (string): Key which value is used for matching with an override map top level key.
    - defaultFor (list): List of key names besides indexKey that will have as default the key name

Behavior:
- Performs initial deep merge of base and override maps.
- For each special path:
  - Extracts relevant parts of base and override maps.
  - Performs map-to-list merge using specified index key for matching.
  - Updates merged result with results from map-to-list merge.
- Handles nested special paths by processing from most to least nested.

Usage:
- list $base $override $specialPaths | include "utils.smartMerge"

Example:
- Input: {
    "base": {"spec": {"endpoints": [{"name": "http", "port": 8080}]}},
    "override": {"spec": {"endpoints": {"http": {"path": "/metrics"}}}},
    "specialPaths": [{"path": "spec.endpoints", "indexKey": "name"}]
  }
- Result: {
    "spec": {"endpoints": [{"name": "http", "port": 8080, "path": "/metrics"}]}
  }
*/}}
{{- $base := deepCopy (index . 0) -}}
{{- $override := deepCopy (index . 1) -}}
{{- $specialPaths := deepCopy (index . 2) -}}

{{/* Perform initial deep merge */}}
{{- $merged := list $base $override | include "lib.utils.deepMerge" | fromYaml -}}

{{/* Handle special merge paths */}}
{{- range $specialPath := $specialPaths -}}
  {{- $path := $specialPath.path -}}
  {{- $indexKey := $specialPath.indexKey -}}
  {{- $defaultFor := $specialPath.defaultFor | default list -}}

  {{- $baseValue := $base -}}
  {{- $overrideValue := $override -}}
  {{- $mergedValue := $merged -}}

  {{- $pathParts := splitList "." $path -}}
  {{- if and (gt (len $pathParts) 0) (eq (index $pathParts 0) "") -}}
    {{- $pathParts = slice $pathParts 1 -}}
  {{- end -}}
  {{- $lastIndex := sub (len $pathParts) 1 -}}

  {{- range $index, $part := $pathParts -}}
    {{- if eq $index $lastIndex -}}
      {{- $baseValue = index $baseValue $part -}}
      {{- $overrideValue = index $overrideValue $part -}}
      {{- $mergedValue = index $mergedValue $part -}}

      {{- if and (kindIs "slice" $baseValue) (kindIs "map" $overrideValue) -}}
        {{- $newMergedValue := list $baseValue $overrideValue $indexKey $defaultFor | include "lib.utils.mergeMapWithList" | fromYamlArray -}}

        {{/* Update the merged value at the specified path */}}
        {{- $currentPath := $merged -}}
        {{- range $partIndex, $pathPart := $pathParts -}}
          {{- if eq $partIndex $lastIndex -}}
            {{- $_ := set $currentPath $pathPart $newMergedValue -}}
          {{- else -}}
            {{- $currentPath = index $currentPath $pathPart -}}
          {{- end -}}
        {{- end -}}
      {{- end -}}
    {{- else -}}
      {{- $baseValue = index $baseValue $part -}}
      {{- $overrideValue = index $overrideValue $part -}}
      {{- $mergedValue = index $mergedValue $part -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- $merged | toYaml -}}
{{- end -}}

{{- define "lib.utils.mergeMapWithList" -}}
{{/*
utils.mergeMapWithList: A helper function for merging a map with a list of maps.
Purpose:
- Merges a list (of maps) with a map, matching the map keys with the maps on the list on the value of some specific key (indexKey).
- Allows for selective updating or removal of the maps in the list.
- Maintains the order of the original list for existing items.
- Adds new items from the override map in the order provided by range.

Parameters:
- . (list): Containing three elements:
  1. baseList (list): The original list of maps to be merged.
  2. overrideMap (map): A map of overrides, where top level keys match with the indexKey of the maps on the base list
  3. indexKey (string): The key name on the maps base list maps used to match with the override map keys.
  4. defaultFor (list): A list of keys that inherit the matching key as value, besides indexKey

Behavior:
- If an override key matches with a base map's specified index key:
  - If the override value is null, the base map is removed from the resulting list.
  - Otherwise, the base map is deep merged with the override value.
- Any non matching maps in the base list that do not have a match are kept unchanged.
- Keys on the override map that do not match on the base list maps are added as new elements at the end of the result list.
- The resulting list maintains the original order of non-removed items from the base list.

Usage:
- list $baseList $overrideMap $indexKey | include "utils.mergeMapWithList"
Example:
- Input:
  baseList: [{name: "item1", value: 1}, {name: "item2", value: 2}, {name: "item3", value: 3}]
  overrideMap: {"item1": {value: 10}, "item2": null, "item4": {name: "item4", value: 4}, "item0": {name: "item0", value: 0}}
  indexKey: "name"
- Result: [{name: "item1", value: 10}, {name: "item3", value: 3}, {name: "item0", value: 0}, {name: "item4", value: 4}]
*/}}
{{- $base := deepCopy ( index . 0) -}}
{{- $override := deepCopy ( index . 1 ) -}}
{{- $indexKey := deepCopy ( index . 2 ) -}}
{{- $defaultFor := deepCopy (index . 3 ) -}}

{{- $result := list -}}
{{- $seenKeys := dict -}}

{{/* First, process existing items in the base list */}}
{{- range $item := $base -}}
  {{- $key := index $item $indexKey -}}
  {{- $_ := set $seenKeys $key true -}}
  {{- if hasKey $override $key -}}
    {{- if eq (index $override $key) nil -}}
      {{/* Skip this item if the override is null */}}
    {{- else if empty (index $override $key) -}}
      {{- $result = append $result $item }}
    {{- else }}
      {{- $newItem := mergeOverwrite (deepCopy $item) (index $override $key) -}}
      {{- /* Ensure the new item has the defaultFor keys set */ -}}
      {{- range $defaultKey := $defaultFor -}}
      {{- if not (hasKey $newItem $defaultKey) }}
      {{- $_ := set $newItem $defaultKey $key }}
      {{- end }}
      {{- end }}
      {{- $result = append $result $newItem -}}
    {{- end -}}
  {{- else -}}
    {{- $result = append $result $item -}}
  {{- end -}}
{{- end -}}

{{/* Then, add new items from the override map */}}
{{- range $key, $value := $override -}}
  {{- if not (hasKey $seenKeys $key) -}}
    {{- if and (ne $value nil) (not (empty $value)) -}}
      {{- /* Ensure the new item has the indexKey and defaultFor set */ -}}
      {{- range $defaultKey := $defaultFor -}}
      {{- if not (hasKey $value $defaultKey) }}
      {{- $_ := set $value $defaultKey $key }}
      {{- end }}
      {{- $_ := set $value $indexKey $key -}}
      {{- end }}
      {{- $result = append $result $value -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- $result | toYaml -}}
{{- end -}}
