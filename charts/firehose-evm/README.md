# Firehose-Evm Helm Chart

Deploy and scale all components of [Firehose EVM](https://github.com/streamingfast/firehose-ethereum) inside Kubernetes with ease

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) ![Version: 0.0.0](https://img.shields.io/badge/Version-0.0.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v2.6.7](https://img.shields.io/badge/AppVersion-v2.6.7-informational?style=flat-square)

## Introduction

Firehose is a high-performance blockchain data extraction tool that captures, processes, and streams blockchain data in real-time, enabling efficient data analysis and integration for various applications. This chart can be used to deploy any [Firehose EVM](https://github.com/streamingfast/firehose-ethereum) chain.

## Chart Features

- Actively maintained by [GraphOps](https://graphops.xyz) [and contributors](https://github.com/graphops/launchpad-charts/graphs/contributors)
- Strong security defaults (non-root execution, ready-only root filesystem, drops all capabilities)
- Readiness checks to ensure traffic only hits `Pod`s that are healthy and ready to serve requests
- Support for `ServiceMonitor`s to configure Prometheus to scrape metrics ([prometheus-operator](https://github.com/prometheus-operator/prometheus-operator))
- Support for configuring Grafana dashboards ([grafana](https://github.com/grafana/helm-charts/tree/main/charts/grafana))

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
 | common.affinity | Affinity configuration | object | `{}` |
 | common.annotations | Component level annotations (templated) | object | `{}` |
 | common.configMap.enabled |  | bool | `true` |
 | common.configMap.template |  | string | `"{{ $nodeArgs := false }}\nstart:\n  args:\n    {{- range .Pod.fireeth.components }}\n    - {{ . }}\n    {{- if contains \"node\" . }}\n    {{- $nodeArgs := true }}\n    {{- end }}\n    {{- end }}\n  flags:\n    {{- .Pod.fireeth.config \| toYaml \| nindent 4 }}\n    {{- if $nodeArgs }}\n    {{- $readerNodeArgs := include \"utils.generateArgsList\" (dict \"map\" ( .Pod.node.args \| default dict ) ) \| fromYamlArray }}\n    reader-node-arguments: \|\n    {{- range $readerNodeArgs }}\n      - {{ . \| quote }}\n    {{- end }}\n    {{- end }}\n"` |
 | common.env | Environment variables | object | `{}` |
 | common.envFromConfigmap | Environment variables from ConfigMaps | object | `{}` |
 | common.envFromSecret | Environment variables from secrets | object | `{"FIREETH_COMMON_FORKED_BLOCKS_STORE_URL":{"key":"","secretName":""},"FIREETH_COMMON_INDEX_STORE_URL":{"key":"","secretName":""},"FIREETH_COMMON_MERGED_BLOCKS_STORE_URL":{"key":"","secretName":""},"FIREETH_COMMON_ONE_BLOCK_STORE_URL":{"key":"","secretName":""}}` |
 | common.envFromSecret.FIREETH_COMMON_FORKED_BLOCKS_STORE_URL.key | Name of the data key in the secret that contains your S3 bucket url for storing forked blocks | string | `""` |
 | common.envFromSecret.FIREETH_COMMON_FORKED_BLOCKS_STORE_URL.secretName | Name of the secret that contains your S3 bucket url for storing forked blocks | string | `""` |
 | common.envFromSecret.FIREETH_COMMON_INDEX_STORE_URL.key | Name of the data key in the secret that contains your S3 bucket url of your index store | string | `""` |
 | common.envFromSecret.FIREETH_COMMON_INDEX_STORE_URL.secretName | Name of the secret that contains your S3 bucket url of your index store | string | `""` |
 | common.envFromSecret.FIREETH_COMMON_MERGED_BLOCKS_STORE_URL.key | Name of the data key in the secret that contains your S3 bucket url for storing merged blocks | string | `""` |
 | common.envFromSecret.FIREETH_COMMON_MERGED_BLOCKS_STORE_URL.secretName | Name of the secret that contains your S3 bucket url for storing merged blocks | string | `""` |
 | common.envFromSecret.FIREETH_COMMON_ONE_BLOCK_STORE_URL.key | Name of the data key in the secret that contains your S3 bucket url for storing one blocks | string | `""` |
 | common.envFromSecret.FIREETH_COMMON_ONE_BLOCK_STORE_URL.secretName | Name of the secret that contains your S3 bucket url for storing one blocks | string | `""` |
 | common.extraContainers | Extra containers to add to the pod (templated) | object | `{}` |
 | common.extraVolumeMounts |  | object | `{}` |
 | common.extraVolumes | Extra volumes to add to the pod (templated) | list | `[]` |
 | common.fireeth | Firehose-specific configuration | object | `{"args":{"-c":"__none","/config/config.yaml":"__none","start":"__none"},"argsOrder":["start","-c","/config/config.yaml"],"components":[],"config":{"common-forked-blocks-store-url":null,"common-index-block-sizes":10000,"common-live-blocks-addr":"relayer:10014","common-merged-blocks-store-url":null,"common-one-block-store-url":null,"data-dir":"/var/lib/fireeth","firehose-grpc-listen-addr":":9000","firehose-rate-limit-bucket-fill-rate":"1s","firehose-rate-limit-bucket-size":20,"log-to-file":false,"metrics-listen-addr":"{{ with .Pod.fireeth.metrics }}{{ .enabled \| ternary (printf \"%s:%d\" .addr ( .port \| int ) ) nil }}{{ end }}","pprof-listen-addr":"{{ with .Pod.fireeth.pprof }}{{ .enabled \| ternary (printf \"%s:%d\" .addr ( .port \| int ) ) nil }}{{ end }}"},"metrics":{"addr":"0.0.0.0","enabled":true,"port":9102},"pprof":{"addr":"localhost","enabled":false,"port":6060}}` |
 | common.horizontalPodAutoscaler | Horizontal Pod Autoscaler configuration | object | `{"enabled":true}` |
 | common.image | Image configuration for firehose-evm | object | `{"digest":"","pullPolicy":"IfNotPresent","repository":"ghcr.io/streamingfast/firehose-ethereum","tag":"v2.6.7-geth-v1.13.15-fh2.4"}` |
 | common.image.digest | Overrides the image reference using a specific digest | string | `""` |
 | common.image.pullPolicy | Image pull policy | string | `"IfNotPresent"` |
 | common.image.repository | Docker image repository | string | `"ghcr.io/streamingfast/firehose-ethereum"` |
 | common.image.tag | Overrides the image reference using a tag digest takes precedence over tag if both are set | string | `"v2.6.7-geth-v1.13.15-fh2.4"` |
 | common.imagePullSecrets | Pull secrets required to fetch images | list | `[]` |
 | common.initContainers | Init containers configuration | object | `{}` |
 | common.kind |  | string | `"Deployment"` |
 | common.labels | Component level labels (templated) | object | `{"app.kubernetes.io/component":"{{ .componentName }}","app.kubernetes.io/part-of":"{{ .Root.Release.Name }}","version.firehose.graphops.xyz/fireeth":"2.6.7","version.firehose.graphops.xyz/node":"1.13.15","version.firehose.graphops.xyz/protocol":"2.4"}` |
 | common.lifecycle | Lifecycle hooks | object | `{}` |
 | common.nodeSelector | Node selector configuration | object | `{}` |
 | common.persistence | Persistence configuration | object | `{"accessModes":["ReadWriteOnce"],"enabled":false,"size":"50Gi","storageClassName":"openebs-zfs-localpv-compressed-128k"}` |
 | common.persistence.accessModes | Access modes for the persistent volume | list | `["ReadWriteOnce"]` |
 | common.persistence.enabled | Enable persistent storage | bool | `false` |
 | common.persistence.size | Size of the persistent volume | string | `"50Gi"` |
 | common.persistence.storageClassName | Storage class name | string | `"openebs-zfs-localpv-compressed-128k"` |
 | common.podDisruptionBudget | Pod Disruption Budget configuration | object | `{"enabled":true}` |
 | common.podSecurityContext | Pod-wide security context | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":true,"runAsNonRoot":true,"runAsUser":1000}` |
 | common.resources | Resource requests and limits | object | `{}` |
 | common.securityContext | Container level security context overrides | object | `{}` |
 | common.service | Service configuration | object | `{"annotations":{},"enabled":true,"labels":{},"spec":{"ports":{"metrics-fh":{"port":"{{ .Pod.fireeth.metrics.port }}","protocol":"TCP"}},"type":"ClusterIP"}}` |
 | common.service.annotations | Additional service annotations | object | `{}` |
 | common.service.labels | Additional service labels | object | `{}` |
 | common.service.spec.ports | Service ports configuration | object | `{"metrics-fh":{"port":"{{ .Pod.fireeth.metrics.port }}","protocol":"TCP"}}` |
 | common.service.spec.type | Service type | string | `"ClusterIP"` |
 | common.serviceAccount | Service account configuration | object | `{"annotations":{},"create":true,"labels":{},"name":"","rbac":{"clusterWide":false,"create":true,"rules":[]}}` |
 | common.serviceAccount.annotations | Annotations to add to the service account | object | `{}` |
 | common.serviceAccount.create | Specifies whether a service account should be created | bool | `true` |
 | common.serviceAccount.labels | Labels to add to the service account | object | `{}` |
 | common.serviceAccount.name | The name of the service account to use. If not set and create is true, a name is generated using the fullname template | string | `""` |
 | common.serviceHeadless | Also create headless services | bool | `true` |
 | common.serviceMonitor | ServiceMonitor configuration for Prometheus Operator | object | `{"enabled":true,"spec":{"endpoints":{"metrics-fh":{"honorLabels":true,"interval":"60s","scrapeTimeout":"10s"}}}}` |
 | common.serviceMonitor.enabled | Enable monitoring by creating `ServiceMonitor` CRDs ([prometheus-operator](https://github.com/prometheus-operator/prometheus-operator)) | bool | `true` |
 | common.terminationGracePeriodSeconds | Amount of time to wait before force-killing the process | int | `10` |
 | common.tolerations | Tolerations configuration | list | `[]` |
 | common.topologySpreadConstraints | Topology spread constraints | list | `[]` |
 | firehosePods.grpc.configMap.enabled |  | bool | `true` |
 | firehosePods.grpc.enabled |  | bool | `true` |
 | firehosePods.grpc.existingConfigMap |  | string | `""` |
 | firehosePods.grpc.fireeth | Firehose-specific configuration | object | `{"components":["firehose"],"config":{"firehose-grpc-listen-addr":":10015"}}` |
 | firehosePods.grpc.fullnameOverride |  | string | `""` |
 | firehosePods.grpc.nameOverride |  | string | `""` |
 | firehosePods.grpc.replicas |  | int | `1` |
 | firehosePods.grpc.service | Service configuration | object | `{"enabled":true,"spec":{"ports":{"grpc":{"containerPort":10015,"protocol":"TCP"},"metrics-fh":{"containerPort":9102,"protocol":"TCP"}}}}` |
 | firehosePods.index-builder.configMap.enabled |  | bool | `true` |
 | firehosePods.index-builder.enabled |  | bool | `true` |
 | firehosePods.index-builder.fireeth | Firehose-specific configuration | object | `{"components":["index-builder"],"config":{"index-builder-grpc-listen-addr":":10009","index-builder-index-size":"1000"}}` |
 | firehosePods.index-builder.service | Service configuration | object | `{"enabled":true,"spec":{"ports":{"indexer-grpc":{"containerPort":10009,"protocol":"TCP"},"metrics-fh":{"containerPort":9102,"protocol":"TCP"}}}}` |
 | firehosePods.merger.enabled |  | bool | `true` |
 | firehosePods.merger.fireeth.components[0] |  | string | `"merger"` |
 | firehosePods.merger.fireeth.config.merger-grpc-listen-addr |  | string | `":10012"` |
 | firehosePods.merger.service | Service configuration | object | `{"enabled":true,"spec":{"ports":{"merger-grpc":{"containerPort":10012,"protocol":"TCP"},"metrics-fh":{"containerPort":9102,"protocol":"TCP"}}}}` |
 | firehosePods.reader-node.configMap.enabled |  | bool | `true` |
 | firehosePods.reader-node.configMap.template |  | string | `"start:\n  args:\n    - {{ .componentName }}\n  flags:\n    {{- .Pod.fireeth.config \| toYaml \| nindent 4 }}\n    {{- $readerNodeArgs := include \"utils.generateArgsList\" (dict \"map\" ( .Pod.node.args \| default dict ) ) \| fromYamlArray }}\n    reader-node-arguments: \|\n    {{- range $readerNodeArgs }}\n      - {{ . \| quote }}\n    {{- end }}\n"` |
 | firehosePods.reader-node.dataDir |  | string | `"/var/lib/geth"` |
 | firehosePods.reader-node.enabled |  | bool | `true` |
 | firehosePods.reader-node.env | Service configuration | object | `{"MANAGER_API_PORT":"{{ splitList \":\" ( index .Pod.fireeth.config \"reader-node-manager-api-addr\" ) \| last }}"}` |
 | firehosePods.reader-node.fireeth | Firehose-specific configuration | object | `{"components":["reader-node"],"config":{"reader-node-data-dir":"/var/lib/geth","reader-node-grpc-listen-addr":":10010","reader-node-manager-api-addr":":10011","reader-node-path":"/app/geth"}}` |
 | firehosePods.reader-node.fullnameOverride |  | string | `""` |
 | firehosePods.reader-node.initContainers | Init containers configuration | object | `{"10-init-nodeport":{"__condition":"{{ .Pod.p2p.enabled }}","image":"lachlanevenson/k8s-kubectl:v1.25.4","imagePullPolicy":"IfNotPresent","resources":{}},"20-init-snapshot":{"__condition":"{{ .Pod.initSnapshot.enabled }}","image":"rclone/rclone:1.67.0","imagePullPolicy":"IfNotPresent","resources":{}}}` |
 | firehosePods.reader-node.initSnapshot.enabled |  | bool | `false` |
 | firehosePods.reader-node.initSnapshot.env.SNAPSHOT_REMOTE_LOCATION |  | string | `"add_snapshot_location"` |
 | firehosePods.reader-node.jwt | JWT for clients to authenticate with the Engine API. Specify either `existingSecret` OR `fromLiteral`. | object | `{"existingSecret":{"key":null,"name":null},"fromLiteral":"1ce5c87e81573667e685eae935d988a92742d5f466d696605cc207a36389c480"}` |
 | firehosePods.reader-node.jwt.existingSecret | Load the JWT from an existing Kubernetes Secret. Takes precedence over `fromLiteral` if set. | object | `{"key":null,"name":null}` |
 | firehosePods.reader-node.jwt.existingSecret.key | Data key for the JWT in the Secret | string | `nil` |
 | firehosePods.reader-node.jwt.existingSecret.name | Name of the Secret resource in the same namespace | string | `nil` |
 | firehosePods.reader-node.jwt.fromLiteral | Use this literal value for the JWT | string | `"1ce5c87e81573667e685eae935d988a92742d5f466d696605cc207a36389c480"` |
 | firehosePods.reader-node.kind |  | string | `"StatefulSet"` |
 | firehosePods.reader-node.lifecycle | Lifecycle hooks | object | `{"preStop":{"exec":{"command":["/usr/local/bin/eth-maintenance"]}}}` |
 | firehosePods.reader-node.nameOverride |  | string | `""` |
 | firehosePods.reader-node.node.args."authrpc.addr" |  | string | `"0.0.0.0"` |
 | firehosePods.reader-node.node.args."authrpc.jwtsecret" |  | string | `"/jwt/jwt.hex"` |
 | firehosePods.reader-node.node.args."authrpc.port" |  | int | `8551` |
 | firehosePods.reader-node.node.args."authrpc.vhosts" |  | string | `"*"` |
 | firehosePods.reader-node.node.args."discovery.port" |  | string | `"EXTERNAL_PORT"` |
 | firehosePods.reader-node.node.args."http.addr" |  | string | `"0.0.0.0"` |
 | firehosePods.reader-node.node.args."http.api" |  | string | `"net,web3,eth,debug"` |
 | firehosePods.reader-node.node.args."http.vhosts" |  | string | `"*"` |
 | firehosePods.reader-node.node.args."metrics.addr" |  | string | `"${NODE_DEPLOYMENT_METRICS_ADDR}"` |
 | firehosePods.reader-node.node.args."metrics.port" |  | string | `"${NODE_DEPLOYMENT_METRICS_PORT}"` |
 | firehosePods.reader-node.node.args.__prefix |  | string | `"--"` |
 | firehosePods.reader-node.node.args.__separator |  | string | `"="` |
 | firehosePods.reader-node.node.args.cache |  | int | `8192` |
 | firehosePods.reader-node.node.args.datadir |  | string | `"{node-data-dir}"` |
 | firehosePods.reader-node.node.args.firehose-enabled |  | string | `"__none"` |
 | firehosePods.reader-node.node.args.http |  | string | `"__none"` |
 | firehosePods.reader-node.node.args.maxpeers |  | int | `100` |
 | firehosePods.reader-node.node.args.nat |  | string | `"extip:EXTERNAL_IP"` |
 | firehosePods.reader-node.node.args.networkid |  | int | `11155111` |
 | firehosePods.reader-node.node.args.port |  | string | `"EXTERNAL_PORT"` |
 | firehosePods.reader-node.node.args.sepolia |  | string | `"__none"` |
 | firehosePods.reader-node.node.args.snapshot |  | string | `"true"` |
 | firehosePods.reader-node.node.args.syncmode |  | string | `"full"` |
 | firehosePods.reader-node.node.args.txlookuplimit |  | int | `1000` |
 | firehosePods.reader-node.node.metrics.__enabled |  | bool | `false` |
 | firehosePods.reader-node.node.metrics.addr |  | string | `"0.0.0.0"` |
 | firehosePods.reader-node.node.metrics.port |  | int | `6061` |
 | firehosePods.reader-node.nodePath |  | string | `"/usr/lib/geth"` |
 | firehosePods.reader-node.p2p.enabled | Expose P2P port via NodePort | bool | `false` |
 | firehosePods.reader-node.p2p.port | NodePort to be used. Must be unique. | int | `32310` |
 | firehosePods.reader-node.p2p.type |  | string | `"NodePort"` |
 | firehosePods.reader-node.p2pNodePort.enabled | Expose P2P port via NodePort | bool | `true` |
 | firehosePods.reader-node.p2pNodePort.initContainer.image.pullPolicy | Container pull policy | string | `"IfNotPresent"` |
 | firehosePods.reader-node.p2pNodePort.initContainer.image.repository | Container image to fetch nodeport information | string | `"lachlanevenson/k8s-kubectl"` |
 | firehosePods.reader-node.p2pNodePort.initContainer.image.tag | Container tag | string | `"v1.25.4"` |
 | firehosePods.reader-node.p2pNodePort.port | NodePort to be used. Must be unique. | int | `32310` |
 | firehosePods.reader-node.persistence | Persistence configuration | object | `{"enabled":true,"reader_node":{"accessModes":["ReadWriteOnce"],"resources":{"requests":{"storage":"3Ti"}},"storageClassName":"openebs-zfs-localpv-compressed-8k"}}` |
 | firehosePods.reader-node.persistence.reader_node.accessModes | Access modes for the persistent volume | list | `["ReadWriteOnce"]` |
 | firehosePods.reader-node.persistence.reader_node.resources.requests.storage | The amount of disk space to provision | string | `"3Ti"` |
 | firehosePods.reader-node.persistence.reader_node.storageClassName | The storage class to use when provisioning a persistent volume | string | `"openebs-zfs-localpv-compressed-8k"` |
 | firehosePods.reader-node.replicas |  | int | `1` |
 | firehosePods.reader-node.service.spec.ports.geth-auth.port |  | int | `8551` |
 | firehosePods.reader-node.service.spec.ports.geth-auth.protocol |  | string | `"TCP"` |
 | firehosePods.reader-node.service.spec.ports.metrics-geth.port |  | int | `6061` |
 | firehosePods.reader-node.service.spec.ports.metrics-geth.protocol |  | string | `"TCP"` |
 | firehosePods.reader-node.service.spec.ports.node-mgr.port |  | string | `"{{ splitList \":\" ( index .Pod.fireeth.config \"reader-node-manager-api-addr\" ) \| last }}"` |
 | firehosePods.reader-node.service.spec.ports.node-mgr.protocol |  | string | `"TCP"` |
 | firehosePods.reader-node.service.spec.ports.reader-grpc.port |  | int | `10010` |
 | firehosePods.reader-node.service.spec.ports.reader-grpc.protocol |  | string | `"TCP"` |
 | firehosePods.reader-node.serviceAccount | Service account configuration | object | `{"annotations":{},"create":true,"name":""}` |
 | firehosePods.reader-node.serviceAccount.annotations | Annotations to add to the service account | object | `{}` |
 | firehosePods.reader-node.serviceAccount.create | Specifies whether a service account should be created | bool | `true` |
 | firehosePods.reader-node.serviceAccount.name | The name of the service account to use. If not set and create is true, a name is generated using the fullname template | string | `""` |
 | firehosePods.relayer.enabled |  | bool | `true` |
 | firehosePods.relayer.fireeth.components[0] |  | string | `"relayer"` |
 | firehosePods.relayer.fireeth.config.relayer-grpc-listen-addr |  | string | `":10014"` |
 | firehosePods.relayer.fireeth.config.relayer-max-source-latency |  | string | `"1h"` |
 | firehosePods.relayer.fireeth.config.relayer-source |  | string | `"reader:10010"` |
 | firehosePods.relayer.fullnameOverride |  | string | `""` |
 | firehosePods.relayer.nameOverride |  | string | `""` |
 | firehosePods.relayer.replicas |  | int | `1` |
 | firehosePods.relayer.service | Service configuration | object | `{"enabled":true,"spec":{"ports":{"metrics-fh":{"containerPort":9102,"protocol":"TCP"},"relayer-grpc":{"containerPort":10014,"protocol":"TCP"}}}}` |
 | global.annotations | Global annotations added to all resources | object | `{}` |
 | global.fullnameOverride |  | string | `""` |
 | global.labels | Global labels added to all resources | object | `{}` |
 | global.nameOverride |  | string | `""` |

## Contributing

We welcome and appreciate your contributions! Please see the [Contributor Guide](/CONTRIBUTING.md), [Code Of Conduct](/CODE_OF_CONDUCT.md) and [Security Notes](/SECURITY.md) for this repository.
