{{- define "utils.getImage" -}}
{{/*
utils.getImage: Constructs a full Docker image reference.
Uses digest if provided, otherwise uses tag. Requires repository.
*/}}
{{- if .repository -}}
  {{- $imageParts := list .repository -}}
  {{- if .digest -}}
    {{- $imageParts = append $imageParts (printf "@%s" .digest) -}}
  {{- else if .tag -}}
    {{- $imageParts = append $imageParts (printf ":%s" .tag) -}}
  {{- end -}}
  {{- join "" $imageParts -}}
{{- end -}}
{{- end -}}


{{- define "utils.templateCollection" -}}
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
    {{- $templatedCollection | fromYaml }}
    while for an array, fromYamlArray
    {{- $templatedCollection | fromYaml }}
*/}}

{{- $collection := index . 0 }}
{{- if not (empty $collection) }}
{{- $collection = deepCopy $collection -}}
{{- end }}
{{- $templateCtx := deepCopy ( index . 1 ) -}}

{{/* Process the collection */}}
{{- if kindIs "string" $collection -}}
  {{/* this is to allow to preserve types other than strings */}}
  {{- if contains "\n" $collection }}
    {{- dict "result" ( tpl $collection $templateCtx ) | toYaml }}
  {{/* to preserve empty strings, relevant for apiGroups in Roles */}}
  {{- else if empty $collection }}
    {{- printf "%s: %s" "result" "\"\"" }}
  {{- else }}
    {{- $tempStr := printf "%s: %v" "result" ( $collection ) }}
    {{ tpl $tempStr $templateCtx }}
  {{- end }}
{{- else if kindIs "map" $collection -}}
  {{- $result := dict -}}
  {{- range $key, $value := $collection -}}
    {{- $processedValue := list $value $templateCtx | include "utils.templateCollection" | fromYaml -}}
    {{- $result = set $result $key $processedValue.result -}}
  {{- end -}}
  {{- include "utils.removeNulls" $result -}}
{{- else if kindIs "slice" $collection -}}
  {{- $result := list -}}
  {{- range $value := $collection -}}
    {{- $processedValue := list $value $templateCtx | include "utils.templateCollection" | fromYaml -}}
    {{- $result = append $result $processedValue.result -}}
  {{- end -}}
  {{- include "utils.removeNulls" $result -}}
{{- else -}}
  {{- dict "result" $collection | toYaml -}}
{{- end -}}

{{- end -}}



{{- define "utils.generateArgsList" -}}
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
- templateCtx: Context for template evaluation. Only run if non-empty (optional, default: {})
Usage example:
  {{- $args := dict ".__prefix" "--" ".__separator" "=" "map" (dict "foo" "bar" "flag" "__none" "num" 42) "orderList" (list "flag" "foo") -}}
  {{- $result := include "utils.generateArgsList" $args | fromJson -}}
  Result: ["--flag", "--foo=bar", "--num=42"]
*/}}
{{- $map := deepCopy .map -}}
{{- $orderList := deepCopy ( .orderList | default list ) -}}
{{- $prefix := deepCopy ( $map.__prefix | default "" ) -}}
{{- $separator := deepCopy ( $map.__separator | default " " ) -}}
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

{{/* Template each item in the result if templateCtx is not empty */}}
{{- if not (empty $templateCtx) -}}
    {{- $result = get (list $result $templateCtx | include "utils.templateCollection" | fromYaml) "result" }}
{{- end -}}

{{- $result | toYaml -}}
{{- end -}}

{{- define "utils.deepMerge" -}}
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
  {{- dict | toYaml -}}
{{- else if eq $length 1 -}}
  {{- get ( include "utils.removeNulls" ( index . 0 ) | fromYaml ) "result" | toYaml -}}
{{- else -}}
  {{- $last := index . (sub $length 1) -}}
  {{- $initial := slice . 0 (sub $length 1) | include "utils.deepMerge" | fromYaml -}}

{{/* Merge two maps excluding keys set to null */}}
  {{- $merged := dict -}}

  {{- range $key, $baseValue := $initial -}}
    {{- if ne $baseValue nil }}
      {{- if hasKey $last $key -}}
        {{- $overrideValue := index $last $key -}}
        {{- if and (kindIs "map" $baseValue) (kindIs "map" $overrideValue) -}}
          {{- $nestedMerge := list $baseValue $overrideValue | include "utils.deepMerge" | fromYaml -}}
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

  {{- $merged | toYaml -}}
{{- end -}}
{{- end -}}


{{- define "utils.removeNulls" -}}
  {{- $value := . -}}
  {{- $result := dict -}}
  {{- if kindIs "map" $value -}}
    {{- $newMap := dict -}}
    {{- range $k, $v := $value -}}
      {{- if not (eq $v nil) -}}
        {{- $nestedResult := include "utils.removeNulls" $v | fromYaml -}}
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
        {{- $nestedResult := include "utils.removeNulls" $v | fromYaml -}}
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
  {{- $result | toYaml -}}
{{- end -}}


{{- define "utils.mergeMapWithList" -}}
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
    {{- else -}}
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
    {{- if ne $value nil -}}
      {{- /* Ensure the new item has the indexKey and defaultFor set */ -}}
      {{- range $defaultKey := $defaultFor -}}
      {{- if not (hasKey $value $defaultKey) }}
      {{- $_ := set $value $defaultKey $key }}
      {{- end }}
      {{- end }}
      {{- $_ := set $value $indexKey $key -}}
      {{- $result = append $result $value -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- $result | toYaml -}}
{{- end -}}


{{- define "utils.smartMerge" -}}
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
{{- $merged := list $base $override | include "utils.deepMerge" | fromYaml -}}

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
        {{- $newMergedValue := list $baseValue $overrideValue $indexKey $defaultFor | include "utils.mergeMapWithList" | fromYamlArray -}}

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
