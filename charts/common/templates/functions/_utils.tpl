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
{{- $ := index . 0 }}
{{- $args := slice . 1 (len .) }}
{{- $length := len $args -}}
{{- if eq $length 0 -}}
  {{- $_ := set $.__common "fcallResult" dict -}}
{{- else if eq $length 1 -}}
  {{- $_ := (list $ (index $args 0)) | include "common.utils.removeNulls" }}
  {{- $cleanResult := $.__common.fcallResult.result }}
  {{- $_ := set $.__common "fcallResult" $cleanResult }}
{{- else -}}
  {{- $last := index $args (sub $length 1) -}}
  {{- $_ := (concat (list $) (slice $args 0 (sub $length 1))) | include "common.utils.deepMerge" -}}
  {{- $initial := $.__common.fcallResult -}}

{{/* Merge two maps excluding keys set to null */}}
  {{- $merged := dict -}}

  {{- range $key, $baseValue := $initial -}}
    {{- if not (eq $baseValue nil) }}
      {{- if hasKey $last $key -}}
        {{- $overrideValue := index $last $key -}}
        {{- if and (kindIs "map" $baseValue) (kindIs "map" $overrideValue) -}}
          {{- $_ := (list $ $baseValue $overrideValue) | include "common.utils.deepMerge" -}}
          {{- $nestedMerge := $.__common.fcallResult -}}
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
    {{- if and (not (hasKey $initial $key)) (not (eq $value nil)) -}}
      {{- $_ := set $merged $key $value -}}
    {{- end -}}
  {{- end -}}

  {{- $_ := set $.__common "fcallResult" $merged -}}
{{- end -}}
{{- end -}}


{{- define "common.utils.removeNulls" -}}
  {{- $ := index . 0 }}
  {{- $value := index . 1 -}}
  {{- $result := dict -}}
  {{- if kindIs "map" $value -}}
    {{- $newMap := dict -}}
    {{- range $k, $v := $value -}}
      {{- if not (eq $v nil) -}}
        {{- $_ := (list $ $v) | include "common.utils.removeNulls" -}}
        {{- $nestedResult := $.__common.fcallResult -}}
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
        {{- $_ := (list $ $v) | include "common.utils.removeNulls" -}}
        {{- $nestedResult := $.__common.fcallResult -}}
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
  {{- $_ := set $.__common "fcallResult" $result -}}
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
*/}}

{{- $ = index . 0 }}
{{- $collection := index . 1 }}
{{- if not (empty $collection) }}
{{- $collection = deepCopy $collection -}}
{{- end }}
{{- $templateCtx := index . 2 -}}
{{- $componentName := index . 3 -}}

{{/* Process the collection */}}
{{- if kindIs "string" $collection -}}
{{- if not (regexMatch ".*\\{\\{.*" $collection) -}}
{{- $_ := set $.__common "fcallResult" (dict "result" $collection) -}}
{{- else -}}
  {{- $_ := (list $ $collection $templateCtx $componentName) | include "common.utils.evaluateTemplate" }}
{{- end }}
{{- else if kindIs "map" $collection -}}
  {{- $result := dict -}}
  {{- range $key, $value := $collection -}}
    {{- $_ := (list $ $value $templateCtx $componentName) | include "common.utils.templateCollection" -}}
    {{- $processedValue := $.__common.fcallResult.result -}}
    {{- $result = set $result $key $processedValue -}}
  {{- end -}}
  {{- $_ := set $.__common "fcallResult" (dict "result" $result) -}}
{{- else if kindIs "slice" $collection -}}
  {{- $result := list -}}
  {{- range $value := $collection -}}
    {{- $_ := (list $ $value $templateCtx $componentName) | include "common.utils.templateCollection" -}}
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
{{- $mergeList := list $ }}
{{- range $key := index $.__common.config.componentLayering (printf "%v" $component) }}
{{- $_ := (list $ $.Values (list $key)) | include "common.utils.getNestedValue" }}
{{- $mergeObj := $.__common.fcallResult }}
{{- if $mergeObj }}
{{- $mergeList = append $mergeList (index $.Values $key) }}
{{- end }}
{{- end }}
{{- $mergeList = append $mergeList (index $.Values (printf "%v" $component)) }}
{{- $_ := $mergeList | include "common.utils.deepMerge" }}
{{- $mergedValues = $.__common.fcallResult }}
{{ $_ := set $templateCtx.ComponentValues (printf "%v" $component) $mergedValues }}
{{- end }}
{{- if $.Values.debug -}}
  {{- include "common.debug.function" (dict
    "name" "resources.mergeValues"
    "args" list
    "result" $templateCtx)
  -}}
{{- end -}}

