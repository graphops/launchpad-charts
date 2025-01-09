{{- define "common.utils.deepMerge" -}}
{{/*
deepMerge: Recursively merges multiple maps with null-key cleanup

Arguments:
- First argument ($): Global context where results will be stored
- Remaining arguments: Maps to merge

Purpose:
- Performs a recursive (deep) merge of two or more maps
- Processes maps from left to right, with right-most values taking precedence
- Removes any keys whose values are explicitly set to null in overriding maps
- Preserves empty maps and slices from higher-precedence maps
- Stores result in $.__common.fcallResult (where $ is the global context)

Behavior:
1. Single map: Returns the map after null cleanup
2. Two maps: Performs deep merge with null cleanup
3. Multiple maps: Recursively merges from left to right

Usage:
  {{ list $ $map1 $map2 ... | include "common.utils.deepMerge" }}
  Result will be in $.__common.fcallResult }}

Example:
  Input:
    $: <global context>
    map1: {a: 1, b: {x: 1, y: 2}}
    map2: {b: {x: null, z: 3}}
    
  Call:
    {{ list $ map1 map2 | include "common.utils.deepMerge" }}
    
  Result (in $.__common.fcallResult):
    {a: 1, b: {y: 2, z: 3}}

Note: This function modifies the global context by storing its result in 
      $.__common.fcallResult. Always access the result from there after calling.
*/}}
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
{{/*
removeNulls: Recursively removes null values from maps and slices
Purpose:
- Traverses data structures (maps and slices) removing null values
- Preserves empty maps and non-null values
- Stores result in $.__common.fcallResult.result

Arguments:
- First argument ($): Global context where results will be stored
- Second argument: Value to process (map, slice, or primitive)

Returns: (in $.__common.fcallResult)
  {result: <processed_value>}

Example:
  Input: {a: null, b: {x: null, y: 1}, c: [null, 1, {z: null}]}
  Result: {result: {b: {y: 1}, c: [1, {}]}}
*/}}
{{- $ := index . 0 }}
{{- $value := index . 1 -}}
{{- $result := dict -}}

{{/* Handle map type */}}
{{- if kindIs "map" $value -}}
    {{- $newMap := dict -}}
    {{- range $k, $v := $value -}}
      {{- if not (eq $v nil) -}}
        {{/* Recursively process non-null values */}}
        {{- $_ := (list $ $v) | include "common.utils.removeNulls" -}}
        {{- $nestedResult := $.__common.fcallResult -}}
        {{- if $nestedResult -}}
          {{- if kindIs "map" $nestedResult -}}
            {{/* Handle nested map results */}}
            {{- if hasKey $nestedResult "result" -}}
              {{- $newMap = set $newMap $k (get $nestedResult "result") -}}
            {{- else -}}
              {{/* Preserve empty maps */}}
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

{{/* Handle slice type */}}
{{- else if kindIs "slice" $value -}}
    {{- $newSlice := list -}}
    {{- range $v := $value -}}
      {{- if not (eq $v nil) -}}
        {{/* Recursively process non-null values */}}
        {{- $_ := (list $ $v) | include "common.utils.removeNulls" -}}
        {{- $nestedResult := $.__common.fcallResult -}}
        {{- if $nestedResult -}}
          {{- if kindIs "map" $nestedResult -}}
            {{/* Handle nested map results */}}
            {{- if hasKey $nestedResult "result" -}}
              {{- $newSlice = append $newSlice (get $nestedResult "result") -}}
            {{- else -}}
              {{/* Preserve empty maps */}}
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

{{/* Handle primitive types */}}
{{- else -}}
    {{- if not (eq $value nil) -}}
      {{- $result = set $result "result" $value -}}
    {{- end -}}
{{- end -}}
{{- $_ := set $.__common "fcallResult" $result -}}
{{- end -}}

{{- define "common.utils.templateCollection" -}}
{{/*
templateCollection: Recursively processes templates in collections
Purpose:
- Templates all string elements within maps and lists
- Preserves non-string values unchanged
- Processes nested structures recursively
- Stores result in $.__common.fcallResult

Arguments:
- First argument ($): Global context where results will be stored
- Second argument: Collection to process
- Third argument: Template context to use
- Fourth argument: Component name (for debugging)

Example:
  Input: 
    collection: {key: "{{ .Values.something }}", nested: {value: "static"}}
    templateCtx: {Values: {something: "processed"}}
  Result: {key: "processed", nested: {value: "static"}}
*/}}

