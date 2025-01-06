# Firehose-Ethereum Helm Chart

Deploy and scale all components of [Firehose EVM](https://github.com/streamingfast/firehose-ethereum) inside Kubernetes with ease

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) ![Version: 0.1.0-canary.5](https://img.shields.io/badge/Version-0.1.0--canary.5-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v2.6.7](https://img.shields.io/badge/AppVersion-v2.6.7-informational?style=flat-square)

## Introduction

Firehose is a high-performance blockchain data extraction tool that captures, processes, and streams blockchain data in real-time, enabling efficient data analysis and integration for various applications.

This chart can be used to deploy the constellation of services required to operate any [Firehose EVM](https://github.com/streamingfast/firehose-ethereum) chain.

## Chart Features

- Actively maintained by [GraphOps](https://graphops.xyz) [and contributors](https://github.com/graphops/launchpad-charts/graphs/contributors)
- Extreme flexibility and customizability
- Sane defaults with solid security parameters (non-root execution, ready-only root filesystem, drops all capabilities)
- Support for `ServiceMonitor`s to configure Prometheus to scrape metrics ([prometheus-operator](https://github.com/prometheus-operator/prometheus-operator))

## Chart Structure and Customization

This chart is focused on the [firehose-ethereum](https://github.com/streamingfast/firehose-ethereum) workload and allows setting up a variable number of workload instances (Deployments / StatefulSets) running it. That is defined in the top-level key `firehoseComponents`.

### firehoseComponents

Each of the sub-keys defined here will generate a workload (either a `Deployment` or `StatefulSet`, set with the `kind` key) with a particular configuration defined under the sub-key. The specific per-component definitions will be merged on top of the `firehoseComponentDefaults` top-level key, so all components inherit a common set of default configurations.

These instances will by default run `firehose-ethereum`, which will be configured via a ConfigMap which is dynamically generated with a combination of your values, the defaults, and templating. This configuration is set under the `.fireeth.config` subkeys, and will define the configuration parameters. Additionally, the set of firehose services to be launched by `firehose-ethereum` on a particular workload can be set under `.fireeth.services`.

Example:
```yaml
firehoseComponents:
  write-path-workload:
    kind: StatefulSet
    fireeth:
      services:
        - reader-node
        - index-builder
        - merger
      config:
        reader-node-grpc-listen-addr: "0.0.0.0:10010"
        index-builder-grpc-listen-addr: "0.0.0.0:10009"
  read-path-workload:
    kind: Deployment
    fireeth:
      services:
        - relayer
        - firehose
      config:
        merger-grpc-listen-addr: ":10012"
        firehose-grpc-listen-addr: "0.0.0.0:10015"
```

Will provision a Deployment, called `read-path-workload` and a StatefulSet called `write-path-workload`, each with its own ConfigMap dynamically generated based on that list of parameters, as well as a range of other Kubernetes resources such as a Service, Service Account, serviceMonitor, etc.

### firehoseServiceDefaults

All components defined in `firehoseComponents` inherit the `firehoseComponentDefaults`, and can be set to run arbitrary firehose services. As such, there is `firehoseServiceDefaults`, a top-level key which contains service-specific defaults. These get inherited by each component as a function of the services they define in their `.fireeth.services` list.

Example:

```yaml
firehoseComponentDefaults:
  kind: Deployment
  fireeth:
    config:
      firehose-rate-limit-bucket-size: 20
      firehose-rate-limit-bucket-fill-rate: "1s"

firehoseServiceDefaults:
  reader-node:
    kind: StatefulSet
    fireeth:
      config:
        reader-node-data-dir: "/var/lib/geth"

  merger:
    fireeth:
      config:
        merger-grpc-listen-addr: ":10012"

firehoseComponents:
  myComponent:
    fireeth:
      services:
        - merger
        - reader-node
      config:
        my-particular-option: "something"
        firehose-rate-limit-bucket-fill-rate: "5s"
```

This will result in a component with a combined configuration equivalent to:
```yaml
firehoseComponents:
  myComponent:
    kind: StatefulSet
    fireeth:
      services:
        - merger
        - reader-node
      config:
        firehose-rate-limit-bucket-size: 20
        firehose-rate-limit-bucket-fill-rate: "5s"
        reader-node-data-dir: "/var/lib/geth"
        merger-grpc-listen-addr: ":10012"
        my-particular-option: "something"
```

which will result in a StatefulSet with firehose running both merger and reader-node services on the POD instances.

*Note:* The firehoseServiceDefaults of each of the configured services will be merged in the order they are defined in the list, in this case reader-node defaults would be merged on top of merger. I.e., if merger had in its `firehoseServiceDefaults` an explicit `kind: Deployment`, then as is, we would still get a `StatefulSet`, but if we exchanged their order to:
```yaml
firehoseComponents:
  myComponent:
    fireeth:
      services:
        - reader-node
        - merger
```
then the result would be `kind: Deployment`. So it's intended for most of `firehoseServiceDefaults` to be component specific and do not overlap much with each other.

### General chart interfaces

Virtually any aspect of the workload (StatefulSet or Deployment) can be overriden under the component level key, where you can set things such as `resources:`, `nodeSelector:`, `podSecurityContext:`, `env:` or `labels:`. Note that those often map to keys that are structured in different parts of the workload spec, such as `metadata.labels` or keys from the POD level or the container definition (there is a single main container defined). In general those have been flattened for convenience.

On par with settings workload spec parameters, a firehose component includes a range of different resources such as a Service, ConfigMap, ServiceMonitor, .... Those resources have a corresponding key to override or extend their parameters, or with entra configuration settingsm, as well as an `enabled` boolean to toggle their creation. Example:

```yaml
# -- ServiceMonitor configuration for Prometheus Operator
serviceMonitor:
  # -- Enable monitoring by creating `ServiceMonitor` CRDs ([prometheus-operator](https://github.com/prometheus-operator/prometheus-operator))
  enabled: true
  metadata:
    labels: {}
    annotations: {}
  spec:
    # Endpoint overrides, keyed by port name
    endpoints:
      metrics-fh:
        # Override or add any endpoint-specific fields
        interval: "30s"
        scrapeTimeout: "10s"
        path: /metrics
        honorLabels: true
        # ... any other endpoint-specific fields
    # Any other top-level ServiceMonitor spec fields

  # -- Service account configuration
serviceAccount:
  # -- Specifies whether a service account should be created
  create: true
  # -- The name of the service account to use.
  # If not set and create is true, a name is generated using the fullname template
  name: ""
  # -- Annotations to add to the service account
  annotations: {}
  # -- Labels to add to the service account
  labels: {}
  rbac:
    create: true
    rules: []
    clusterWide: false
```

## Quickstart

To install the chart with the release name `my-release`:

```console
helm repo add graphops http://graphops.github.io/launchpad-charts
helm install my-release graphops/firehose-ethereum
```

## Upgrading

We recommend that you pin the version of the Chart that you deploy. You can use the `--version` flag with `helm install` and `helm upgrade` to specify a chart version constraint.

This project uses [Semantic Versioning](https://semver.org/). Changes to the version of the application (the `appVersion`) that the Chart deploys will generally result in a patch version bump for the Chart. Breaking changes to the Chart or its `values.yaml` interface will be reflected with a major version bump.

We do not recommend that you upgrade the application by overriding `image.tag`. Instead, use the version of the Chart that is built for your desired `appVersion`.

## Values

| Key | Description | Type | Default |
|-----|-------------|------|---------|
 | firehoseComponentDefaults.affinity | Affinity configuration | object | `{}` |
 | firehoseComponentDefaults.annotations | Component level annotations (templated) | object | `{}` |
 | firehoseComponentDefaults.clusterRbac | Cluster scoped RBAC role and binding configuration Used by the P2P init-container | object | `{"bindingSpec":{"roleRef":{}},"enabled":false,"roleSpec":null}` |
 | firehoseComponentDefaults.command | Container entrypoint | list | `[]` |
 | firehoseComponentDefaults.configMap | ConfigMap customization | object | `{"enabled":true,"metadata":{"annotations":{},"labels":{}},"options":{"template":"{{- $nodeArgs := false }}\nstart:\n  args:\n    {{- range .Pod.fireeth.services }}\n    - {{ . }}\n    {{- if (contains \"node\" .) }}\n    {{- $nodeArgs = true }}\n    {{- end }}\n    {{- end }}\n  flags:\n    {{- range $key, $value := .Pod.fireeth.config }}\n    {{ $key }}: {{ $value \| quote }}\n    {{- end }}\n    {{- if $nodeArgs }}\n    {{- $readerNodeArgs := include \"utils.generateArgsList\" (dict \"map\" ( .Pod.fireeth.nodeArgs \| default dict ) \"orderList\" ( .Pod.fireeth.nodeArgsOrder \| default list ) ) \| fromYamlArray }}\n    reader-node-arguments: \|\n      {{- range $readerNodeArgs }}\n      {{ . }}\n      {{- end }}\n      {{- end }}\n","useEnvSubst":false}}` |
 | firehoseComponentDefaults.configMap.enabled | Create a ConfigMap (highly recommended) | bool | `true` |
 | firehoseComponentDefaults.configMap.metadata | Any remaiing key/values can be added and will be merged with the templated ConfigMap resource | object | `{"annotations":{},"labels":{}}` |
 | firehoseComponentDefaults.configMap.options | ConfigMap specific options | object | `{"template":"{{- $nodeArgs := false }}\nstart:\n  args:\n    {{- range .Pod.fireeth.services }}\n    - {{ . }}\n    {{- if (contains \"node\" .) }}\n    {{- $nodeArgs = true }}\n    {{- end }}\n    {{- end }}\n  flags:\n    {{- range $key, $value := .Pod.fireeth.config }}\n    {{ $key }}: {{ $value \| quote }}\n    {{- end }}\n    {{- if $nodeArgs }}\n    {{- $readerNodeArgs := include \"utils.generateArgsList\" (dict \"map\" ( .Pod.fireeth.nodeArgs \| default dict ) \"orderList\" ( .Pod.fireeth.nodeArgsOrder \| default list ) ) \| fromYamlArray }}\n    reader-node-arguments: \|\n      {{- range $readerNodeArgs }}\n      {{ . }}\n      {{- end }}\n      {{- end }}\n","useEnvSubst":false}` |
 | firehoseComponentDefaults.configMap.options.template | Default ConfigMap template for the fireeth config | string | `"{{- $nodeArgs := false }}\nstart:\n  args:\n    {{- range .Pod.fireeth.services }}\n    - {{ . }}\n    {{- if (contains \"node\" .) }}\n    {{- $nodeArgs = true }}\n    {{- end }}\n    {{- end }}\n  flags:\n    {{- range $key, $value := .Pod.fireeth.config }}\n    {{ $key }}: {{ $value \| quote }}\n    {{- end }}\n    {{- if $nodeArgs }}\n    {{- $readerNodeArgs := include \"utils.generateArgsList\" (dict \"map\" ( .Pod.fireeth.nodeArgs \| default dict ) \"orderList\" ( .Pod.fireeth.nodeArgsOrder \| default list ) ) \| fromYamlArray }}\n    reader-node-arguments: \|\n      {{- range $readerNodeArgs }}\n      {{ . }}\n      {{- end }}\n      {{- end }}\n"` |
 | firehoseComponentDefaults.configMap.options.useEnvSubst | Run an envsubst initcontainer at runtime | bool | `false` |
 | firehoseComponentDefaults.env | Environment variables | object | `{}` |
 | firehoseComponentDefaults.envFrom | Environment variables from references | object | `{"secretKeyRef":{"FIREETH_COMMON_FORKED_BLOCKS_STORE_URL":{"key":"","name":""},"FIREETH_COMMON_MERGED_BLOCKS_STORE_URL":{"key":"","name":""},"FIREETH_COMMON_ONE_BLOCK_STORE_URL":{"key":"","name":""}}}` |
 | firehoseComponentDefaults.envFrom.secretKeyRef.FIREETH_COMMON_FORKED_BLOCKS_STORE_URL.key | Name of the data key in the secret that contains your S3 bucket url for storing forked blocks | string | `""` |
 | firehoseComponentDefaults.envFrom.secretKeyRef.FIREETH_COMMON_FORKED_BLOCKS_STORE_URL.name | Name of the secret that contains your S3 bucket url for storing forked blocks | string | `""` |
 | firehoseComponentDefaults.envFrom.secretKeyRef.FIREETH_COMMON_MERGED_BLOCKS_STORE_URL.key | Name of the data key in the secret that contains your S3 bucket url for storing merged blocks | string | `""` |
 | firehoseComponentDefaults.envFrom.secretKeyRef.FIREETH_COMMON_MERGED_BLOCKS_STORE_URL.name | Name of the secret that contains your S3 bucket url for storing merged blocks | string | `""` |
 | firehoseComponentDefaults.envFrom.secretKeyRef.FIREETH_COMMON_ONE_BLOCK_STORE_URL.key | Name of the data key in the secret that contains your S3 bucket url for storing one blocks | string | `""` |
 | firehoseComponentDefaults.envFrom.secretKeyRef.FIREETH_COMMON_ONE_BLOCK_STORE_URL.name | Name of the secret that contains your S3 bucket url for storing one blocks | string | `""` |
 | firehoseComponentDefaults.extraContainers | Extra containers to add to the pod (templated) | object | `{}` |
 | firehoseComponentDefaults.fireeth | Firehose-specific configuration | object | `{"args":{"--config-file":"/config/config.yaml","__separator":"=","start":"__none"},"argsOrder":["start","--config-file"],"config":{"common-forked-blocks-store-url":null,"common-live-blocks-addr":"relayer:10014","common-merged-blocks-store-url":null,"common-one-block-store-url":null,"data-dir":"/var/lib/fireeth","firehose-rate-limit-bucket-fill-rate":"1s","firehose-rate-limit-bucket-size":20,"log-to-file":false,"metrics-listen-addr":"{{ with .Pod.fireeth.metrics }}{{ .enabled \| ternary (printf \"%s:%d\" .addr ( .port \| int ) ) nil }}{{ end }}","pprof-listen-addr":"{{ with .Pod.fireeth.pprof }}{{ .enabled \| ternary (printf \"%s:%d\" .addr (.port \| int)) nil }}{{ end }}"},"genesisJson":{"enabled":false},"jwt":{"enabled":false,"existingSecret":{"key":null,"name":null},"fromLiteral":null},"metrics":{"addr":"0.0.0.0","enabled":true,"port":9102},"nodeArgs":{},"nodeArgsOrder":[],"nodeMetrics":{"enabled":false},"p2p":{"enabled":false,"port":null},"pprof":{"addr":"127.0.0.1","enabled":true,"port":6060},"services":[]}` |
 | firehoseComponentDefaults.fireeth.args | Command line arguments for fireeth Generated from this map and format can be tweaked with __separator and __prefix. the '__none' string allows for declaring an argument without a value (i.e. --sepolia) | object | `{"--config-file":"/config/config.yaml","__separator":"=","start":"__none"}` |
 | firehoseComponentDefaults.fireeth.argsOrder | List to set a specific order for some of the args elements. The ones set will appear first in the order of the list, and the reamining ones will be unsorted, or alphabetically sorted | list | `["start","--config-file"]` |
 | firehoseComponentDefaults.fireeth.config | Fireeth configuration paramaters | object | `{"common-forked-blocks-store-url":null,"common-live-blocks-addr":"relayer:10014","common-merged-blocks-store-url":null,"common-one-block-store-url":null,"data-dir":"/var/lib/fireeth","firehose-rate-limit-bucket-fill-rate":"1s","firehose-rate-limit-bucket-size":20,"log-to-file":false,"metrics-listen-addr":"{{ with .Pod.fireeth.metrics }}{{ .enabled \| ternary (printf \"%s:%d\" .addr ( .port \| int ) ) nil }}{{ end }}","pprof-listen-addr":"{{ with .Pod.fireeth.pprof }}{{ .enabled \| ternary (printf \"%s:%d\" .addr (.port \| int)) nil }}{{ end }}"}` |
 | firehoseComponentDefaults.fireeth.genesisJson.enabled | Add a genesis.json key to configMap | bool | `false` |
 | firehoseComponentDefaults.fireeth.jwt | Provision or use an existing JWT secret If it's enabled and neither existingSecret nor fromLiteral are set, a random secret will be generated and then re-used in the future | object | `{"enabled":false,"existingSecret":{"key":null,"name":null},"fromLiteral":null}` |
 | firehoseComponentDefaults.fireeth.jwt.enabled | Provision or make use of a JWT secret for Node | bool | `false` |
 | firehoseComponentDefaults.fireeth.jwt.existingSecret | Load the JWT from an existing Kubernetes Secret. Takes precedence over `fromLiteral` if set. | object | `{"key":null,"name":null}` |
 | firehoseComponentDefaults.fireeth.jwt.existingSecret.key | Data key for the JWT in the Secret | string | `nil` |
 | firehoseComponentDefaults.fireeth.jwt.existingSecret.name | Name of the Secret resource in the same namespace | string | `nil` |
 | firehoseComponentDefaults.fireeth.jwt.fromLiteral | Use this literal value for the JWT | string | `nil` |
 | firehoseComponentDefaults.fireeth.metrics | Enable support for metrics | object | `{"addr":"0.0.0.0","enabled":true,"port":9102}` |
 | firehoseComponentDefaults.fireeth.nodeArgs | Command line arguments to pass to the blockchain node | object | `{}` |
 | firehoseComponentDefaults.fireeth.nodeArgsOrder | List or ordered arguments for the nodeArgs | list | `[]` |
 | firehoseComponentDefaults.fireeth.nodeMetrics | Enable support for metrics on the blockchain node | object | `{"enabled":false}` |
 | firehoseComponentDefaults.fireeth.p2p | Enable a NodePort for P2P support in node | object | `{"enabled":false,"port":null}` |
 | firehoseComponentDefaults.fireeth.p2p.enabled | Expose P2P port via NodePort | bool | `false` |
 | firehoseComponentDefaults.fireeth.p2p.port | NodePort to be used. Must be unique. Leave blank for a dynamic port | string | `nil` |
 | firehoseComponentDefaults.fireeth.pprof | Enable pprof interface support for profiling data | object | `{"addr":"127.0.0.1","enabled":true,"port":6060}` |
 | firehoseComponentDefaults.fireeth.services | List of firehose services to launch (reader-node | merger | relayer | ...) | list | `[]` |
 | firehoseComponentDefaults.horizontalPodAutoscaler | Horizontal Pod Autoscaler configuration | object | `{"enabled":false,"metadata":{"annotations":{},"labels":{}},"spec":{}}` |
 | firehoseComponentDefaults.horizontalPodAutoscaler.metadata | Anything else will be marge on the final horizontalPodAutoscaler resource template | object | `{"annotations":{},"labels":{}}` |
 | firehoseComponentDefaults.image | Image configuration for firehose-ethereum | object | `{"digest":"","pullPolicy":"IfNotPresent","repository":"ghcr.io/streamingfast/firehose-ethereum","tag":"v2.6.7-geth-v1.13.15-fh2.4"}` |
 | firehoseComponentDefaults.image.digest | Overrides the image reference using a specific digest | string | `""` |
 | firehoseComponentDefaults.image.pullPolicy | Image pull policy | string | `"IfNotPresent"` |
 | firehoseComponentDefaults.image.repository | Docker image repository | string | `"ghcr.io/streamingfast/firehose-ethereum"` |
 | firehoseComponentDefaults.image.tag | Overrides the image reference using a tag digest takes precedence over tag if both are set | string | `"v2.6.7-geth-v1.13.15-fh2.4"` |
 | firehoseComponentDefaults.imagePullSecrets | Pull secrets required to fetch images | list | `[]` |
 | firehoseComponentDefaults.initContainers | Init containers configuration | object | `{"10-init-nodeport":{"enabled":"{{ .Pod.fireeth.p2p.enabled }}","image":"lachlanevenson/k8s-kubectl:v1.25.4","imagePullPolicy":"IfNotPresent","resources":{}},"20-init-envsubst":{"enabled":"{{ .Pod.configMap.options.useEnvSubst }}","image":"blockstack/envsubst:latest","imagePullPolicy":"IfNotPresent","resources":{}}}` |
 | firehoseComponentDefaults.kind | Default workload type (Deployment | StatefulSet) | string | `"Deployment"` |
 | firehoseComponentDefaults.labels | Component level labels (templated) | object | `{"app.kubernetes.io/component":"{{ .componentName }}","app.kubernetes.io/part-of":"{{ .Root.Release.Name }}"}` |
 | firehoseComponentDefaults.lifecycle | Lifecycle hooks | object | `{}` |
 | firehoseComponentDefaults.nodeSelector | Node selector configuration | object | `{}` |
 | firehoseComponentDefaults.podDisruptionBudget | Pod Disruption Budget configuration | object | `{"enabled":false,"metadata":{"annotations":{},"labels":{}},"spec":null}` |
 | firehoseComponentDefaults.podManagementPolicy | , scaling behavior: (OrderedReady | Parallel) | StatefulSet only | `"OrderedReady"` |
 | firehoseComponentDefaults.podSecurityContext | Pod-wide security context | object | `{"fsGroup":"{{ .Pod.podSecurityContext.runAsUser }}","runAsGroup":"{{ .Pod.podSecurityContext.runAsUser }}","runAsNonRoot":true,"runAsUser":1000}` |
 | firehoseComponentDefaults.ports | Container level ports configuration | object | `{"fh-metrics":{"containerPort":"{{ with .Pod.fireeth.metrics }}{{ .enabled \| ternary (printf \"%d\" ( .port \| int ) ) nil }}{{ end }}","protocol":"TCP"},"fh-pprof":{"containerPort":"{{ with .Pod.fireeth.pprof }}{{ .enabled \| ternary (printf \"%d\" ( .port \| int ) ) nil }}{{ end }}","protocol":"TCP"}}` |
 | firehoseComponentDefaults.rbac | RBAC role and binding configuration | object | `{"bindingSpec":{"metadata":{"annotations":{},"labels":{}},"roleRef":{}},"enabled":"{{ .Pod.serviceAccount.enabled }}","roleSpec":{"metadata":{"annotations":{},"labels":{}}}}` |
 | firehoseComponentDefaults.resources | Resource requests and limits | object | `{}` |
 | firehoseComponentDefaults.securityContext | Container level security context overrides | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":true}` |
 | firehoseComponentDefaults.service | Service customization | object | `{"enabled":true,"metadata":{"annotations":{},"labels":{},"name":"{{ include \"metadata.fullname\" $ }}-{{ .componentName }}"},"spec":{"ports":{"fh-metrics":{"port":"{{ with .Pod.fireeth.metrics }}{{ .enabled \| ternary (printf \"%d\" ( .port \| int ) ) nil }}{{ end }}","protocol":"{{ with .Pod.fireeth.metrics }}{{ .enabled \| ternary \"TCP\" nil }}{{ end }}"},"fh-pprof":{"port":"{{ with .Pod.fireeth.pprof }}{{ .enabled \| ternary (printf \"%d\" ( .port \| int ) ) nil }}{{ end }}","protocol":"{{ with .Pod.fireeth.pprof }}{{ .enabled \| ternary \"TCP\" nil }}{{ end }}"}},"type":"ClusterIP"}}` |
 | firehoseComponentDefaults.service.enabled | Create a Service | bool | `true` |
 | firehoseComponentDefaults.service.metadata.annotations | Additional service annotations | object | `{}` |
 | firehoseComponentDefaults.service.metadata.labels | Additional service labels | object | `{}` |
 | firehoseComponentDefaults.service.spec | Any other key/values will be merged with the final Service resource `spec.ports` is a key-value map, with the port name as key, and the spec as value | object | `{"ports":{"fh-metrics":{"port":"{{ with .Pod.fireeth.metrics }}{{ .enabled \| ternary (printf \"%d\" ( .port \| int ) ) nil }}{{ end }}","protocol":"{{ with .Pod.fireeth.metrics }}{{ .enabled \| ternary \"TCP\" nil }}{{ end }}"},"fh-pprof":{"port":"{{ with .Pod.fireeth.pprof }}{{ .enabled \| ternary (printf \"%d\" ( .port \| int ) ) nil }}{{ end }}","protocol":"{{ with .Pod.fireeth.pprof }}{{ .enabled \| ternary \"TCP\" nil }}{{ end }}"}},"type":"ClusterIP"}` |
 | firehoseComponentDefaults.service.spec.ports | Service ports configuration | object | `{"fh-metrics":{"port":"{{ with .Pod.fireeth.metrics }}{{ .enabled \| ternary (printf \"%d\" ( .port \| int ) ) nil }}{{ end }}","protocol":"{{ with .Pod.fireeth.metrics }}{{ .enabled \| ternary \"TCP\" nil }}{{ end }}"},"fh-pprof":{"port":"{{ with .Pod.fireeth.pprof }}{{ .enabled \| ternary (printf \"%d\" ( .port \| int ) ) nil }}{{ end }}","protocol":"{{ with .Pod.fireeth.pprof }}{{ .enabled \| ternary \"TCP\" nil }}{{ end }}"}}` |
 | firehoseComponentDefaults.service.spec.type | Service type | string | `"ClusterIP"` |
 | firehoseComponentDefaults.serviceAccount | Service account configuration | object | `{"enabled":true,"metadata":{"annotations":{},"labels":{}}}` |
 | firehoseComponentDefaults.serviceAccount.enabled | Specifies whether a service account should be created | bool | `true` |
 | firehoseComponentDefaults.serviceAccount.metadata | Rest spec | object | `{"annotations":{},"labels":{}}` |
 | firehoseComponentDefaults.serviceAccount.metadata.annotations | Annotations to add to the service account | object | `{}` |
 | firehoseComponentDefaults.serviceAccount.metadata.labels | Labels to add to the service account | object | `{}` |
 | firehoseComponentDefaults.serviceHeadless | Also create headless services, mandatory for StatefulSets and true by default | string | `"{{ eq .Pod.kind \"StatefulSet\" \| ternary true true }}"` |
 | firehoseComponentDefaults.serviceMonitor | ServiceMonitor configuration for Prometheus Operator | object | `{"enabled":true,"metadata":{"annotations":{},"labels":{}},"spec":{"endpoints":{"metrics-fh":{"honorLabels":true,"interval":"30s","path":"/metrics","scrapeTimeout":"10s"}}}}` |
 | firehoseComponentDefaults.serviceMonitor.enabled | Enable monitoring by creating `ServiceMonitor` CRDs ([prometheus-operator](https://github.com/prometheus-operator/prometheus-operator)) | bool | `true` |
 | firehoseComponentDefaults.serviceName | Required for StatefulSets | string | `"{{ include \"metadata.fullname\" $ }}-{{ .componentName }}-headless"` |
 | firehoseComponentDefaults.serviceP2P | Creates a NodePort service (used in P2P support) if a nodePort isn't specified, kubernetes will dinamically attribute one | object | `{"enabled":"{{ default false .Pod.fireeth.p2p.enabled }}","metadata":{"annotations":{},"labels":{}},"spec":{"ports":{"p2p-tcp":{"nodePort":null,"port":"{{ with .Pod.serviceP2P.spec.ports }}{{ default (30303 \| int) (index . \"p2p-tcp\" \"nodePort\" \| int) }}{{ end }}","protocol":"TCP","targetPort":null},"p2p-udp":{"nodePort":null,"port":"{{ with .Pod.serviceP2P.spec.ports }}{{ default (30303 \| int) (index . \"p2p-tcp\" \"nodePort\" \| int) }}{{ end }}","protocol":"UDP","targetPort":null}}}}` |
 | firehoseComponentDefaults.serviceP2P.metadata.annotations | Additional service annotations | object | `{}` |
 | firehoseComponentDefaults.serviceP2P.metadata.labels | Additional service labels | object | `{}` |
 | firehoseComponentDefaults.serviceP2P.spec | Any other key/values will be merged with the final Service resource `spec.ports` is a key-value map, with the port name as key, and the spec as value | object | `{"ports":{"p2p-tcp":{"nodePort":null,"port":"{{ with .Pod.serviceP2P.spec.ports }}{{ default (30303 \| int) (index . \"p2p-tcp\" \"nodePort\" \| int) }}{{ end }}","protocol":"TCP","targetPort":null},"p2p-udp":{"nodePort":null,"port":"{{ with .Pod.serviceP2P.spec.ports }}{{ default (30303 \| int) (index . \"p2p-tcp\" \"nodePort\" \| int) }}{{ end }}","protocol":"UDP","targetPort":null}}}` |
 | firehoseComponentDefaults.serviceP2P.spec.ports | Service ports configuration | object | `{"p2p-tcp":{"nodePort":null,"port":"{{ with .Pod.serviceP2P.spec.ports }}{{ default (30303 \| int) (index . \"p2p-tcp\" \"nodePort\" \| int) }}{{ end }}","protocol":"TCP","targetPort":null},"p2p-udp":{"nodePort":null,"port":"{{ with .Pod.serviceP2P.spec.ports }}{{ default (30303 \| int) (index . \"p2p-tcp\" \"nodePort\" \| int) }}{{ end }}","protocol":"UDP","targetPort":null}}` |
 | firehoseComponentDefaults.serviceP2P.spec.ports.p2p-tcp.nodePort | nodePort to use, if left null a dynamic one will be atributed | optional | `nil` |
 | firehoseComponentDefaults.serviceP2P.spec.ports.p2p-tcp.port | default is to use nodePort if specified, or 30303 | mandatory | `"{{ with .Pod.serviceP2P.spec.ports }}{{ default (30303 \| int) (index . \"p2p-tcp\" \"nodePort\" \| int) }}{{ end }}"` |
 | firehoseComponentDefaults.serviceP2P.spec.ports.p2p-tcp.targetPort | default is to use the port's name | optional | `nil` |
 | firehoseComponentDefaults.serviceP2P.spec.ports.p2p-udp.nodePort | nodePort to use, if left null a dynamic one will be atributed | optional | `nil` |
 | firehoseComponentDefaults.serviceP2P.spec.ports.p2p-udp.port | default is to use nodePort if specified, or 30303 | mandatory | `"{{ with .Pod.serviceP2P.spec.ports }}{{ default (30303 \| int) (index . \"p2p-tcp\" \"nodePort\" \| int) }}{{ end }}"` |
 | firehoseComponentDefaults.serviceP2P.spec.ports.p2p-udp.targetPort | default is to use the port's name | optional | `nil` |
 | firehoseComponentDefaults.terminationGracePeriodSeconds | Amount of time to wait before force-killing the process | int | `10` |
 | firehoseComponentDefaults.tolerations | Tolerations configuration | list | `[]` |
 | firehoseComponentDefaults.topologySpreadConstraints | Topology spread constraints | list | `[]` |
 | firehoseComponentDefaults.updateStrategy | Update Strategy, (RollingUpdate | Recreate) for Deployments, (RollingUpdate | OnDelete) for StatefulSets | object | `{"type":"RollingUpdate"}` |
 | firehoseComponentDefaults.volumeMounts | Container volumeMounts | object | `{"config":{"enabled":"{{ .Pod.configMap.enabled }}","mountPath":"{{ .Pod.configMap.options.useEnvSubst \| ternary \"/config-input\" \"/config\" }}","readOnly":true},"config-processed":{"enabled":"{{ .Pod.configMap.options.useEnvSubst }}","mountPath":"/config","readOnly":false},"data-dir":{"enabled":true,"mountPath":"{{ index .Pod.fireeth.config \"data-dir\" }}","readOnly":false}}` |
 | firehoseComponentDefaults.volumes | Pod volumes | object | `{"config":{"configMap":{"defaultMode":420,"name":"{{ include \"metadata.fullname\" $ }}-{{ .componentName }}-config"},"enabled":"{{ .Pod.configMap.enabled }}"},"config-processed":{"emptyDir":{"medium":"Memory"},"enabled":"{{ and .Pod.configMap.options.useEnvSubst .Pod.configMap.enabled }}"},"data-dir":{"emptyDir":{},"enabled":true},"env-dir":{"emptyDir":{},"enabled":"{{ (or (and .Pod.configMap.options.useEnvSubst .Pod.configMap.enabled) false ) \| ternary true false }}"}}` |
 | firehoseComponents | Definition and architecture of components to provision. A component is a kubernetes workload (Deployment or StatefulSet). The components will be named by the key name, and inherit the firehoseComponentDefaults as well as the defaults for the firehose services they will be set to run, under `.fireeth.services` list. For each component, configuraiton follows <firehoseComponentDefaults>. | object | `{"grpc":{"enabled":true,"fireeth":{"services":["firehose"]},"replicas":1},"index-builder":{"enabled":true,"fireeth":{"services":["index-builder"]}},"merger":{"enabled":true,"fireeth":{"services":["merger"]}},"reader-node":{"enabled":true,"fireeth":{"services":["reader-node"]},"replicas":1},"relayer":{"enabled":true,"fireeth":{"services":["relayer"]},"fullnameOverride":"","nameOverride":"","replicas":1}}` |
 | firehoseServiceDefaults | Defaults per firehose service type, will get inherited by workloads running that service keys will match service names, and on each key the same interface as <firehoseDefaults> is available | object | `{"firehose":{"fireeth":{"config":{"firehose-grpc-listen-addr":"0.0.0.0:10015"}},"ports":{"fh-grpc":{"containerPort":"{{ with .Pod.fireeth.config }}{{ if (index . \"firehose-grpc-listen-addr\") }}{{ splitList \":\" (index . \"firehose-grpc-listen-addr\") \| last \| int }}{{ else }}{{ nil }}{{ end }}{{ end }}","protocol":"TCP"}},"service":{"enabled":true,"spec":{"ports":{"fh-grpc":{"port":"{{ with .Pod.fireeth.config }}{{ if (index . \"firehose-grpc-listen-addr\") }}{{ splitList \":\" (index . \"firehose-grpc-listen-addr\") \| last \| int }}{{ else }}{{ nil }}{{ end }}{{ end }}","protocol":"TCP"}}}}},"index-builder":{"fireeth":{"config":{"index-builder-grpc-listen-addr":"0.0.0.0:10009","index-builder-index-size":"1000"}},"ports":{"index-grpc":{"containerPort":"{{ with .Pod.fireeth.config }}{{ if (index . \"index-builder-grpc-listen-addr\") }}{{ splitList \":\" (index . \"index-builder-grpc-listen-addr\") \| last \| int }}{{ else }}{{ nil }}{{ end }}{{ end }}","protocol":"TCP"}},"service":{"enabled":true,"spec":{"ports":{"index-grpc":{"port":"{{ with .Pod.fireeth.config }}{{ if (index . \"index-builder-grpc-listen-addr\") }}{{ splitList \":\" (index . \"index-builder-grpc-listen-addr\") \| last \| int }}{{ else }}{{ nil }}{{ end }}{{ end }}","protocol":"TCP"}}}}},"merger":{"fireeth":{"config":{"merger-grpc-listen-addr":":10012"}},"ports":{"merger-grpc":{"containerPort":"{{ with .Pod.fireeth.config }}{{ if (index . \"merger-grpc-listen-addr\") }}{{ splitList \":\" (index . \"merger-grpc-listen-addr\") \| last \| int }}{{ else }}{{ nil }}{{ end }}{{ end }}","protocol":"TCP"}},"service":{"enabled":true,"spec":{"ports":{"merger-grpc":{"port":"{{ with .Pod.fireeth.config }}{{ if (index . \"merger-grpc-listen-addr\") }}{{ splitList \":\" (index . \"merger-grpc-listen-addr\") \| last \| int }}{{ else }}{{ nil }}{{ end }}{{ end }}","protocol":"TCP"}}}}},"reader-node":{"clusterRbac":{"enabled":"{{ .Pod.fireeth.p2p.enabled }}","roleSpec":{"rules":[{"apiGroups":[""],"resources":["nodes"],"verbs":["get","list","watch"]}]}},"configMap":{"data":"{{ with .Pod.fireeth.genesisJson }}{{ .enabled \| ternary ( .data \| toYaml \| nindent 8 ) nil }}{{ end }}","options":{"useEnvSubst":true}},"env":{"MANAGER_API_PORT":"{{ with .Pod.fireeth.config }}{{ hasKey . \"reader-node-manager-api-addr\" \| ternary (splitList \":\" (index . \"reader-node-manager-api-addr\") \| last \| int) nil }}{{ end }}"},"fireeth":{"config":{"reader-node-bootstrap-data-url":"{{ with .Pod.fireeth.genesisJson }}{{ .enabled \| ternary \"/genesis/genesis.json\" nil }}{{ end }}","reader-node-data-dir":"/var/lib/geth","reader-node-grpc-listen-addr":"0.0.0.0:10010","reader-node-manager-api-addr":"127.0.0.1:10011","reader-node-path":"/app/geth"},"genesisJson":{"data":{"genesis.json":"<JSON data>\n"},"enabled":false},"jwt":{"enabled":true},"nodeArgs":{"__prefix":"--","__separator":"=","authrpc.addr":"0.0.0.0","authrpc.jwtsecret":"{{ with .Pod.fireeth.jwt }}{{ .enabled \| ternary \"/secrets/jwt/jwt.hex\" nil }}{{ end }}","authrpc.port":8551,"authrpc.vhosts":"*","cache":8192,"datadir":"{node-data-dir}","discovery.port":"{{ .Pod.fireeth.p2p.enabled \| ternary \"${EXTERNAL_PORT}\" nil }}","firehose-enabled":"__none","history.transactions":1000,"http":"__none","http.addr":"0.0.0.0","http.api":"net,web3,eth,debug","http.port":8545,"http.vhosts":"*","maxpeers":100,"metrics.addr":"{{ with .Pod.fireeth.nodeMetrics }}{{ .enabled \| ternary .addr nil }}{{ end }}","metrics.port":"{{ with .Pod.fireeth.nodeMetrics }}{{ .enabled \| ternary (.port \| int) nil }}{{ end }}","nat":"{{ .Pod.fireeth.p2p.enabled \| ternary \"extip:${EXTERNAL_IP}\" nil }}","port":"{{ .Pod.fireeth.p2p.enabled \| ternary \"${EXTERNAL_PORT}\" nil }}","snapshot":"true","syncmode":"full"},"nodeArgsOrder":[],"nodeMetrics":{"addr":"0.0.0.0","enabled":true,"port":6061},"p2p":{"enabled":true,"port":null}},"kind":"StatefulSet","lifecycle":{"preStop":{"exec":{"command":["/usr/local/bin/eth-maintenance"]}}},"ports":{"node-authrpc":{"containerPort":"{{ with .Pod.fireeth.nodeArgs }}{{ hasKey . \"authrpc.port\" \| ternary (index . \"authrpc.port\" \| int) nil }}{{ end }}","protocol":"TCP"},"node-metrics":{"containerport":"{{ with .Pod.fireeth.nodeMetrics }}{{ if .port }}{{ .port \| int }}{{ else }}null{{ end }}{{ end }}","protocol":"TCP"},"node-mgr":{"containerPort":"{{ splitList \":\" ( index .Pod.fireeth.config \"reader-node-manager-api-addr\" ) \| last \| int }}","protocol":"TCP"},"node-rpc":{"containerPort":"{{ with .Pod.fireeth.nodeArgs }}{{ hasKey . \"http.port\" \| ternary (index . \"http.port\" \| int) nil }}{{ end }}","protocol":"TCP"},"reader-grpc":{"containerPort":"{{ with .Pod.fireeth.config }}{{ if (index . \"reader-node-grpc-listen-addr\") }}{{ splitList \":\" (index . \"reader-node-grpc-listen-addr\") \| last \| int }}{{ else }}{{ nil }}{{ end }}{{ end }}","protocol":"TCP"}},"rbac":{"enabled":true,"roleSpec":{"rules":[{"apiGroups":[""],"resources":["services"],"verbs":["get","list","watch"]},{"apiGroups":[""],"resources":["secrets"],"verbs":["get","create"]}]}},"service":{"spec":{"ports":{"node-authrpc":{"port":"{{ with .Pod.fireeth.nodeArgs }}{{ hasKey . \"authrpc.port\" \| ternary (index . \"authrpc.port\" \| int) nil }}{{ end }}","protocol":"{{ with .Pod.fireeth.nodeArgs }}{{ hasKey . \"authrpc.port\" \| ternary \"TCP\" nil }}{{ end }}"},"node-metrics":{"port":"{{ with .Pod.fireeth.nodeMetrics }}{{ .enabled \| ternary (.port \| int) nil }}{{ end }}","protocol":"{{ with .Pod.fireeth.nodeMetrics }}{{ .enabled \| ternary \"TCP\" nil }}{{ end }}"},"node-mgr":{"port":"{{ with .Pod.fireeth.config }}{{ hasKey . \"reader-node-manager-api-addr\" \| ternary (splitList \":\" (index . \"reader-node-manager-api-addr\") \| last) nil }}{{ end }}","protocol":"{{ with .Pod.fireeth.config }}{{ hasKey . \"reader-node-manager-api-addr\" \| ternary \"TCP\" nil }}{{ end }}"},"node-rpc":{"port":"{{ with .Pod.fireeth.nodeArgs }}{{ hasKey . \"http.port\" \| ternary (index . \"http.port\" \| int) nil }}{{ end }}","protocol":"{{ with .Pod.fireeth.nodeArgs }}{{ hasKey . \"http.port\" \| ternary \"TCP\" nil }}{{ end }}"},"reader-grpc":{"port":"{{ with .Pod.fireeth.config \| default dict }}{{ if (index . \"reader-node-grpc-listen-addr\") }}{{ splitList \":\" (index . \"reader-node-grpc-listen-addr\") \| last \| int }}{{ else }}null{{ end }}{{ end }}","protocol":"TCP"}}}},"volumeClaimTemplates":{"data-dir":{"enabled":true,"metadata":{"labels":{}},"spec":{"accessModes":["ReadWriteOnce"],"resources":{"requests":{"storage":"50Gi"}},"storageClassName":"openebs-zfs-localpv-compressed-8k"}},"node-data-dir":{"enabled":true,"metadata":{"labels":{}},"spec":{"accessModes":["ReadWriteOnce"],"resources":{"requests":{"storage":"3Ti"}},"storageClassName":"openebs-zfs-localpv-compressed-8k"}}},"volumeMounts":{"genesis-json":{"enabled":"{{ .Pod.fireeth.genesisJson.enabled \| default false }}","mountPath":"/genesis","readOnly":true,"subPath":"genesis.json"},"jwt-secret":{"enabled":"{{ .Pod.fireeth.jwt.enabled \| default false }}","mountPath":"/secrets/jwt","readOnly":true},"node-data-dir":{"enabled":true,"mountPath":"{{ index .Pod.fireeth.config \"reader-node-data-dir\" }}","readOnly":false}},"volumes":{"data-dir":{"emptyDir":null,"persistentVolumeClaim":{"claimName":"data-dir"}},"genesis-json":{"configMap":{"defaultMode":420,"items":[{"key":"genesis.json","path":"genesis.json"}],"name":"{{ include \"metadata.fullname\" $ }}-{{ .componentName }}-config"},"enabled":"{{ .Pod.fireeth.genesisJson.enabled \| default false }}"},"jwt-secret":{"enabled":"{{ .Pod.fireeth.jwt.enabled \| default false }}","secret":{"items":[{"key":"{{ with .Pod.fireeth.jwt }}{{ .existingSecret.key \| default \"jwt.hex\" }}{{ end }}","path":"jwt.hex"}],"secretName":"{{ with .Pod.fireeth.jwt }}{{ .existingSecret.name \| default (printf \"%s-%s-jwt\" (include \"metadata.fullname\" $) $.componentName ) }}{{ end }}"}},"node-data-dir":{"enabled":true,"persistentVolumeClaim":{"claimName":"node-data-dir"}}}},"relayer":{"fireeth":{"config":{"relayer-grpc-listen-addr":"0.0.0.0:10014","relayer-max-source-latency":"1h","relayer-source":"firehose-ethereum-1-reader:10010"}},"ports":{"relayer-grpc":{"containerPort":"{{ with .Pod.fireeth.config }}{{ if (index . \"relayer-grpc-listen-addr\") }}{{ splitList \":\" (index . \"relayer-grpc-listen-addr\") \| last \| int }}{{ else }}{{ nil }}{{ end }}{{ end }}","protocol":"TCP"}},"service":{"enabled":true,"spec":{"ports":{"relayer-grpc":{"port":"{{ with .Pod.fireeth.config }}{{ if (index . \"relayer-grpc-listen-addr\") }}{{ splitList \":\" (index . \"relayer-grpc-listen-addr\") \| last \| int }}{{ else }}{{ nil }}{{ end }}{{ end }}","protocol":"TCP"}}}}}}` |
 | firehoseServiceDefaults.firehose | Defaults for the firehose service | object | `{"fireeth":{"config":{"firehose-grpc-listen-addr":"0.0.0.0:10015"}},"ports":{"fh-grpc":{"containerPort":"{{ with .Pod.fireeth.config }}{{ if (index . \"firehose-grpc-listen-addr\") }}{{ splitList \":\" (index . \"firehose-grpc-listen-addr\") \| last \| int }}{{ else }}{{ nil }}{{ end }}{{ end }}","protocol":"TCP"}},"service":{"enabled":true,"spec":{"ports":{"fh-grpc":{"port":"{{ with .Pod.fireeth.config }}{{ if (index . \"firehose-grpc-listen-addr\") }}{{ splitList \":\" (index . \"firehose-grpc-listen-addr\") \| last \| int }}{{ else }}{{ nil }}{{ end }}{{ end }}","protocol":"TCP"}}}}}` |
 | firehoseServiceDefaults.index-builder | Defaults for the index-builder service | object | `{"fireeth":{"config":{"index-builder-grpc-listen-addr":"0.0.0.0:10009","index-builder-index-size":"1000"}},"ports":{"index-grpc":{"containerPort":"{{ with .Pod.fireeth.config }}{{ if (index . \"index-builder-grpc-listen-addr\") }}{{ splitList \":\" (index . \"index-builder-grpc-listen-addr\") \| last \| int }}{{ else }}{{ nil }}{{ end }}{{ end }}","protocol":"TCP"}},"service":{"enabled":true,"spec":{"ports":{"index-grpc":{"port":"{{ with .Pod.fireeth.config }}{{ if (index . \"index-builder-grpc-listen-addr\") }}{{ splitList \":\" (index . \"index-builder-grpc-listen-addr\") \| last \| int }}{{ else }}{{ nil }}{{ end }}{{ end }}","protocol":"TCP"}}}}}` |
 | firehoseServiceDefaults.merger | Defaults for the merger service | object | `{"fireeth":{"config":{"merger-grpc-listen-addr":":10012"}},"ports":{"merger-grpc":{"containerPort":"{{ with .Pod.fireeth.config }}{{ if (index . \"merger-grpc-listen-addr\") }}{{ splitList \":\" (index . \"merger-grpc-listen-addr\") \| last \| int }}{{ else }}{{ nil }}{{ end }}{{ end }}","protocol":"TCP"}},"service":{"enabled":true,"spec":{"ports":{"merger-grpc":{"port":"{{ with .Pod.fireeth.config }}{{ if (index . \"merger-grpc-listen-addr\") }}{{ splitList \":\" (index . \"merger-grpc-listen-addr\") \| last \| int }}{{ else }}{{ nil }}{{ end }}{{ end }}","protocol":"TCP"}}}}}` |
 | firehoseServiceDefaults.reader-node | Defaults for the reader-node service | object | `{"clusterRbac":{"enabled":"{{ .Pod.fireeth.p2p.enabled }}","roleSpec":{"rules":[{"apiGroups":[""],"resources":["nodes"],"verbs":["get","list","watch"]}]}},"configMap":{"data":"{{ with .Pod.fireeth.genesisJson }}{{ .enabled \| ternary ( .data \| toYaml \| nindent 8 ) nil }}{{ end }}","options":{"useEnvSubst":true}},"env":{"MANAGER_API_PORT":"{{ with .Pod.fireeth.config }}{{ hasKey . \"reader-node-manager-api-addr\" \| ternary (splitList \":\" (index . \"reader-node-manager-api-addr\") \| last \| int) nil }}{{ end }}"},"fireeth":{"config":{"reader-node-bootstrap-data-url":"{{ with .Pod.fireeth.genesisJson }}{{ .enabled \| ternary \"/genesis/genesis.json\" nil }}{{ end }}","reader-node-data-dir":"/var/lib/geth","reader-node-grpc-listen-addr":"0.0.0.0:10010","reader-node-manager-api-addr":"127.0.0.1:10011","reader-node-path":"/app/geth"},"genesisJson":{"data":{"genesis.json":"<JSON data>\n"},"enabled":false},"jwt":{"enabled":true},"nodeArgs":{"__prefix":"--","__separator":"=","authrpc.addr":"0.0.0.0","authrpc.jwtsecret":"{{ with .Pod.fireeth.jwt }}{{ .enabled \| ternary \"/secrets/jwt/jwt.hex\" nil }}{{ end }}","authrpc.port":8551,"authrpc.vhosts":"*","cache":8192,"datadir":"{node-data-dir}","discovery.port":"{{ .Pod.fireeth.p2p.enabled \| ternary \"${EXTERNAL_PORT}\" nil }}","firehose-enabled":"__none","history.transactions":1000,"http":"__none","http.addr":"0.0.0.0","http.api":"net,web3,eth,debug","http.port":8545,"http.vhosts":"*","maxpeers":100,"metrics.addr":"{{ with .Pod.fireeth.nodeMetrics }}{{ .enabled \| ternary .addr nil }}{{ end }}","metrics.port":"{{ with .Pod.fireeth.nodeMetrics }}{{ .enabled \| ternary (.port \| int) nil }}{{ end }}","nat":"{{ .Pod.fireeth.p2p.enabled \| ternary \"extip:${EXTERNAL_IP}\" nil }}","port":"{{ .Pod.fireeth.p2p.enabled \| ternary \"${EXTERNAL_PORT}\" nil }}","snapshot":"true","syncmode":"full"},"nodeArgsOrder":[],"nodeMetrics":{"addr":"0.0.0.0","enabled":true,"port":6061},"p2p":{"enabled":true,"port":null}},"kind":"StatefulSet","lifecycle":{"preStop":{"exec":{"command":["/usr/local/bin/eth-maintenance"]}}},"ports":{"node-authrpc":{"containerPort":"{{ with .Pod.fireeth.nodeArgs }}{{ hasKey . \"authrpc.port\" \| ternary (index . \"authrpc.port\" \| int) nil }}{{ end }}","protocol":"TCP"},"node-metrics":{"containerport":"{{ with .Pod.fireeth.nodeMetrics }}{{ if .port }}{{ .port \| int }}{{ else }}null{{ end }}{{ end }}","protocol":"TCP"},"node-mgr":{"containerPort":"{{ splitList \":\" ( index .Pod.fireeth.config \"reader-node-manager-api-addr\" ) \| last \| int }}","protocol":"TCP"},"node-rpc":{"containerPort":"{{ with .Pod.fireeth.nodeArgs }}{{ hasKey . \"http.port\" \| ternary (index . \"http.port\" \| int) nil }}{{ end }}","protocol":"TCP"},"reader-grpc":{"containerPort":"{{ with .Pod.fireeth.config }}{{ if (index . \"reader-node-grpc-listen-addr\") }}{{ splitList \":\" (index . \"reader-node-grpc-listen-addr\") \| last \| int }}{{ else }}{{ nil }}{{ end }}{{ end }}","protocol":"TCP"}},"rbac":{"enabled":true,"roleSpec":{"rules":[{"apiGroups":[""],"resources":["services"],"verbs":["get","list","watch"]},{"apiGroups":[""],"resources":["secrets"],"verbs":["get","create"]}]}},"service":{"spec":{"ports":{"node-authrpc":{"port":"{{ with .Pod.fireeth.nodeArgs }}{{ hasKey . \"authrpc.port\" \| ternary (index . \"authrpc.port\" \| int) nil }}{{ end }}","protocol":"{{ with .Pod.fireeth.nodeArgs }}{{ hasKey . \"authrpc.port\" \| ternary \"TCP\" nil }}{{ end }}"},"node-metrics":{"port":"{{ with .Pod.fireeth.nodeMetrics }}{{ .enabled \| ternary (.port \| int) nil }}{{ end }}","protocol":"{{ with .Pod.fireeth.nodeMetrics }}{{ .enabled \| ternary \"TCP\" nil }}{{ end }}"},"node-mgr":{"port":"{{ with .Pod.fireeth.config }}{{ hasKey . \"reader-node-manager-api-addr\" \| ternary (splitList \":\" (index . \"reader-node-manager-api-addr\") \| last) nil }}{{ end }}","protocol":"{{ with .Pod.fireeth.config }}{{ hasKey . \"reader-node-manager-api-addr\" \| ternary \"TCP\" nil }}{{ end }}"},"node-rpc":{"port":"{{ with .Pod.fireeth.nodeArgs }}{{ hasKey . \"http.port\" \| ternary (index . \"http.port\" \| int) nil }}{{ end }}","protocol":"{{ with .Pod.fireeth.nodeArgs }}{{ hasKey . \"http.port\" \| ternary \"TCP\" nil }}{{ end }}"},"reader-grpc":{"port":"{{ with .Pod.fireeth.config \| default dict }}{{ if (index . \"reader-node-grpc-listen-addr\") }}{{ splitList \":\" (index . \"reader-node-grpc-listen-addr\") \| last \| int }}{{ else }}null{{ end }}{{ end }}","protocol":"TCP"}}}},"volumeClaimTemplates":{"data-dir":{"enabled":true,"metadata":{"labels":{}},"spec":{"accessModes":["ReadWriteOnce"],"resources":{"requests":{"storage":"50Gi"}},"storageClassName":"openebs-zfs-localpv-compressed-8k"}},"node-data-dir":{"enabled":true,"metadata":{"labels":{}},"spec":{"accessModes":["ReadWriteOnce"],"resources":{"requests":{"storage":"3Ti"}},"storageClassName":"openebs-zfs-localpv-compressed-8k"}}},"volumeMounts":{"genesis-json":{"enabled":"{{ .Pod.fireeth.genesisJson.enabled \| default false }}","mountPath":"/genesis","readOnly":true,"subPath":"genesis.json"},"jwt-secret":{"enabled":"{{ .Pod.fireeth.jwt.enabled \| default false }}","mountPath":"/secrets/jwt","readOnly":true},"node-data-dir":{"enabled":true,"mountPath":"{{ index .Pod.fireeth.config \"reader-node-data-dir\" }}","readOnly":false}},"volumes":{"data-dir":{"emptyDir":null,"persistentVolumeClaim":{"claimName":"data-dir"}},"genesis-json":{"configMap":{"defaultMode":420,"items":[{"key":"genesis.json","path":"genesis.json"}],"name":"{{ include \"metadata.fullname\" $ }}-{{ .componentName }}-config"},"enabled":"{{ .Pod.fireeth.genesisJson.enabled \| default false }}"},"jwt-secret":{"enabled":"{{ .Pod.fireeth.jwt.enabled \| default false }}","secret":{"items":[{"key":"{{ with .Pod.fireeth.jwt }}{{ .existingSecret.key \| default \"jwt.hex\" }}{{ end }}","path":"jwt.hex"}],"secretName":"{{ with .Pod.fireeth.jwt }}{{ .existingSecret.name \| default (printf \"%s-%s-jwt\" (include \"metadata.fullname\" $) $.componentName ) }}{{ end }}"}},"node-data-dir":{"enabled":true,"persistentVolumeClaim":{"claimName":"node-data-dir"}}}}` |
 | firehoseServiceDefaults.reader-node.fireeth.genesisJson.data."genesis.json" | Add your genesis file JSON here | string | `"<JSON data>\n"` |
 | firehoseServiceDefaults.reader-node.fireeth.genesisJson.enabled | Add a genesis.json key to reader-node configMap | bool | `false` |
 | firehoseServiceDefaults.reader-node.ports | Container ports | object | `{"node-authrpc":{"containerPort":"{{ with .Pod.fireeth.nodeArgs }}{{ hasKey . \"authrpc.port\" \| ternary (index . \"authrpc.port\" \| int) nil }}{{ end }}","protocol":"TCP"},"node-metrics":{"containerport":"{{ with .Pod.fireeth.nodeMetrics }}{{ if .port }}{{ .port \| int }}{{ else }}null{{ end }}{{ end }}","protocol":"TCP"},"node-mgr":{"containerPort":"{{ splitList \":\" ( index .Pod.fireeth.config \"reader-node-manager-api-addr\" ) \| last \| int }}","protocol":"TCP"},"node-rpc":{"containerPort":"{{ with .Pod.fireeth.nodeArgs }}{{ hasKey . \"http.port\" \| ternary (index . \"http.port\" \| int) nil }}{{ end }}","protocol":"TCP"},"reader-grpc":{"containerPort":"{{ with .Pod.fireeth.config }}{{ if (index . \"reader-node-grpc-listen-addr\") }}{{ splitList \":\" (index . \"reader-node-grpc-listen-addr\") \| last \| int }}{{ else }}{{ nil }}{{ end }}{{ end }}","protocol":"TCP"}}` |
 | firehoseServiceDefaults.relayer | Defaults for the relayer service | object | `{"fireeth":{"config":{"relayer-grpc-listen-addr":"0.0.0.0:10014","relayer-max-source-latency":"1h","relayer-source":"firehose-ethereum-1-reader:10010"}},"ports":{"relayer-grpc":{"containerPort":"{{ with .Pod.fireeth.config }}{{ if (index . \"relayer-grpc-listen-addr\") }}{{ splitList \":\" (index . \"relayer-grpc-listen-addr\") \| last \| int }}{{ else }}{{ nil }}{{ end }}{{ end }}","protocol":"TCP"}},"service":{"enabled":true,"spec":{"ports":{"relayer-grpc":{"port":"{{ with .Pod.fireeth.config }}{{ if (index . \"relayer-grpc-listen-addr\") }}{{ splitList \":\" (index . \"relayer-grpc-listen-addr\") \| last \| int }}{{ else }}{{ nil }}{{ end }}{{ end }}","protocol":"TCP"}}}}}` |
 | global.annotations | Global annotations added to all resources | object | `{}` |
 | global.fullnameOverride |  | string | `""` |
 | global.labels | Global labels added to all resources | object | `{"app.kubernetes.io/instance":"{{ .Root.Release.Name }}","app.kubernetes.io/managed-by":"{{ .Root.Release.Service }}","app.kubernetes.io/name":"{{ include \"metadata.name\" . }}","app.kubernetes.io/version":"{{ .Root.Chart.AppVersion }}","helm.sh/chart":"{{ include \"metadata.chart\" . }}","version.firehose.graphops.xyz/fireeth":"2.6.7","version.firehose.graphops.xyz/node":"1.13.15","version.firehose.graphops.xyz/protocol":"2.4"}` |
 | global.nameOverride |  | string | `""` |

## Contributing

We welcome and appreciate your contributions! Please see the [Contributor Guide](/CONTRIBUTING.md), [Code Of Conduct](/CODE_OF_CONDUCT.md) and [Security Notes](/SECURITY.md) for this repository.