{{- $_ := set $.__common.config "templateCtx" $templateCtx }}

{{- end }}

{{- define "common.resources.templateValues" }}

{{- $templateCtx := $.__common.templateCtx }}

{{- $templatedValues := dict }}
{{- range $component, $values := $templateCtx.ComponentValues }}
{{- $_ := set $templateCtx "Self" $values }}
{{- $_ := (list $ $values $templateCtx $component) | include "common.utils.templateCollection" }}
{{- $templatedValues := $.__common.fcallResult.result }}
{{- if $.Values.debug -}}
  {{- include "common.debug.function" (dict
    "name" (printf "%s%s" "Templating component values for " $component)
    "args" (list $templateCtx)
    "result" $templatedValues)
  -}}
{{- end -}}
{{- $_ := set $templateCtx.ComponentValues (printf "%v" $component) $templatedValues }}
{{- end }}

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
{{- $ := index . 0 }}
{{- $obj := index . 1 }}
{{- if kindIs "map" $obj -}}
    {{- if hasKey $obj "__enabled" -}}
        {{- if not $obj.__enabled -}}
        {{- else -}}
            {{- $result := dict -}}
            {{- range $k, $v := $obj -}}
                {{- if not (hasPrefix "__" $k) -}}
                    {{- if or (kindIs "map" $v) (kindIs "slice" $v) -}}
                        {{- $_ := (list $ $v) | include "common.utils.pruneOutput" -}}
                        {{- $processed := $.__common.fcallResult -}}
                        {{- if or (not (eq $processed nil)) (kindIs "map" $v) (kindIs "slice" $v) -}}
                            {{- $_ := set $result $k $processed -}}
                        {{- end -}}
                    {{- else -}}
                        {{- if not (eq $v nil) -}}
                            {{- $_ := set $result $k $v -}}
                        {{- end -}}
                    {{- end -}}
                {{- end -}}
            {{- end -}}
            {{- $_ := set $.__common "fcallResult" $result -}}
        {{- end -}}
    {{- else -}}
        {{- $result := dict -}}
        {{- range $k, $v := $obj -}}
            {{- if not (hasPrefix "__" $k) -}}
                {{- if or (kindIs "map" $v) (kindIs "slice" $v) -}}
                    {{- $_ := (list $ $v) | include "common.utils.pruneOutput" -}}
                    {{- $processed := $.__common.fcallResult -}}
                    {{- if or (not (eq $processed nil)) (kindIs "map" $v) (kindIs "slice" $v) -}}
                        {{- $_ := set $result $k $processed -}}
                    {{- end -}}
                {{- else -}}
                    {{- if not (eq $v nil) -}}
                        {{- $_ := set $result $k $v -}}
                    {{- end -}}
                {{- end -}}
            {{- end -}}
        {{- end -}}
        {{- $_ := set $.__common "fcallResult" $result -}}
    {{- end -}}
{{- else if kindIs "slice" $obj -}}
    {{- $result := list -}}
    {{- range $v := $obj -}}
        {{- if or (kindIs "map" $v) (kindIs "slice" $v) -}}
            {{- $_ := (list $ $v) | include "common.utils.pruneOutput" -}}
            {{- $processed := $.__common.fcallResult -}}
            {{- if or (not (eq $processed nil)) (kindIs "map" $v) (kindIs "slice" $v) -}}
                {{- $result = append $result $processed -}}
            {{- end -}}
        {{- else -}}
            {{- if not (eq $v nil) -}}
                {{- $result = append $result $v -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
    {{- $_ := set $.__common "fcallResult" $result -}}
{{- else -}}
    {{- $_ := set $.__common "fcallResult" $obj -}}
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
  {{- $result := include "utils.generateArgsList" $args | fromYamlArray -}}
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
    {{- else if (kindIs "int" $value) -}}
      {{- $result = append $result (printf "%s%s%s%d" $prefix $key $separator $value) -}}
    {{- else }}
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
    {{- else if (kindIs "int" $value) -}}
      {{- $result = append $result (printf "%s%s%s%d" $prefix $key $separator $value) -}}
    {{- else -}}
      {{- $result = append $result (printf "%s%s%s%v" $prefix $key $separator $value) -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- $result | toJson -}}
{{- end -}}

{{- /* Helper function to get nested value with nil checks */}}
{{- define "common.utils.getNestedValue" -}}
{{- $ := index . 0 }}
{{- $root := index . 1 -}}
{{- $pathList := index . 2 -}}

{{- $value := $root -}}
{{- $valid := true -}}
{{- range $key := $pathList -}}
    {{- if and $valid (hasKey $value $key) -}}
        {{- $value = index $value $key -}}
    {{- else -}}
        {{- $valid = false -}}
    {{- end -}}
{{- end -}}
{{- if not $valid -}}
    {{- $value = "__nil" -}}
{{- end -}}
{{- $_ := set $.__common "fcallResult" $value -}}
{{- end -}}


{{- define "common.utils.preprocessTemplate" -}}
{{- $ := index . 0 }}
{{- $template := index . 1 }}
{{- $templateCtx := index . 2 }}
{{- $componentName := index . 3 }}

{{/* Extract @ declarations */}}
{{- $pattern := `@(type|needs)\(.*?\)` -}}

{{- $result := dict "type" nil "template" $template }}
{{- $dependencies := list }}

{{- range $match := regexFindAll $pattern $template -1 -}}
  {{- $directive := trimAll "@()" (regexFind `@(type|needs)` $match) }}
  {{- $directiveArgs := trimAll "()" (regexFind `\(.*?\)` $match) }}

  {{- if eq $directive "type" }}
    {{- $_ := set $result "type" $directiveArgs }}
  {{- else if eq $directive "needs" }}
    {{- $parts := splitList " as " $directiveArgs -}}
    {{- $path := index $parts 0 -}}
    {{/* .ComponentValues.<component> paths need to be evaluated with .Self as <component>  */}}
    {{- $evalComponentName := $componentName }}
    {{- if hasPrefix "ComponentValues." (trimPrefix "." $path) }}
      {{- $evalComponentName = regexFind "ComponentValues[.]([^.]+)" $path | trimPrefix "ComponentValues." }}
    {{- end }}
    {{- $varName := index $parts 1 -}}
    {{- $dependencies = append $dependencies (dict "key" $path "var" $varName "componentName" $evalComponentName "evalResult" nil) }}
  {{- end }}
{{- end -}}

{{- range $dep := $dependencies }}
  {{- $_ := (list $ $dep.key) | include "common.utils.splitPath" }}
  {{- $listPath := $.__common.fcallResult }}
  {{- (list $ $templateCtx $listPath) | include "common.utils.getNestedValue" }}
  {{- $value := $.__common.fcallResult }}
  {{- $resolvedValue := "" }}
  {{- if not (and (eq (kindOf $value) "string") (eq $value "__nil")) }}
    {{/* As $value can be a map with has at some nesting level a template value, we always evaluate */}}
    {{- $evalTemplateCtx := deepCopy $templateCtx }}
    {{- $_ := set $evalTemplateCtx "Self" (index (printf ".ComponentValues.%s" $dep.componentName)) }}
    {{- (list $ $value $evalTemplateCtx $componentName) | include "common.utils.templateCollection" }}
    {{- $resolvedValue = $.__common.fcallResult.result }}
  {{- else }}
    {{- $resolvedValue = "__nil" }}
  {{- end }}
  {{- $_ := set $dep "evalResult" $resolvedValue }}
{{- end }}

{{- $templateHeader := "" }}
{{- range $dep := $dependencies }}
  {{- $header := (printf "{{- $__serialized := %s -}}{{- $%s := index ( $__serialized | fromJson ) \"value\" -}}" ( dict "value" $dep.evalResult | toJson | quote ) $dep.var) }}
  {{- if not (empty $templateHeader) }}
    {{- $templateHeader = printf "%s\n%s" $templateHeader $header}}
  {{- else }}
    {{- $templateHeader = $header }}
  {{- end }}
{{- end }}

{{- $cleanTemplate := regexReplaceAll `[\n\s]*@(type|needs)\(.*?\)[\s\n]*` $template "" }}
{{- $finalTemplate := printf "%s\n%s" $templateHeader $cleanTemplate }}

{{- $_ := set $result "template" $finalTemplate }}

{{- $_ := set $.__common "fcallResult" $result }}
{{- end -}}


{{- define "common.utils.evaluateTemplate" -}}
{{- $ = index . 0 }}
{{- $template := index . 1 }}
{{- $templateCtx := index . 2 -}}
{{- $componentName := index . 3 -}}
{{- $type := "" }}
{{/* Process the template */}}
{{- if (regexMatch `@(needs|type)\(.*?\)` $template )}}
{{- (list $ $template $templateCtx $componentName) | include "common.utils.preprocessTemplate" -}}
{{- $template = $.__common.fcallResult.template }}
{{- $type = default "" $.__common.fcallResult.type }}
{{- end }}
{{- $_ := set $templateCtx "Self" (index $templateCtx.ComponentValues $componentName) }}
{{- $templatedVal := (tpl $template $templateCtx) }}
{{- if not (empty $type) }}
  {{- $_ := set $.__common "fcallResult" (printf "result: !!%s %s" $type $templatedVal | fromYaml) }}
{{- else if contains "\n" (trim $templatedVal) }}
  {{- $_ := set $.__common "fcallResult" (dict "result" $templatedVal) }}
{{- else }}
  {{- $_ := set $.__common "fcallResult" (printf "result: %s" $templatedVal | fromYaml) }}
{{- end }}

{{- end }}

{{- define "common.utils.splitPath" -}}
{{- $ := index . 0 }}
{{- $path := index . 1 }}
{{- $path = trimPrefix "." $path -}}
{{- $matches := regexFindAll `\[([^\]]+)\]|([^.\[\]]+)` $path -1 -}}
{{- $result := list -}}
{{- range $match := $matches -}}
    {{- $key := regexReplaceAll `^\[(.+)\]$` $match "$1" -}}
    {{- $result = append $result $key -}}
{{- end -}}
{{- $_ := set $.__common "fcallResult" $result -}}
{{- end -}}

{{- define "common.utils.joinPath" -}}
{{- $ := index . 0 }}
{{- $listKeys := index . 1 }}
{{- $result := "" -}}
{{- range $key := $listKeys -}}
    {{- if contains "." $key -}}
        {{- $result = printf "%s[%s]" $result $key -}}
    {{- else -}}
        {{- if empty $result -}}
            {{- $result = $key -}}
        {{- else -}}
            {{- $result = printf "%s.%s" $result $key -}}
        {{- end -}}
    {{- end -}}
{{- end -}}
{{- $_ := set $.__common "fcallResult" $result -}}
{{- end -}}