{{- $ = index . 0 }}
{{- $collection := index . 1 }}
{{- if not (empty $collection) }}
  {{- $collection = deepCopy $collection -}}
{{- end }}
{{- $templateCtx := index . 2 -}}
{{- $componentName := index . 3 -}}

{{/* Process based on type */}}
{{- if kindIs "string" $collection -}}
  {{/* Only process strings containing template syntax */}}
  {{- if regexMatch ".*\\{\\{.*" $collection -}}
    {{- $_ := (list $ $collection $templateCtx $componentName) | include "common.utils.evaluateTemplate" }}
  {{- else -}}
    {{- $_ := set $.__common "fcallResult" (dict "result" $collection) -}}
  {{- end }}

{{/* Process maps recursively */}}
{{- else if kindIs "map" $collection -}}
  {{- $result := dict -}}
  {{- range $key, $value := $collection -}}
    {{- $_ := (list $ $value $templateCtx $componentName) | include "common.utils.templateCollection" -}}
    {{- $processedValue := $.__common.fcallResult.result -}}
    {{- $result = set $result $key $processedValue -}}
  {{- end -}}
  {{- $_ := set $.__common "fcallResult" (dict "result" $result) -}}

{{/* Process slices recursively */}}
{{- else if kindIs "slice" $collection -}}
  {{- $result := list -}}
  {{- range $value := $collection -}}
    {{- $_ := (list $ $value $templateCtx $componentName) | include "common.utils.templateCollection" -}}
    {{- $processedValue := $.__common.fcallResult.result -}}
    {{- $result = append $result $processedValue -}}
  {{- end -}}
  {{- $_ := set $.__common "fcallResult" (dict "result" $result) -}}

{{/* Pass through other types unchanged */}}
{{- else -}}
  {{- $_ := set $.__common "fcallResult" (dict "result" $collection) -}}
{{- end -}}
{{- end -}}

{{- define "common.resources.mergeValues" -}}
{{/*
mergeValues: Merges component values based on layering configuration
Purpose:
- Processes each component's values through configured layers
- Applies deep merge strategy for each layer
- Stores results in templateCtx.ComponentValues

Arguments:
- Global context with:
  - Values: Source values
  - __common.config.components: List of components to process
  - __common.config.componentLayering: Map of component to layer keys
  - __common.templateCtx: Context for storing results

Example:
  Config:
    components: ["app", "db"]
    componentLayering:
      app: ["common", "base"]
  Values:
    common: {replicas: 1}
    base: {image: "nginx"}
    app: {port: 80}
  Result in templateCtx.ComponentValues:
    app: {replicas: 1, image: "nginx", port: 80}
*/}}
{{- $templateCtx := $.__common.templateCtx }}

{{- $mergedValues := dict }}
{{- range $component := $.__common.config.components }}
    {{/* Build merge list starting with global context */}}
    {{- $mergeList := list $ }}
    
    {{/* Add each layer's values */}}
    {{- range $key := index $.__common.config.componentLayering (printf "%v" $component) }}
        {{- $_ := (list $ $.Values (list $key)) | include "common.utils.getNestedValue" }}
        {{- if hasKey $.Values $key }}
            {{- $mergeList = append $mergeList (index $.Values $key) }}
        {{- end }}
    {{- end }}
    
    {{/* Add component-specific values last (highest precedence) */}}
    {{- $mergeList = append $mergeList (index $.Values (printf "%v" $component)) }}
    
    {{/* Perform the merge */}}
    {{- $_ := $mergeList | include "common.utils.deepMerge" }}
    {{- $mergedValues = $.__common.fcallResult }}
    {{- $_ := set $templateCtx.ComponentValues (printf "%v" $component) $mergedValues }}
{{- end }}

{{/* Debug output if enabled */}}
{{- if $.Values.debug -}}
    {{- include "common.debug.function" (dict
        "name" "resources.mergeValues"
        "args" list
        "result" $templateCtx)
    -}}
{{- end -}}

