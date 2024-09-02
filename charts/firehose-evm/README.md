# Firehose-Evm Helm Chart

Deploy and scale all components of [Firehose EVM](https://github.com/streamingfast/firehose-ethereum) inside Kubernetes with ease

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) ![Version: 0.0.0](https://img.shields.io/badge/Version-0.0.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v2.6.7](https://img.shields.io/badge/AppVersion-v2.6.7-informational?style=flat-square)

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
then the result would be `kind: Deployment`. So it makes sense most of the `firehoseServiceDefaults` are really component specific and do not overlap much with each other.

### General chart interfaces

Virtually any aspect of both the workload, or any of the other resources can be extended or overridden.

There are three major `.Values` sections:
- firehoseComponents

- firehoseComponentDefaults
- global

## Quickstart

To install the chart with the release name `my-release`:

```console
$ helm repo add graphops http://graphops.github.io/launchpad-charts
$ helm install my-release graphops/firehose-evm
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
 | firehoseComponentDefaults.configMap.enabled |  | bool | `true` |
 | firehoseComponentDefaults.configMap.template |  | string | `"{{- $nodeArgs := false }}\nstart:\n  args:\n    {{- range .Pod.fireeth.services }}\n    - {{ . }}\n    {{- if contains \"node\" . }}\n    {{- $nodeArgs := true }}\n    {{- end }}\n    {{- end }}\n  flags:\n    {{- .Pod.fireeth.config \| toYaml \| nindent 4 }}\n    {{- if $nodeArgs }}\n    {{- $readerNodeArgs := include \"utils.generateArgsList\" (dict \"map\" ( .Pod.node.args \| default dict ) ) \| fromYamlArray }}\n    reader-node-arguments: \|\n    {{- range $readerNodeArgs }}\n      - {{ . \| quote }}\n    {{- end }}\n    {{- end }}\n"` |
 | firehoseComponentDefaults.configMap.useEnvSubst |  | bool | `false` |
 | firehoseComponentDefaults.env | Environment variables | object | `{}` |
 | firehoseComponentDefaults.envFrom | Environment variables from references | object | `{"SecretKeyRef":{"FIREETH_COMMON_FORKED_BLOCKS_STORE_URL":{"key":"","name":""},"FIREETH_COMMON_INDEX_STORE_URL":{"key":"","name":""},"FIREETH_COMMON_MERGED_BLOCKS_STORE_URL":{"key":"","name":""},"FIREETH_COMMON_ONE_BLOCK_STORE_URL":{"key":"","name":""}}}` |
 | firehoseComponentDefaults.envFrom.SecretKeyRef.FIREETH_COMMON_FORKED_BLOCKS_STORE_URL.key | Name of the data key in the secret that contains your S3 bucket url for storing forked blocks | string | `""` |
 | firehoseComponentDefaults.envFrom.SecretKeyRef.FIREETH_COMMON_FORKED_BLOCKS_STORE_URL.name | Name of the secret that contains your S3 bucket url for storing forked blocks | string | `""` |
 | firehoseComponentDefaults.envFrom.SecretKeyRef.FIREETH_COMMON_INDEX_STORE_URL.key | Name of the data key in the secret that contains your S3 bucket url of your index store | string | `""` |
 | firehoseComponentDefaults.envFrom.SecretKeyRef.FIREETH_COMMON_INDEX_STORE_URL.name | Name of the secret that contains your S3 bucket url of your index store | string | `""` |
 | firehoseComponentDefaults.envFrom.SecretKeyRef.FIREETH_COMMON_MERGED_BLOCKS_STORE_URL.key | Name of the data key in the secret that contains your S3 bucket url for storing merged blocks | string | `""` |
 | firehoseComponentDefaults.envFrom.SecretKeyRef.FIREETH_COMMON_MERGED_BLOCKS_STORE_URL.name | Name of the secret that contains your S3 bucket url for storing merged blocks | string | `""` |
 | firehoseComponentDefaults.envFrom.SecretKeyRef.FIREETH_COMMON_ONE_BLOCK_STORE_URL.key | Name of the data key in the secret that contains your S3 bucket url for storing one blocks | string | `""` |
 | firehoseComponentDefaults.envFrom.SecretKeyRef.FIREETH_COMMON_ONE_BLOCK_STORE_URL.name | Name of the secret that contains your S3 bucket url for storing one blocks | string | `""` |
 | firehoseComponentDefaults.extraContainers | Extra containers to add to the pod (templated) | object | `{}` |
 | firehoseComponentDefaults.fireeth | Firehose-specific configuration | object | `{"args":{"-c":"/config/config.yaml","start":"__none"},"argsOrder":["start","-c"],"config":{"common-forked-blocks-store-url":null,"common-index-block-sizes":10000,"common-live-blocks-addr":"relayer:10014","common-merged-blocks-store-url":null,"common-one-block-store-url":null,"data-dir":"/var/lib/fireeth","firehose-rate-limit-bucket-fill-rate":"1s","firehose-rate-limit-bucket-size":20,"log-to-file":false,"metrics-listen-addr":"{{ with .Pod.fireeth.metrics }}{{ .enabled \| ternary (printf \"%s:%d\" .addr ( .port \| int ) ) nil }}{{ end }}","pprof-listen-addr":"{{ with .Pod.fireeth.pprof }}{{ .enabled \| ternary (printf \"%s:%d\" .addr ( .port \| int ) ) nil }}{{ end }}"},"metrics":{"addr":"0.0.0.0","enabled":true,"port":9102},"pprof":{"addr":"127.0.0.1","enabled":true,"port":6060},"services":[]}` |
 | firehoseComponentDefaults.horizontalPodAutoscaler | Horizontal Pod Autoscaler configuration | object | `{"enabled":true}` |
 | firehoseComponentDefaults.image | Image configuration for firehose-evm | object | `{"digest":"","pullPolicy":"IfNotPresent","repository":"ghcr.io/streamingfast/firehose-ethereum","tag":"v2.6.7-geth-v1.13.15-fh2.4"}` |
 | firehoseComponentDefaults.image.digest | Overrides the image reference using a specific digest | string | `""` |
 | firehoseComponentDefaults.image.pullPolicy | Image pull policy | string | `"IfNotPresent"` |
 | firehoseComponentDefaults.image.repository | Docker image repository | string | `"ghcr.io/streamingfast/firehose-ethereum"` |
 | firehoseComponentDefaults.image.tag | Overrides the image reference using a tag digest takes precedence over tag if both are set | string | `"v2.6.7-geth-v1.13.15-fh2.4"` |
 | firehoseComponentDefaults.imagePullSecrets | Pull secrets required to fetch images | list | `[]` |
 | firehoseComponentDefaults.initContainers | Init containers configuration | object | `{}` |
 | firehoseComponentDefaults.kind |  | string | `"Deployment"` |
 | firehoseComponentDefaults.labels | Component level labels (templated) | object | `{"app.kubernetes.io/component":"{{ .componentName }}","app.kubernetes.io/part-of":"{{ .Root.Release.Name }}","version.firehose.graphops.xyz/fireeth":"2.6.7","version.firehose.graphops.xyz/node":"1.13.15","version.firehose.graphops.xyz/protocol":"2.4"}` |
 | firehoseComponentDefaults.lifecycle | Lifecycle hooks | object | `{}` |
 | firehoseComponentDefaults.nodeSelector | Node selector configuration | object | `{}` |
 | firehoseComponentDefaults.persistence | Persistence configuration | object | `{"accessModes":["ReadWriteOnce"],"enabled":false,"size":"50Gi","storageClassName":"openebs-zfs-localpv-compressed-128k"}` |
 | firehoseComponentDefaults.persistence.accessModes | Access modes for the persistent volume | list | `["ReadWriteOnce"]` |
 | firehoseComponentDefaults.persistence.enabled | Enable persistent storage | bool | `false` |
 | firehoseComponentDefaults.persistence.size | Size of the persistent volume | string | `"50Gi"` |
 | firehoseComponentDefaults.persistence.storageClassName | Storage class name | string | `"openebs-zfs-localpv-compressed-128k"` |
 | firehoseComponentDefaults.podDisruptionBudget | Pod Disruption Budget configuration | object | `{"enabled":true}` |
 | firehoseComponentDefaults.podManagementPolicy | , scaling behavior: (OrderedReady | Parallel) | StatefulSet only | `"OrderedReady"` |
 | firehoseComponentDefaults.podSecurityContext | Pod-wide security context | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":true,"runAsNonRoot":true,"runAsUser":1000}` |
 | firehoseComponentDefaults.ports.metrics-fh.containerPort |  | string | `"{{ with .Pod.fireeth.metrics }}{{ .enabled \| ternary (printf \"%d\" ( .port \| int ) ) nil }}{{ end }}"` |
 | firehoseComponentDefaults.ports.metrics-fh.protocol |  | string | `"TCP"` |
 | firehoseComponentDefaults.resources | Resource requests and limits | object | `{}` |
 | firehoseComponentDefaults.securityContext | Container level security context overrides | object | `{}` |
 | firehoseComponentDefaults.service | Service configuration | object | `{"annotations":{},"enabled":true,"labels":{},"spec":{"ports":{"fh-metrics":{"port":"{{ with .Pod.fireeth.metrics }}{{ .enabled \| ternary (printf \"%d\" ( .port \| int ) ) nil }}{{ end }}","protocol":"TCP"}},"type":"ClusterIP"}}` |
 | firehoseComponentDefaults.service.annotations | Additional service annotations | object | `{}` |
 | firehoseComponentDefaults.service.labels | Additional service labels | object | `{}` |
 | firehoseComponentDefaults.service.spec.ports | Service ports configuration | object | `{"fh-metrics":{"port":"{{ with .Pod.fireeth.metrics }}{{ .enabled \| ternary (printf \"%d\" ( .port \| int ) ) nil }}{{ end }}","protocol":"TCP"}}` |
 | firehoseComponentDefaults.service.spec.type | Service type | string | `"ClusterIP"` |
 | firehoseComponentDefaults.serviceAccount | Service account configuration | object | `{"annotations":{},"create":true,"labels":{},"name":"","rbac":{"clusterWide":false,"create":true,"rules":[]}}` |
 | firehoseComponentDefaults.serviceAccount.annotations | Annotations to add to the service account | object | `{}` |
 | firehoseComponentDefaults.serviceAccount.create | Specifies whether a service account should be created | bool | `true` |
 | firehoseComponentDefaults.serviceAccount.labels | Labels to add to the service account | object | `{}` |
 | firehoseComponentDefaults.serviceAccount.name | The name of the service account to use. If not set and create is true, a name is generated using the fullname template | string | `""` |
 | firehoseComponentDefaults.serviceHeadless | Also create headless services, mandatory for StatefulSets and true by default | string | `"{{ eq .Pod.kind \"StatefulSet\" \| ternary true true }}"` |
 | firehoseComponentDefaults.serviceMonitor | ServiceMonitor configuration for Prometheus Operator | object | `{"enabled":true,"metadata":{"annotations":{},"labels":{}},"spec":{"endpoints":{"metrics-fh":{"honorLabels":true,"interval":"30s","path":"/metrics","scrapeTimeout":"10s"}}}}` |
 | firehoseComponentDefaults.serviceMonitor.enabled | Enable monitoring by creating `ServiceMonitor` CRDs ([prometheus-operator](https://github.com/prometheus-operator/prometheus-operator)) | bool | `true` |
 | firehoseComponentDefaults.terminationGracePeriodSeconds | Amount of time to wait before force-killing the process | int | `10` |
 | firehoseComponentDefaults.tolerations | Tolerations configuration | list | `[]` |
 | firehoseComponentDefaults.topologySpreadConstraints | Topology spread constraints | list | `[]` |
 | firehoseComponentDefaults.updateStrategy | Update Strategy, (RollingUpdate | Recreate) for Deployments, (RollingUpdate | OnDelete) for StatefulSets | object | `{"type":"RollingUpdate"}` |
 | firehoseComponentDefaults.volumeMounts.config-processed.enabled |  | string | `"{{ .Pod.configMap.useEnvSubst }}"` |
 | firehoseComponentDefaults.volumeMounts.config-processed.mountPath |  | string | `"/config"` |
 | firehoseComponentDefaults.volumeMounts.config-processed.readOnly |  | bool | `false` |
 | firehoseComponentDefaults.volumeMounts.config.enabled |  | string | `"{{ .Pod.configMap.enabled }}"` |
 | firehoseComponentDefaults.volumeMounts.config.mountPath |  | string | `"{{ .Pod.configMap.useEnvSubst \| ternary \"/config-input\" \"/config\" }}"` |
 | firehoseComponentDefaults.volumeMounts.config.readOnly |  | bool | `true` |
 | firehoseComponentDefaults.volumeMounts.data-dir.enabled |  | bool | `true` |
 | firehoseComponentDefaults.volumeMounts.data-dir.mountPath |  | string | `"{{ index .Pod.fireeth.config \"data-dir\" }}"` |
 | firehoseComponentDefaults.volumeMounts.data-dir.readOnly |  | bool | `false` |
 | firehoseComponentDefaults.volumes.config-processed.emptyDir |  | object | `{}` |
 | firehoseComponentDefaults.volumes.config-processed.enabled |  | string | `"{{ .Pod.configMap.useEnvSubst }}"` |
 | firehoseComponentDefaults.volumes.config.configMap.defaultMode |  | int | `420` |
 | firehoseComponentDefaults.volumes.config.configMap.name |  | string | `"{{ include \"metadata.fullname\" $ }}-{{ .componentName }}-config"` |
 | firehoseComponentDefaults.volumes.config.enabled |  | string | `"{{ .Pod.configMap.enabled }}"` |
 | firehoseComponentDefaults.volumes.data-dir.emptyDir |  | object | `{}` |
 | firehoseComponentDefaults.volumes.data-dir.enabled |  | bool | `true` |
 | firehoseComponents.grpc.enabled |  | bool | `true` |
 | firehoseComponents.grpc.existingConfigMap |  | string | `""` |
 | firehoseComponents.grpc.fireeth | Firehose-specific configuration | object | `{"services":["firehose"]}` |
 | firehoseComponents.grpc.fullnameOverride |  | string | `""` |
 | firehoseComponents.grpc.nameOverride |  | string | `""` |
 | firehoseComponents.grpc.replicas |  | int | `1` |
 | firehoseComponents.index-builder.enabled |  | bool | `true` |
 | firehoseComponents.index-builder.fireeth | Firehose-specific configuration | object | `{"services":["index-builder"]}` |
 | firehoseComponents.merger.enabled |  | bool | `true` |
 | firehoseComponents.merger.fireeth.services[0] |  | string | `"merger"` |
 | firehoseComponents.reader-node.dataDir |  | string | `"/var/lib/geth"` |
 | firehoseComponents.reader-node.enabled |  | bool | `true` |
 | firehoseComponents.reader-node.fireeth | Firehose-specific configuration | object | `{"services":["reader-node"]}` |
 | firehoseComponents.reader-node.fullnameOverride |  | string | `""` |
 | firehoseComponents.reader-node.initSnapshot.enabled |  | bool | `false` |
 | firehoseComponents.reader-node.initSnapshot.env.SNAPSHOT_REMOTE_LOCATION |  | string | `"add_snapshot_location"` |
 | firehoseComponents.reader-node.nameOverride |  | string | `""` |
 | firehoseComponents.reader-node.node.jwt | JWT for clients to authenticate with the Engine API. Specify either `existingSecret` OR `fromLiteral`. | object | `{"existingSecret":{"key":null,"name":null},"fromLiteral":"1ce5c87e81573667e685eae935d988a92742d5f466d696605cc207a36389c480"}` |
 | firehoseComponents.reader-node.node.jwt.existingSecret | Load the JWT from an existing Kubernetes Secret. Takes precedence over `fromLiteral` if set. | object | `{"key":null,"name":null}` |
 | firehoseComponents.reader-node.node.jwt.existingSecret.key | Data key for the JWT in the Secret | string | `nil` |
 | firehoseComponents.reader-node.node.jwt.existingSecret.name | Name of the Secret resource in the same namespace | string | `nil` |
 | firehoseComponents.reader-node.node.jwt.fromLiteral | Use this literal value for the JWT | string | `"1ce5c87e81573667e685eae935d988a92742d5f466d696605cc207a36389c480"` |
 | firehoseComponents.reader-node.nodePath |  | string | `"/usr/lib/geth"` |
 | firehoseComponents.reader-node.p2p.enabled | Expose P2P port via NodePort | bool | `false` |
 | firehoseComponents.reader-node.p2p.port | NodePort to be used. Must be unique. | int | `32310` |
 | firehoseComponents.reader-node.p2p.type |  | string | `"NodePort"` |
 | firehoseComponents.reader-node.p2pNodePort.enabled | Expose P2P port via NodePort | bool | `true` |
 | firehoseComponents.reader-node.p2pNodePort.initContainer.image.pullPolicy | Container pull policy | string | `"IfNotPresent"` |
 | firehoseComponents.reader-node.p2pNodePort.initContainer.image.repository | Container image to fetch nodeport information | string | `"lachlanevenson/k8s-kubectl"` |
 | firehoseComponents.reader-node.p2pNodePort.initContainer.image.tag | Container tag | string | `"v1.25.4"` |
 | firehoseComponents.reader-node.p2pNodePort.port | NodePort to be used. Must be unique. | int | `32310` |
 | firehoseComponents.reader-node.persistence | Persistence configuration | object | `{"enabled":true,"reader_node":{"accessModes":["ReadWriteOnce"],"resources":{"requests":{"storage":"3Ti"}},"storageClassName":"openebs-zfs-localpv-compressed-8k"}}` |
 | firehoseComponents.reader-node.persistence.reader_node.accessModes | Access modes for the persistent volume | list | `["ReadWriteOnce"]` |
 | firehoseComponents.reader-node.persistence.reader_node.resources.requests.storage | The amount of disk space to provision | string | `"3Ti"` |
 | firehoseComponents.reader-node.persistence.reader_node.storageClassName | The storage class to use when provisioning a persistent volume | string | `"openebs-zfs-localpv-compressed-8k"` |
 | firehoseComponents.reader-node.replicas |  | int | `1` |
 | firehoseComponents.relayer.enabled |  | bool | `true` |
 | firehoseComponents.relayer.fireeth.services[0] |  | string | `"relayer"` |
 | firehoseComponents.relayer.fullnameOverride |  | string | `""` |
 | firehoseComponents.relayer.nameOverride |  | string | `""` |
 | firehoseComponents.relayer.replicas |  | int | `1` |
 | firehoseServiceDefaults.firehose.fireeth.config.firehose-grpc-listen-addr |  | string | `"0.0.0.0:10015"` |
 | firehoseServiceDefaults.firehose.ports.firehose-grpc.containerPort |  | string | `"{{ with .Pod.fireeth.config }}{{ if (index . \"firehose-grpc-listen-addr\") }}{{ splitList \":\" (index . \"firehose-grpc-listen-addr\") \| last \| int }}{{ else }}{{ nil }}{{ end }}{{ end }}"` |
 | firehoseServiceDefaults.firehose.ports.firehose-grpc.protocol |  | string | `"TCP"` |
 | firehoseServiceDefaults.firehose.service.enabled |  | bool | `true` |
 | firehoseServiceDefaults.firehose.service.spec.ports.firehose-grpc.port |  | string | `"{{ with .Pod.fireeth.config }}{{ if (index . \"firehose-grpc-listen-addr\") }}{{ splitList \":\" (index . \"firehose-grpc-listen-addr\") \| last \| int }}{{ else }}{{ nil }}{{ end }}{{ end }}"` |
 | firehoseServiceDefaults.firehose.service.spec.ports.firehose-grpc.protocol |  | string | `"TCP"` |
 | firehoseServiceDefaults.index-builder.fireeth.config.index-builder-grpc-listen-addr |  | string | `"0.0.0.0:10009"` |
 | firehoseServiceDefaults.index-builder.fireeth.config.index-builder-index-size |  | string | `"1000"` |
 | firehoseServiceDefaults.index-builder.ports.index-builder-grpc.containerPort |  | string | `"{{ with .Pod.fireeth.config }}{{ if (index . \"index-builder-grpc-listen-addr\") }}{{ splitList \":\" (index . \"index-builder-grpc-listen-addr\") \| last \| int }}{{ else }}{{ nil }}{{ end }}{{ end }}"` |
 | firehoseServiceDefaults.index-builder.ports.index-builder-grpc.protocol |  | string | `"TCP"` |
 | firehoseServiceDefaults.index-builder.service.enabled |  | bool | `true` |
 | firehoseServiceDefaults.index-builder.service.spec.ports.index-builder-grpc.port |  | string | `"{{ with .Pod.fireeth.config }}{{ if (index . \"index-builder-grpc-listen-addr\") }}{{ splitList \":\" (index . \"index-builder-grpc-listen-addr\") \| last \| int }}{{ else }}{{ nil }}{{ end }}{{ end }}"` |
 | firehoseServiceDefaults.index-builder.service.spec.ports.index-builder-grpc.protocol |  | string | `"TCP"` |
 | firehoseServiceDefaults.merger.fireeth.config.merger-grpc-listen-addr |  | string | `":10012"` |
 | firehoseServiceDefaults.merger.ports.merger-grpc.containerPort |  | string | `"{{ with .Pod.fireeth.config }}{{ if (index . \"merger-grpc-listen-addr\") }}{{ splitList \":\" (index . \"merger-grpc-listen-addr\") \| last \| int }}{{ else }}{{ nil }}{{ end }}{{ end }}"` |
 | firehoseServiceDefaults.merger.ports.merger-grpc.protocol |  | string | `"TCP"` |
 | firehoseServiceDefaults.merger.service.enabled |  | bool | `true` |
 | firehoseServiceDefaults.merger.service.spec.ports.merger-grpc.port |  | string | `"{{ with .Pod.fireeth.config }}{{ if (index . \"merger-grpc-listen-addr\") }}{{ splitList \":\" (index . \"merger-grpc-listen-addr\") \| last \| int }}{{ else }}{{ nil }}{{ end }}{{ end }}"` |
 | firehoseServiceDefaults.merger.service.spec.ports.merger-grpc.protocol |  | string | `"TCP"` |
 | firehoseServiceDefaults.reader-node.configMap.useEnvSubst |  | bool | `true` |
 | firehoseServiceDefaults.reader-node.env.MANAGER_API_PORT |  | string | `"{{ splitList \":\" ( index .Pod.fireeth.config \"reader-node-manager-api-addr\" ) \| last }}"` |
 | firehoseServiceDefaults.reader-node.fireeth.config.reader-node-data-dir |  | string | `"/var/lib/geth"` |
 | firehoseServiceDefaults.reader-node.fireeth.config.reader-node-grpc-listen-addr |  | string | `"0.0.0.0:10010"` |
 | firehoseServiceDefaults.reader-node.fireeth.config.reader-node-manager-api-addr |  | string | `"127.0.0.1:10011"` |
 | firehoseServiceDefaults.reader-node.fireeth.config.reader-node-path |  | string | `"/app/geth"` |
 | firehoseServiceDefaults.reader-node.initContainers | Init containers configuration | object | `{"10-init-nodeport":{"image":"lachlanevenson/k8s-kubectl:v1.25.4","imagePullPolicy":"IfNotPresent","resources":{}},"20-init-snapshot":{"image":"rclone/rclone:1.67.0","imagePullPolicy":"IfNotPresent","resources":{}}}` |
 | firehoseServiceDefaults.reader-node.kind |  | string | `"StatefulSet"` |
 | firehoseServiceDefaults.reader-node.lifecycle.preStop.exec.command[0] |  | string | `"/usr/local/bin/eth-maintenance"` |
 | firehoseServiceDefaults.reader-node.node.args."authrpc.addr" |  | string | `"0.0.0.0"` |
 | firehoseServiceDefaults.reader-node.node.args."authrpc.jwtsecret" |  | string | `"/jwt/jwt.hex"` |
 | firehoseServiceDefaults.reader-node.node.args."authrpc.port" |  | int | `8551` |
 | firehoseServiceDefaults.reader-node.node.args."authrpc.vhosts" |  | string | `"*"` |
 | firehoseServiceDefaults.reader-node.node.args."discovery.port" |  | string | `"EXTERNAL_PORT"` |
 | firehoseServiceDefaults.reader-node.node.args."http.addr" |  | string | `"0.0.0.0"` |
 | firehoseServiceDefaults.reader-node.node.args."http.api" |  | string | `"net,web3,eth,debug"` |
 | firehoseServiceDefaults.reader-node.node.args."http.vhosts" |  | string | `"*"` |
 | firehoseServiceDefaults.reader-node.node.args."metrics.addr" |  | string | `"0.0.0.0"` |
 | firehoseServiceDefaults.reader-node.node.args."metrics.port" |  | int | `6061` |
 | firehoseServiceDefaults.reader-node.node.args.__prefix |  | string | `"--"` |
 | firehoseServiceDefaults.reader-node.node.args.__separator |  | string | `"="` |
 | firehoseServiceDefaults.reader-node.node.args.cache |  | int | `8192` |
 | firehoseServiceDefaults.reader-node.node.args.datadir |  | string | `"{node-data-dir}"` |
 | firehoseServiceDefaults.reader-node.node.args.firehose-enabled |  | string | `"__none"` |
 | firehoseServiceDefaults.reader-node.node.args.http |  | string | `"__none"` |
 | firehoseServiceDefaults.reader-node.node.args.maxpeers |  | int | `100` |
 | firehoseServiceDefaults.reader-node.node.args.nat |  | string | `"extip:EXTERNAL_IP"` |
 | firehoseServiceDefaults.reader-node.node.args.networkid |  | int | `11155111` |
 | firehoseServiceDefaults.reader-node.node.args.port |  | string | `"EXTERNAL_PORT"` |
 | firehoseServiceDefaults.reader-node.node.args.sepolia |  | string | `"__none"` |
 | firehoseServiceDefaults.reader-node.node.args.snapshot |  | string | `"true"` |
 | firehoseServiceDefaults.reader-node.node.args.syncmode |  | string | `"full"` |
 | firehoseServiceDefaults.reader-node.node.args.txlookuplimit |  | int | `1000` |
 | firehoseServiceDefaults.reader-node.node.metrics.addr |  | string | `"0.0.0.0"` |
 | firehoseServiceDefaults.reader-node.node.metrics.enabled |  | bool | `true` |
 | firehoseServiceDefaults.reader-node.node.metrics.port |  | int | `6061` |
 | firehoseServiceDefaults.reader-node.ports | Container ports | object | `{"reader-node-grpc":{"containerPort":"{{ with .Pod.fireeth.config }}{{ if (index . \"reader-node-grpc-listen-addr\") }}{{ splitList \":\" (index . \"reader-node-grpc-listen-addr\") \| last \| int }}{{ else }}{{ nil }}{{ end }}{{ end }}","protocol":"TCP"}}` |
 | firehoseServiceDefaults.reader-node.service.spec.ports.node-auth.port |  | int | `8551` |
 | firehoseServiceDefaults.reader-node.service.spec.ports.node-auth.protocol |  | string | `"TCP"` |
 | firehoseServiceDefaults.reader-node.service.spec.ports.node-metrics.port |  | int | `6061` |
 | firehoseServiceDefaults.reader-node.service.spec.ports.node-metrics.protocol |  | string | `"TCP"` |
 | firehoseServiceDefaults.reader-node.service.spec.ports.node-mgr.port |  | string | `"{{ splitList \":\" ( index .Pod.fireeth.config \"reader-node-manager-api-addr\" ) \| last \| int }}"` |
 | firehoseServiceDefaults.reader-node.service.spec.ports.node-mgr.protocol |  | string | `"TCP"` |
 | firehoseServiceDefaults.reader-node.service.spec.ports.reader-node-grpc.port |  | string | `"{{ with .Pod.fireeth.config }}{{ if (index . \"reader-node-grpc-listen-addr\") }}{{ splitList \":\" (index . \"reader-node-grpc-listen-addr\") \| last \| int }}{{ else }}{{ nil }}{{ end }}{{ end }}"` |
 | firehoseServiceDefaults.reader-node.service.spec.ports.reader-node-grpc.protocol |  | string | `"TCP"` |
 | firehoseServiceDefaults.reader-node.volumeClaimTemplates.data-dir.enabled |  | bool | `true` |
 | firehoseServiceDefaults.reader-node.volumeClaimTemplates.data-dir.metadata.labels |  | object | `{}` |
 | firehoseServiceDefaults.reader-node.volumeClaimTemplates.data-dir.spec.accessModes[0] |  | string | `"ReadWriteOnce"` |
 | firehoseServiceDefaults.reader-node.volumeClaimTemplates.data-dir.spec.resources.requests.storage |  | string | `"50Gi"` |
 | firehoseServiceDefaults.reader-node.volumeClaimTemplates.data-dir.spec.storageClassName |  | string | `"standard"` |
 | firehoseServiceDefaults.reader-node.volumes.data-dir.emptyDir |  | string | `nil` |
 | firehoseServiceDefaults.reader-node.volumes.data-dir.persistentVolumeClaim.claimName |  | string | `"data-dir"` |
 | firehoseServiceDefaults.relayer.fireeth.config.relayer-grpc-listen-addr |  | string | `"0.0.0.0:10014"` |
 | firehoseServiceDefaults.relayer.fireeth.config.relayer-max-source-latency |  | string | `"1h"` |
 | firehoseServiceDefaults.relayer.fireeth.config.relayer-source |  | string | `"reader:10010"` |
 | firehoseServiceDefaults.relayer.ports.relayer-grpc.containerPort |  | string | `"{{ with .Pod.fireeth.config }}{{ if (index . \"relayer-grpc-listen-addr\") }}{{ splitList \":\" (index . \"relayer-grpc-listen-addr\") \| last \| int }}{{ else }}{{ nil }}{{ end }}{{ end }}"` |
 | firehoseServiceDefaults.relayer.ports.relayer-grpc.protocol |  | string | `"TCP"` |
 | firehoseServiceDefaults.relayer.service.enabled |  | bool | `true` |
 | firehoseServiceDefaults.relayer.service.spec.ports.relayer-grpc.port |  | string | `"{{ with .Pod.fireeth.config }}{{ if (index . \"relayer-grpc-listen-addr\") }}{{ splitList \":\" (index . \"relayer-grpc-listen-addr\") \| last \| int }}{{ else }}{{ nil }}{{ end }}{{ end }}"` |
 | firehoseServiceDefaults.relayer.service.spec.ports.relayer-grpc.protocol |  | string | `"TCP"` |
 | global.annotations | Global annotations added to all resources | object | `{}` |
 | global.fullnameOverride |  | string | `""` |
 | global.labels | Global labels added to all resources | object | `{}` |
 | global.nameOverride |  | string | `""` |

## Contributing

We welcome and appreciate your contributions! Please see the [Contributor Guide](/CONTRIBUTING.md), [Code Of Conduct](/CODE_OF_CONDUCT.md) and [Security Notes](/SECURITY.md) for this repository.