{{- $_ := set $.__common.config "templateCtx" $templateCtx }}
{{- end -}}

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
{{/*
transformMapToList: Converts map structures to lists at specified paths
Purpose:
- Transforms map structures into lists at specified paths
- Supports adding index keys from map keys
- Handles default values for transformed items
- Preserves map keys as specified index fields

Arguments:
- First argument ($): Global context
- Second argument ($base): Base object to transform
- Third argument ($paths): List of path objects with:
  - path: Dot-notation path to transform
  - indexKey: Key to store original map key (optional)
  - defaultFor: List of keys to default to map key (optional)

Example:
  Input:
    base:
      spec:
        containers:
          main: {image: "nginx"}
          sidecar: {image: "proxy"}
    paths:
      - path: "spec.containers"
        indexKey: "name"
        defaultFor: ["id"]
  
  Result:
    spec:
      containers:
        - name: "main"
          id: "main"
          image: "nginx"
        - name: "sidecar"
          id: "sidecar"
          image: "proxy"
*/}}
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
{{/*
pruneOutput: Cleans up object structure by removing special fields and disabled sections
Purpose:
- Removes fields prefixed with "__" (internal use)
- Removes entire objects where __enabled=false
- Removes null values
- Processes nested maps and slices recursively

Arguments:
- First argument ($): Global context
- Second argument ($obj): Object to process

Returns: (in $.__common.fcallResult)
- Cleaned object or nil if disabled

Example:
  Input:
    obj:
      __enabled: true
      __internal: "hidden"
      visible: "shown"
      section:
        __enabled: false
        data: "hidden"
      nested:
        deep: null
        valid: "kept"
  
  Result:
    {
      visible: "shown",
      nested: {
        valid: "kept"
      }
    }
*/}}
{{- $ := index . 0 }}
{{- $obj := index . 1 }}

{{/* Handle map type */}}
{{- if kindIs "map" $obj -}}
    {{/* Check if object is explicitly disabled */}}
    {{- if hasKey $obj "__enabled" -}}
        {{- if not $obj.__enabled -}}
            {{- $_ := set $.__common "fcallResult" nil -}}
        {{- else -}}
            {{/* Process enabled object */}}
            {{- $result := dict -}}
            {{- range $k, $v := $obj -}}
                {{/* Skip internal fields */}}
                {{- if not (hasPrefix "__" $k) -}}
                    {{- if or (kindIs "map" $v) (kindIs "slice" $v) -}}
                        {{/* Recursively process nested structures */}}
                        {{- $_ := (list $ $v) | include "common.utils.pruneOutput" -}}
                        {{- $processed := $.__common.fcallResult -}}
                        {{- if or (not (eq $processed nil)) (kindIs "map" $v) (kindIs "slice" $v) -}}
                            {{- $_ := set $result $k $processed -}}
                        {{- end -}}
                    {{- else -}}
                        {{/* Keep non-null values */}}
                        {{- if not (eq $v nil) -}}
                            {{- $_ := set $result $k $v -}}
                        {{- end -}}
                    {{- end -}}
                {{- end -}}
            {{- end -}}
            {{- $_ := set $.__common "fcallResult" $result -}}
        {{- end -}}
    {{- else -}}
        {{/* Process object without explicit enabled flag */}}
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

{{/* Handle slice type */}}
{{- else if kindIs "slice" $obj -}}
    {{- $result := list -}}
    {{- range $v := $obj -}}
        {{- if or (kindIs "map" $v) (kindIs "slice" $v) -}}
            {{- $_ := (list $ $v) | include "common.utils.pruneOutput" -}}
            {{- $processed := $.__common.fcallResult -}}
            {{- if $processed -}}
                {{- $result = append $result $processed -}}
            {{- end -}}
        {{- else -}}
            {{- if not (eq $v nil) -}}
                {{- $result = append $result $v -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
    {{- $_ := set $.__common "fcallResult" $result -}}

{{/* Handle primitive types */}}
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
    {{- else }}
      {{- $result = append $result (printf "%s%s%s%s" $prefix $key $separator ($value | toYaml)) -}}
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
      {{- $result = append $result (printf "%s%s%s%s" $prefix $key $separator ($value | toYaml)) -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- $result | toYaml -}}
{{- end -}}

{{- define "common.utils.getNestedValue" -}}
{{/*
getNestedValue: Safely retrieves nested values from a map using a path list
Purpose:
- Traverses nested maps using a list of keys
- Performs nil checks at each level
- Returns error state if path is invalid

Arguments:
- First argument ($): Global context
- Second argument ($root): Root object to traverse
- Third argument ($pathList): List of keys forming the path

Returns: (in $.__common.fcallResult)
  {
    value: <found value or empty string>,
    error: <boolean indicating success>
  }

Example:
  Input:
    root:
      level1:
        level2: "value"
    pathList: ["level1", "level2"]
  
  Result:
    {
      value: "value",
      error: false
    }

Error Handling:
- Returns error=true if any key in path doesn't exist
- Fails with error message showing missing key and full path
*/}}
{{- $ := index . 0 }}
{{- $root := index . 1 -}}
{{- $pathList := index . 2 -}}

{{- $value := $root -}}
{{- $valid := true -}}

{{/* Traverse path */}}
{{- range $key := $pathList -}}
    {{- if and $valid (kindIs "map" $value) (hasKey $value $key) -}}
        {{- $value = index $value $key -}}
    {{- else -}}
        {{- $valid = false -}}
        {{- fail (printf "Missing key %s on %v\n values: %s" $key $pathList ($root | toYaml)) }}
    {{- end -}}
{{- end -}}

{{/* Set result */}}
{{- if not $valid -}}
    {{- $_ := set $.__common "fcallResult" (dict "value" "" "error" true) -}}
{{- else -}}
    {{- $_ := set $.__common "fcallResult" (dict "value" $value "error" false) -}}
{{- end -}}
{{- end -}}


{{- define "common.utils.preprocessTemplate" -}}
{{/*
preprocessTemplate: Processes template directives and resolves dependencies
Purpose:
- Extracts and processes @type and @needs directives
- Resolves template dependencies with caching
- Builds template context with resolved variables

Arguments:
- First argument ($): Global context
- Second argument ($template): Template string with directives
- Third argument ($templateCtx): Template context
- Fourth argument ($componentName): Current component name

Directives:
- @type(type): Specifies the output type (e.g., "int", "bool")
- @needs(path as varName): Declares dependency and assigns to variable

Example:
  Input:
    template: |
      @type(int)
      @needs(Values.replicas as count)
      {{ $count }}
    templateCtx:
      Values:
        replicas: 3

  Result: {
    type: "int",
    template: "{{- $count := index .__deps \"count\" -}}\n{{ $count }}",
    depsContext: {count: 3}
  }

Cache:
- Uses $.__common.cache to store resolved dependencies
- Cache keys are normalized paths (ComponentValues.component.path)
*/}}
{{- $ := index . 0 }}
{{- $template := index . 1 }}
{{- $templateCtx := index . 2 }}
{{- $componentName := index . 3 }}

{{/* Extract @ declarations */}}
{{- $pattern := `@(type|requires|uses|if|ifnot)\(.*?\)` -}}

{{- $result := dict "type" nil "template" $template }}
{{- $directives := list }}
{{- $hasConditional := false }}

{{/* Process directives */}}
{{- range $match := regexFindAll $pattern $template -1 -}}
  {{- $directive := trimAll "@()" (regexFind `@(type|requires|uses|if|ifnot)` $match) }}
  {{- $directiveArgs := trimAll "()" (regexFind `\(.*?\)` $match) }}

  {{/* Handle type directive */}}
  {{- if eq $directive "type" }}
    {{- $_ := set $result "type" $directiveArgs }}
  {{- else if or (eq $directive "if") (eq $directive "ifnot") }}
    {{- if $hasConditional }}
      {{- fail "Only one @if or @ifnot directive is allowed per template" }}
    {{- end }}
    {{- $hasConditional = true }}
  {{- end }}
    {{- $parts := splitList "," $directiveArgs -}}
    {{- $path := index $parts 0 -}}
    {{- $directiveInfo := dict "key" $path "componentName" $componentName "evalResult" nil "directive" $directive "default" nil -}}
    {{- range $part := slice $parts 1 }}
      {{- if hasPrefix "default=" $part }}
        {{- $_ := set $directiveInfo "default" (trimPrefix "default=" $part) }}
      {{- else if hasPrefix "error=" $part }}
        {{- $_ := set $directiveInfo "errorMsg" (trimPrefix "error=" $part) }}
      {{- end }}
    {{- end }}
    {{- $directives = append $directives $directiveInfo }}
  {{- else if or (eq $directive "requires") (eq $directive "uses") }}
    {{- $parts := splitList "," $directiveArgs -}}
    {{- $pathParts := splitList " as " (index $parts 0) -}}
    {{- $path := index $pathParts 0 -}}
    {{- $varName := index $pathParts 1 -}}
    {{/* .ComponentValues.<component> paths need to be evaluated with .Self as <component>  */}}
    {{- $evalComponentName := $componentName }}
    {{- if hasPrefix "ComponentValues." (trimPrefix "." $path) }}
      {{- $evalComponentName = regexFind "ComponentValues[.]([^.]+)" $path | trimPrefix "ComponentValues." }}
    {{- end }}
    {{- $directiveInfo := dict "key" $path "var" $varName "componentName" $evalComponentName "evalResult" nil "directive" $directive -}}
    {{- if eq $directive "requires" }}
      {{- range $part := slice $parts 1 }}
        {{- if hasPrefix "msg=" $part }}
          {{- $_ := set $directiveInfo "errorMsg" (trimPrefix "msg=" $part) }}
        {{- end }}
      {{- end }}
    {{- else }}
      {{- range $part := slice $parts 1 }}
        {{- if hasPrefix "default=" $part }}
          {{- $_ := set $directiveInfo "default" (trimPrefix "default=" $part) }}
        {{- end }}
      {{- end }}
    {{- end }}
    {{- $directives = append $directives $directiveInfo }}
  {{- end }}
{{- end -}}

{{/* Resolve directives */}}
{{- range $dir := $directives }}
  {{/* Split path and normalize for caching */}}
  {{- $_ := (list $ $dir.key) | include "common.utils.splitPath" }}
  {{- $listPath := $.__common.fcallResult }}
  {{/* Replace Self with a normalized path, to use the listPath as a cache key */}}
  {{- $cacheKeyList := $listPath }}
  {{- if eq (index $listPath 0) "Self" }}
  {{- $cacheKeyList = concat (list "ComponentValues" $componentName) (slice $cacheKeyList 1) }}
  {{- end }}
  {{- $cacheKey := join "@" $cacheKeyList }}
  {{/* if value is already cached, use that */}}
  {{- if hasKey $.__common.cache $cacheKey }}
    {{- $_ := set $dir "evalResult" (index $.__common.cache $cacheKey) }}
    {{- $_ := set $dir "evalFailed" false }}
  {{- else }}
    {{/* Resolve and cache new value */}}
    {{- (list $ $templateCtx $listPath) | include "common.utils.getNestedValue" }}
    {{- if not $.__common.fcallResult.error }}
      {{- $value := $.__common.fcallResult.value }}
      {{/* Process nested templates */}}
      {{- $evalTemplateCtx := deepCopy $templateCtx }}
      {{- $_ := set $evalTemplateCtx "Self" (index $evalTemplateCtx.ComponentValues (printf "%s" $dir.componentName)) }}
      {{- (list $ $value $evalTemplateCtx $componentName) | include "common.utils.templateCollection" }}
      {{- $_ := set $dir "evalResult" $.__common.fcallResult.result }}
      {{- $_ := set $dir "evalFailed" false }}
      {{/* Save resolved value in cache */}}
      {{- $_ := set $.__common.cache $cacheKey $dir.evalResult }}
    {{- end }}
  {{- end }}
  {{/* Now process the directives, starting with the ones that determine output bypassing template */}} 
  {{- $resolved := false }}
  {{/* For if/ifnot directives, validate boolean and check failing conditions */}}
  {{- if or (eq $dir.directive "if") (eq $dir.directive "ifnot") }}
    {{- if $dir.evalFailed }}
      {{- if (eq $dir.default nil) }}
        {{- fail (printf "Path %s not defined and no default provided, got %v" $dir.key $dir.evalResult) }}
      {{- else }}
        {{- if eq $dir.default "true" }}
          {{- $_ := set $dir "evalResult" true }}
        {{- else if eq $dir.default "false" }}
          {{- $_ := set $dir "evalResult" false }}
        {{- else }}
          {{- fail (printf "Default value for %s must be 'true' or 'false', got %v" $dir.key $dir.default) }}
        {{- end }}
      {{- end }}
    {{- else if not (kindIs "bool" $dir.evalResult) }}
      {{- fail (printf "Path %s must evaluate to a boolean, got %v" $dir.key $dir.evalResult) }}
    {{- end }}
    {{- if eq $dir.directive "if" }}
      {{- if not $dir.evalResult }}
        {{- $_ := set $result "template" "{{ nil }}" }}
        {{- $resolved = true }}
      {{- end }}
    {{- else }}
      {{- if $dir.evalResult }}
        {{- $_ := set $result "template" "{{ nil }}" }}
        {{- $resolved = true }}
      {{- end }}
    {{- end }}
  {{- end }}
  {{- if $resolved }}
    {{/* Set result */}}
    {{- $_ := set $result "template" $dir.template }}
    {{- $_ := set $result "depsContext" dict }}
    {{- $_ := set $.__common "fcallResult" $result }}
  {{- else }}
  {{/* Handle the remaining directives */}}
    {{- if eq $dir.directive "requires" }}
      {{- if $dir.evalFailed }}
        {{- $errorMsg := "" }}
        {{- if hasKey $dir "errorMsg" }}
          {{- $errorMsg = printf ": %s" $dir.errorMsg }}
        {{- end }}
        {{- fail (printf "Failed to evaluate %s on %s, getting paths %v%s" $dir.var $dir.key $listPath $errorMsg) }}
      {{- end }}
    {{- else if eq $dir.directive "uses" }}
      {{- if $dir.evalFailed }}
        {{- if hasKey $dir "default" }}
          {{- $_ := set $dir "evalResult" ($dir.default | fromJson) }}
          {{- $_ := set $dir "evalFailed" false }}
        {{- else }}
          {{- $_ := set $dir "evalResult" nil }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}

{{/* Build final template */}}
{{- $resolvedVars := dict }}
{{- $templateHeader := "" }}
{{- range $dir := $directives }}
  {{- if and (not $dir.evalFailed) (regexMatch "^(requires|uses)$" $dir.directive) }}
    {{- $header := (printf "{{- $%s := index .__deps \"%s\" -}}" $dir.var $dir.var) }}
    {{- if or (eq $dir.var nil) (eq $dir.var "null") }}
      {{- fail "var is nil" }}
    {{- end }}
    {{- if not (empty $templateHeader) }}
      {{- $templateHeader = printf "%s\n%s" $templateHeader $header}}
    {{- else }}
      {{- $templateHeader = $header }}
    {{- end }}
    {{ $_ := set $resolvedVars $dir.var $dir.evalResult }}
  {{- end }}
{{- end }}

{{- $cleanTemplate := regexReplaceAll `[\n\s]*@(type|requires|uses|if|ifnot)\(.*?\)[\s\n]*` $template "" }}
{{- $finalTemplate := printf "%s\n%s" $templateHeader $cleanTemplate }}

{{/* Set result */}}
{{- $_ := set $result "template" $finalTemplate }}
{{- $_ := set $result "depsContext" $resolvedVars }}

{{- $_ := set $.__common "fcallResult" $result }}
{{- end -}}


{{- define "common.utils.evaluateTemplate" -}}
{{/*
evaluateTemplate: Processes and evaluates templates with directives
Purpose:
- Handles template preprocessing (@type, @needs)
- Evaluates processed template with context
- Formats output based on type directive

Arguments:
- First argument ($): Global context
- Second argument ($template): Template string
- Third argument ($templateCtx): Template context
- Fourth argument ($componentName): Current component name

Returns: (in $.__common.fcallResult)
  {result: <evaluated_template>} or
  <typed_value> if @type directive present

Example:
  Input:
    template: |
      @type(int)
      @needs(Values.count as n)
      {{ mul $n 2 }}
    templateCtx:
      Values:
        count: 21
  
  Result: 42 (as integer)
*/}}
{{- $ = index . 0 }}
{{- $template := index . 1 }}
{{- $templateCtx := deepCopy (index . 2) -}}
{{- $componentName := index . 3 -}}
{{- $type := "" }}

{{/* Preprocess if directives present */}}
{{- if (regexMatch `@(requires|uses|type|if|ifnot)\(.*?\)` $template )}}
{{- (list $ $template $templateCtx $componentName) | include "common.utils.preprocessTemplate" -}}
{{- $template = $.__common.fcallResult.template }}
{{- $templateCtx = mergeOverwrite $templateCtx (dict "__deps" $.__common.fcallResult.depsContext) }}
{{- $type = default "" $.__common.fcallResult.type }}
{{- end }}

{{/* Set Self context and evaluate */}}
{{- $_ := set $templateCtx "Self" (index $templateCtx.ComponentValues $componentName) }}
{{- $templatedVal := (tpl $template $templateCtx) }}

{{/* Format result based on type */}}
{{- if not (empty $type) }}
  {{- $_ := set $.__common "fcallResult" (printf "result: !!%s %s" $type $templatedVal | fromYaml) }}
{{- else if contains "\n" (trim $templatedVal) }}
  {{- $_ := set $.__common "fcallResult" (dict "result" $templatedVal) }}
{{- else }}
  {{- $_ := set $.__common "fcallResult" (printf "result: %s" $templatedVal | fromYaml) }}
{{- end }}
{{- end }}

{{- define "common.utils.splitPath" -}}
{{/*
splitPath: Splits a dot notation path into a list of segments
Purpose:
- Converts dot notation paths into list of segments
- Handles both dot notation and bracket notation
- Preserves dots within bracketed segments

Arguments:
- First argument ($): Global context
- Second argument ($path): Path string to split

Returns: (in $.__common.fcallResult)
  List of path segments

Example:
  Input paths:
    "foo.bar"           -> ["foo", "bar"]
    "foo[bar.baz]"      -> ["foo", "bar.baz"]
    "foo.bar[x.y.z].q"  -> ["foo", "bar", "x.y.z", "q"]

Note:
- Brackets are used to preserve dots in segment names
- Leading dots are trimmed
*/}}
{{- $ := index . 0 }}
{{- $path := index . 1 }}
{{- $path = trimPrefix "." $path -}}

{{/* Split path using regex pattern */}}
{{- $matches := regexFindAll `\[([^\]]+)\]|([^.\[\]]+)` $path -1 -}}
{{- $result := list -}}

{{/* Process matches into segments */}}
{{- range $match := $matches -}}
    {{- $key := regexReplaceAll `^\[(.+)\]$` $match "$1" -}}
    {{- $result = append $result $key -}}
{{- end -}}

{{- $_ := set $.__common "fcallResult" $result -}}
{{- end -}}

{{- define "common.utils.joinPath" -}}
{{/*
joinPath: Joins path segments into a dot notation path
Purpose:
- Combines list of segments into a single path string
- Automatically handles bracketing for segments containing dots
- Creates valid dot notation paths

Arguments:
- First argument ($): Global context
- Second argument ($listKeys): List of path segments

Returns: (in $.__common.fcallResult)
  Combined path string

Example:
  Input segments:
    ["foo", "bar"]        -> "foo.bar"
    ["foo", "bar.baz"]    -> "foo[bar.baz]"
    ["a", "b.c.d", "e"]   -> "a[b.c.d].e"

Note:
- Segments containing dots are automatically bracketed
- Empty input results in empty string
*/}}
{{- $ := index . 0 }}
{{- $listKeys := index . 1 }}
{{- $result := "" -}}

{{/* Process each segment */}}
{{- range $key := $listKeys -}}
    {{- if contains "." $key -}}
        {{/* Bracket segments containing dots */}}
        {{- $result = printf "%s[%s]" $result $key -}}
    {{- else -}}
        {{- if empty $result -}}
            {{/* First segment */}}
            {{- $result = $key -}}
        {{- else -}}
            {{/* Add dot separator for normal segments */}}
            {{- $result = printf "%s.%s" $result $key -}}
        {{- end -}}
    {{- end -}}
{{- end -}}

{{- $_ := set $.__common "fcallResult" $result -}}
{{- end -}}
