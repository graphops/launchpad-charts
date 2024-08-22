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
 | common.env | Environment variables | object | `{"FIREETH_COMMON_LIVE_BLOCKS_ADDR":"relayer:10014","FIREETH_GLOBAL_DATA_DIR":"/var/lib/fireeth","FIREETH_GLOBAL_LOG_TO_FILE":"false","MANAGER_API_PORT":"10011"}` |
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
 | common.fireeth | Firehose-specific configuration | object | `{"args":{"-c":"__none","/config/config.yaml":"__none","start":"__none"},"argsOrder":["start","-c"],"config":{"common-index-block-sizes":10000,"data-dir":"/var/lib/fireeth","firehose-rate-limit-bucket-fill-rate":"1s","firehose-rate-limit-bucket-size":20,"metrics-listen-addr":"{{ with .Pod.fireeth.metrics }}{{ .enabled \| ternary (printf \"%s:%d\" .addr ( .port \| int ) ) nil }}{{ end }}"},"metrics":{"addr":"0.0.0.0","enabled":true,"port":9102},"pprof":{"addr":"localhost","enabled":false,"port":6060}}` |
 | common.horizontalPodAutoscaler | Horizontal Pod Autoscaler configuration | object | `{"enabled":false}` |
 | common.image | Image configuration for firehose-evm | object | `{"digest":"","pullPolicy":"IfNotPresent","repository":"ghcr.io/streamingfast/firehose-ethereum","tag":"v2.6.7-geth-v1.13.15-fh2.4"}` |
 | common.image.digest | Overrides the image reference using a specific digest | string | `""` |
 | common.image.pullPolicy | Image pull policy | string | `"IfNotPresent"` |
 | common.image.repository | Docker image repository | string | `"ghcr.io/streamingfast/firehose-ethereum"` |
 | common.image.tag | Overrides the image reference using a tag digest takes precedence over tag if both are set | string | `"v2.6.7-geth-v1.13.15-fh2.4"` |
 | common.imagePullSecrets | Pull secrets required to fetch images | list | `[]` |
 | common.initContainers | Init containers configuration | object | `{}` |
 | common.labels | Component level labels (templated) | object | `{"app.kubernetes.io/component":"{{ .componentName }}","app.kubernetes.io/part-of":"{{ .Root.Release.Name }}","version.firehose.graphops.xyz/fireeth":"2.6.7","version.firehose.graphops.xyz/node":"1.13.15","version.firehose.graphops.xyz/protocol":"2.4"}` |
 | common.lifecycle | Lifecycle hooks | object | `{}` |
 | common.nodeSelector | Node selector configuration | object | `{}` |
 | common.persistence | Persistence configuration | object | `{"accessModes":["ReadWriteOnce"],"enabled":true,"size":"50Gi","storageClassName":"openebs-zfs-localpv-compressed-128k"}` |
 | common.persistence.accessModes | Access modes for the persistent volume | list | `["ReadWriteOnce"]` |
 | common.persistence.enabled | Enable persistent storage | bool | `true` |
 | common.persistence.size | Size of the persistent volume | string | `"50Gi"` |
 | common.persistence.storageClassName | Storage class name | string | `"openebs-zfs-localpv-compressed-128k"` |
 | common.podDisruptionBudget | Pod Disruption Budget configuration | object | `{"enabled":false}` |
 | common.podSecurityContext | Pod-wide security context | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":true,"runAsNonRoot":true,"runAsUser":1000}` |
 | common.resources | Resource requests and limits | object | `{}` |
 | common.securityContext | Container level security context overrides | object | `{}` |
 | common.service | Service configuration | object | `{"annotations":{},"enabled":true,"labels":{},"ports":{"metrics-fh":{"port":9102,"protocol":"TCP"},"node-mgr":{"port":10011,"protocol":"TCP"}},"type":"ClusterIP"}` |
 | common.service.annotations | Additional service annotations | object | `{}` |
 | common.service.labels | Additional service labels | object | `{}` |
 | common.service.ports | Service ports configuration | object | `{"metrics-fh":{"port":9102,"protocol":"TCP"},"node-mgr":{"port":10011,"protocol":"TCP"}}` |
 | common.service.type | Service type | string | `"ClusterIP"` |
 | common.serviceAccount | Service account configuration | object | `{"annotations":{},"create":true,"labels":{},"name":"","rbac":{"clusterWide":false,"create":true,"rules":[]}}` |
 | common.serviceAccount.annotations | Annotations to add to the service account | object | `{}` |
 | common.serviceAccount.create | Specifies whether a service account should be created | bool | `true` |
 | common.serviceAccount.labels | Labels to add to the service account | object | `{}` |
 | common.serviceAccount.name | The name of the service account to use. If not set and create is true, a name is generated using the fullname template | string | `""` |
 | common.serviceMonitor | ServiceMonitor configuration for Prometheus Operator | object | `{"enabled":true,"spec":{"endpoints":{"metrics-fh":{"honorLabels":true,"interval":"60s","scrapeTimeout":"10s"}}}}` |
 | common.serviceMonitor.enabled | Enable monitoring by creating `ServiceMonitor` CRDs ([prometheus-operator](https://github.com/prometheus-operator/prometheus-operator)) | bool | `true` |
 | common.terminationGracePeriodSeconds | Amount of time to wait before force-killing the process | int | `10` |
 | common.tolerations | Tolerations configuration | list | `[]` |
 | common.topologySpreadConstraints | Topology spread constraints | list | `[]` |
 | global.annotations | Global annotations added to all resources | object | `{}` |
 | global.fullnameOverride |  | string | `""` |
 | global.labels | Global labels added to all resources | object | `{}` |
 | global.nameOverride |  | string | `""` |
 | grpc.affinity | Affinity configuration | object | `{}` |
 | grpc.annotations | Component level annotations (templated) | object | `{}` |
 | grpc.configMap.enabled |  | bool | `true` |
 | grpc.enabled |  | bool | `true` |
 | grpc.env | Environment variables | object | `{}` |
 | grpc.envFromConfigmap | Environment variables from ConfigMaps | object | `{}` |
 | grpc.existingConfigMap |  | string | `""` |
 | grpc.extraContainers | Extra containers to add to the pod (templated) | object | `{}` |
 | grpc.extraVolumeMounts |  | object | `{}` |
 | grpc.extraVolumes | Extra volumes to add to the pod (templated) | list | `[]` |
 | grpc.fireeth | Firehose-specific configuration | object | `{"config":{"firehose-grpc-listen-addr":":10015"}}` |
 | grpc.fullnameOverride |  | string | `""` |
 | grpc.horizontalPodAutoscaler | Horizontal Pod Autoscaler configuration | object | `{}` |
 | grpc.image | Image configuration for firehose-evm | object | `{}` |
 | grpc.imagePullSecrets | Pull secrets required to fetch images | list | `[]` |
 | grpc.initContainers | Init containers configuration | object | `{}` |
 | grpc.labels | Component level labels (templated) | object | `{}` |
 | grpc.lifecycle | Lifecycle hooks | object | `{}` |
 | grpc.nameOverride |  | string | `""` |
 | grpc.nodeSelector | Node selector configuration | object | `{}` |
 | grpc.persistence | Persistence configuration | object | `{}` |
 | grpc.podDisruptionBudget | Pod Disruption Budget configuration | object | `{}` |
 | grpc.podSecurityContext | Pod-wide security context | object | `{}` |
 | grpc.replicas |  | int | `1` |
 | grpc.resources | Resource requests and limits | object | `{}` |
 | grpc.secretEnv | Environment variables from secrets | object | `{}` |
 | grpc.securityContext | Container level security context overrides | object | `{}` |
 | grpc.service | Service configuration | object | `{"ports":[{"containerPort":10015,"name":"grpc","protocol":"TCP"},{"containerPort":9102,"name":"metrics-fh","protocol":"TCP"}],"type":"ClusterIP"}` |
 | grpc.serviceAccount | Service account configuration | object | `{}` |
 | grpc.serviceMonitor | ServiceMonitor configuration for Prometheus Operator | object | `{}` |
 | grpc.terminationGracePeriodSeconds | Amount of time to wait before force-killing the process | object | `{}` |
 | grpc.tolerations | Tolerations configuration | list | `[]` |
 | grpc.topologySpreadConstraints | Topology spread constraints | list | `[]` |
 | index-builder.affinity | Affinity configuration | object | `{}` |
 | index-builder.annotations | Component level annotations (templated) | object | `{}` |
 | index-builder.config.index-builder-grpc-listen-addr |  | string | `":10009"` |
 | index-builder.config.index-builder-index-size |  | string | `"1000"` |
 | index-builder.configMap.enabled |  | bool | `true` |
 | index-builder.enabled |  | bool | `false` |
 | index-builder.env | Environment variables | object | `{}` |
 | index-builder.envFromConfigmap | Environment variables from ConfigMaps | object | `{}` |
 | index-builder.extraContainers | Extra containers to add to the pod (templated) | object | `{}` |
 | index-builder.extraVolumeMounts |  | object | `{}` |
 | index-builder.extraVolumes | Extra volumes to add to the pod (templated) | list | `[]` |
 | index-builder.fireeth | Firehose-specific configuration | object | `{}` |
 | index-builder.fullnameOverride |  | string | `""` |
 | index-builder.horizontalPodAutoscaler | Horizontal Pod Autoscaler configuration | object | `{}` |
 | index-builder.image | Image configuration for firehose-evm | object | `{"pullPolicy":"IfNotPresent","repository":"ghcr.io/streamingfast/firehose-ethereum","tag":""}` |
 | index-builder.image.tag | Overrides the image tag | string | Chart.appVersion |
 | index-builder.imagePullSecrets | Pull secrets required to fetch images | list | `[]` |
 | index-builder.initContainers | Init containers configuration | object | `{}` |
 | index-builder.labels | Component level labels (templated) | object | `{}` |
 | index-builder.lifecycle | Lifecycle hooks | object | `{}` |
 | index-builder.nameOverride |  | string | `""` |
 | index-builder.nodeSelector | Node selector configuration | object | `{}` |
 | index-builder.persistence | Persistence configuration | object | `{"accessModes":["ReadWriteOnce"],"resources":{"requests":{"storage":"50Gi"}},"storageClassName":"openebs-zfs-localpv-compressed-128k"}` |
 | index-builder.persistence.resources.requests.storage | The amount of disk space to provision | string | `"50Gi"` |
 | index-builder.persistence.storageClassName | The storage class to use when provisioning a persistent volume | string | `"openebs-zfs-localpv-compressed-128k"` |
 | index-builder.podDisruptionBudget | Pod Disruption Budget configuration | object | `{}` |
 | index-builder.podSecurityContext | Pod-wide security context | object | `{}` |
 | index-builder.resources | Resource requests and limits | object | `{}` |
 | index-builder.secretEnv | Environment variables from secrets | object | `{}` |
 | index-builder.securityContext | Container level security context overrides | object | `{}` |
 | index-builder.service | Service configuration | object | `{"ports":[{"containerPort":10009,"name":"indexer-grpc","protocol":"TCP"},{"containerPort":9102,"name":"metrics-fh","protocol":"TCP"}],"type":"ClusterIP"}` |
 | index-builder.serviceAccount | Service account configuration | object | `{"annotations":{},"create":true,"name":""}` |
 | index-builder.serviceAccount.annotations | Annotations to add to the service account | object | `{}` |
 | index-builder.serviceAccount.create | Specifies whether a service account should be created | bool | `true` |
 | index-builder.serviceAccount.name | The name of the service account to use. If not set and create is true, a name is generated using the fullname template | string | `""` |
 | index-builder.serviceMonitor | ServiceMonitor configuration for Prometheus Operator | object | `{"enabled":true}` |
 | index-builder.terminationGracePeriodSeconds | Amount of time to wait before force-killing the process | int | `10` |
 | index-builder.tolerations | Tolerations configuration | list | `[]` |
 | index-builder.topologySpreadConstraints | Topology spread constraints | list | `[]` |
 | merger.affinity | Affinity configuration | object | `{}` |
 | merger.annotations | Component level annotations (templated) | object | `{}` |
 | merger.config.merger-grpc-listen-addr |  | string | `":10012"` |
 | merger.configMap.enabled |  | bool | `true` |
 | merger.enabled |  | bool | `false` |
 | merger.env | Environment variables | object | `{}` |
 | merger.envFromConfigmap | Environment variables from ConfigMaps | object | `{}` |
 | merger.extraContainers | Extra containers to add to the pod (templated) | object | `{}` |
 | merger.extraVolumeMounts |  | object | `{}` |
 | merger.extraVolumes | Extra volumes to add to the pod (templated) | list | `[]` |
 | merger.fireeth | Firehose-specific configuration | object | `{}` |
 | merger.fullnameOverride |  | string | `""` |
 | merger.horizontalPodAutoscaler | Horizontal Pod Autoscaler configuration | object | `{}` |
 | merger.image | Image configuration for firehose-evm | object | `{"pullPolicy":"IfNotPresent","repository":"ghcr.io/streamingfast/firehose-ethereum","tag":""}` |
 | merger.image.tag | Overrides the image tag | string | Chart.appVersion |
 | merger.imagePullSecrets | Pull secrets required to fetch images | list | `[]` |
 | merger.initContainers | Init containers configuration | object | `{}` |
 | merger.labels | Component level labels (templated) | object | `{}` |
 | merger.lifecycle | Lifecycle hooks | object | `{}` |
 | merger.nameOverride |  | string | `""` |
 | merger.nodeSelector | Node selector configuration | object | `{}` |
 | merger.persistence | Persistence configuration | object | `{"accessModes":["ReadWriteOnce"],"resources":{"requests":{"storage":"50Gi"}},"storageClassName":"openebs-zfs-localpv-compressed-128k"}` |
 | merger.persistence.resources.requests.storage | The amount of disk space to provision | string | `"50Gi"` |
 | merger.persistence.storageClassName | The storage class to use when provisioning a persistent volume | string | `"openebs-zfs-localpv-compressed-128k"` |
 | merger.podDisruptionBudget | Pod Disruption Budget configuration | object | `{}` |
 | merger.podSecurityContext | Pod-wide security context | object | `{}` |
 | merger.resources | Resource requests and limits | object | `{}` |
 | merger.secretEnv | Environment variables from secrets | object | `{}` |
 | merger.securityContext | Container level security context overrides | object | `{}` |
 | merger.service | Service configuration | object | `{"ports":[{"containerPort":10012,"name":"merger-grpc","protocol":"TCP"},{"containerPort":9102,"name":"metrics-fh","protocol":"TCP"}],"type":"ClusterIP"}` |
 | merger.serviceAccount | Service account configuration | object | `{"annotations":{},"create":true,"name":""}` |
 | merger.serviceAccount.annotations | Annotations to add to the service account | object | `{}` |
 | merger.serviceAccount.create | Specifies whether a service account should be created | bool | `true` |
 | merger.serviceAccount.name | The name of the service account to use. If not set and create is true, a name is generated using the fullname template | string | `""` |
 | merger.serviceMonitor | ServiceMonitor configuration for Prometheus Operator | object | `{"enabled":true}` |
 | merger.terminationGracePeriodSeconds | Amount of time to wait before force-killing the process | int | `10` |
 | merger.tolerations | Tolerations configuration | list | `[]` |
 | merger.topologySpreadConstraints | Topology spread constraints | list | `[]` |
 | reader-node.affinity | Affinity configuration | object | `{}` |
 | reader-node.annotations | Component level annotations (templated) | object | `{}` |
 | reader-node.config.reader-node-data-dir |  | string | `"/var/lib/geth"` |
 | reader-node.config.reader-node-grpc-listen-addr |  | string | `":10010"` |
 | reader-node.config.reader-node-manager-api-addr |  | string | `":10011"` |
 | reader-node.config.reader-node-path |  | string | `"/app/geth"` |
 | reader-node.configMap.enabled |  | bool | `true` |
 | reader-node.dataDir |  | string | `"/var/lib/geth"` |
 | reader-node.enabled |  | bool | `false` |
 | reader-node.env | Environment variables | object | `{"FIREETH_READER_NODE_LOG_TO_ZAP":"false"}` |
 | reader-node.envFromConfigmap | Environment variables from ConfigMaps | object | `{}` |
 | reader-node.extraContainers | Extra containers to add to the pod (templated) | object | `{}` |
 | reader-node.extraVolumeMounts |  | object | `{}` |
 | reader-node.extraVolumes | Extra volumes to add to the pod (templated) | list | `[]` |
 | reader-node.fireeth | Firehose-specific configuration | object | `{}` |
 | reader-node.fullnameOverride |  | string | `""` |
 | reader-node.horizontalPodAutoscaler | Horizontal Pod Autoscaler configuration | object | `{}` |
 | reader-node.image | Image configuration for firehose-evm | object | `{"pullPolicy":"IfNotPresent","repository":"ghcr.io/streamingfast/firehose-ethereum","tag":""}` |
 | reader-node.image.tag | Overrides the image tag | string | Chart.appVersion |
 | reader-node.imagePullSecrets | Pull secrets required to fetch images | list | `[]` |
 | reader-node.initContainers | Init containers configuration | object | `{"10-init-nodeport":{"__condition":"{{ .Pod.p2p.enabled }}","image":"lachlanevenson/k8s-kubectl:v1.25.4","imagePullPolicy":"IfNotPresent","resources":{}},"20-init-snapshot":{"__condition":"{{ .Pod.initSnapshot.enabled }}","image":"rclone/rclone:1.67.0","imagePullPolicy":"IfNotPresent","resources":{}}}` |
 | reader-node.initSnapshot.enabled |  | bool | `false` |
 | reader-node.initSnapshot.env.SNAPSHOT_REMOTE_LOCATION |  | string | `"add_snapshot_location"` |
 | reader-node.jwt | JWT for clients to authenticate with the Engine API. Specify either `existingSecret` OR `fromLiteral`. | object | `{"existingSecret":{"key":null,"name":null},"fromLiteral":"1ce5c87e81573667e685eae935d988a92742d5f466d696605cc207a36389c480"}` |
 | reader-node.jwt.existingSecret | Load the JWT from an existing Kubernetes Secret. Takes precedence over `fromLiteral` if set. | object | `{"key":null,"name":null}` |
 | reader-node.jwt.existingSecret.key | Data key for the JWT in the Secret | string | `nil` |
 | reader-node.jwt.existingSecret.name | Name of the Secret resource in the same namespace | string | `nil` |
 | reader-node.jwt.fromLiteral | Use this literal value for the JWT | string | `"1ce5c87e81573667e685eae935d988a92742d5f466d696605cc207a36389c480"` |
 | reader-node.labels | Component level labels (templated) | object | `{}` |
 | reader-node.lifecycle | Lifecycle hooks | object | `{"preStop":{"exec":{"command":["/usr/local/bin/eth-maintenance"]}}}` |
 | reader-node.nameOverride |  | string | `""` |
 | reader-node.node.args."authrpc.addr" |  | string | `"0.0.0.0"` |
 | reader-node.node.args."authrpc.jwtsecret" |  | string | `"/jwt/jwt.hex"` |
 | reader-node.node.args."authrpc.port" |  | int | `8551` |
 | reader-node.node.args."authrpc.vhosts" |  | string | `"*"` |
 | reader-node.node.args."discovery.port" |  | string | `"EXTERNAL_PORT"` |
 | reader-node.node.args."http.addr" |  | string | `"0.0.0.0"` |
 | reader-node.node.args."http.api" |  | string | `"net,web3,eth,debug"` |
 | reader-node.node.args."http.vhosts" |  | string | `"*"` |
 | reader-node.node.args."metrics.addr" |  | string | `"${NODE_DEPLOYMENT_METRICS_ADDR}"` |
 | reader-node.node.args."metrics.port" |  | string | `"${NODE_DEPLOYMENT_METRICS_PORT}"` |
 | reader-node.node.args.cache |  | int | `8192` |
 | reader-node.node.args.datadir |  | string | `"{node-data-dir}"` |
 | reader-node.node.args.firehose-enabled |  | string | `"__none"` |
 | reader-node.node.args.http |  | string | `"__none"` |
 | reader-node.node.args.maxpeers |  | int | `100` |
 | reader-node.node.args.nat |  | string | `"extip:EXTERNAL_IP"` |
 | reader-node.node.args.networkid |  | int | `11155111` |
 | reader-node.node.args.port |  | string | `"EXTERNAL_PORT"` |
 | reader-node.node.args.sepolia |  | string | `"__none"` |
 | reader-node.node.args.snapshot |  | string | `"true"` |
 | reader-node.node.args.syncmode |  | string | `"full"` |
 | reader-node.node.args.txlookuplimit |  | int | `1000` |
 | reader-node.node.metrics.__enabled |  | bool | `false` |
 | reader-node.node.metrics.addr |  | string | `"0.0.0.0"` |
 | reader-node.node.metrics.port |  | int | `6061` |
 | reader-node.nodePath |  | string | `"/usr/lib/geth"` |
 | reader-node.nodeSelector | Node selector configuration | object | `{}` |
 | reader-node.p2p.enabled | Expose P2P port via NodePort | bool | `false` |
 | reader-node.p2p.port | NodePort to be used. Must be unique. | int | `32310` |
 | reader-node.p2p.type |  | string | `"NodePort"` |
 | reader-node.p2pNodePort.enabled | Expose P2P port via NodePort | bool | `true` |
 | reader-node.p2pNodePort.initContainer.image.pullPolicy | Container pull policy | string | `"IfNotPresent"` |
 | reader-node.p2pNodePort.initContainer.image.repository | Container image to fetch nodeport information | string | `"lachlanevenson/k8s-kubectl"` |
 | reader-node.p2pNodePort.initContainer.image.tag | Container tag | string | `"v1.25.4"` |
 | reader-node.p2pNodePort.port | NodePort to be used. Must be unique. | int | `32310` |
 | reader-node.persistence | Persistence configuration | object | `{"reader_node":{"accessModes":["ReadWriteOnce"],"resources":{"requests":{"storage":"3Ti"}},"storageClassName":"openebs-zfs-localpv-compressed-8k"}}` |
 | reader-node.persistence.reader_node.accessModes | Access modes for the persistent volume | list | `["ReadWriteOnce"]` |
 | reader-node.persistence.reader_node.resources.requests.storage | The amount of disk space to provision | string | `"3Ti"` |
 | reader-node.persistence.reader_node.storageClassName | The storage class to use when provisioning a persistent volume | string | `"openebs-zfs-localpv-compressed-8k"` |
 | reader-node.podDisruptionBudget | Pod Disruption Budget configuration | object | `{}` |
 | reader-node.podSecurityContext | Pod-wide security context | object | `{}` |
 | reader-node.replicas |  | int | `1` |
 | reader-node.resources | Resource requests and limits | object | `{}` |
 | reader-node.secretEnv | Environment variables from secrets | object | `{}` |
 | reader-node.securityContext | Container level security context overrides | object | `{}` |
 | reader-node.service | Service configuration | object | `{"ports":{"geth-auth":{"port":8551,"protocol":"TCP"},"metrics-geth":{"port":6061,"protocol":"TCP"},"node-mgr":{"port":10011,"protocol":"TCP"},"reader-grpc":{"port":10010,"protocol":"TCP"}},"type":"ClusterIP"}` |
 | reader-node.serviceAccount | Service account configuration | object | `{"annotations":{},"create":true,"name":""}` |
 | reader-node.serviceAccount.annotations | Annotations to add to the service account | object | `{}` |
 | reader-node.serviceAccount.create | Specifies whether a service account should be created | bool | `true` |
 | reader-node.serviceAccount.name | The name of the service account to use. If not set and create is true, a name is generated using the fullname template | string | `""` |
 | reader-node.serviceMonitor | ServiceMonitor configuration for Prometheus Operator | object | `{}` |
 | reader-node.terminationGracePeriodSeconds | Amount of time to wait before force-killing the process | int | `10` |
 | reader-node.tolerations | Tolerations configuration | list | `[]` |
 | reader-node.topologySpreadConstraints | Topology spread constraints | list | `[]` |
 | relayer.affinity | Affinity configuration | object | `{}` |
 | relayer.annotations | Component level annotations (templated) | object | `{}` |
 | relayer.config.relayer-grpc-listen-addr |  | string | `":10014"` |
 | relayer.config.relayer-max-source-latency |  | string | `"1h"` |
 | relayer.config.relayer-source |  | string | `"reader:10010"` |
 | relayer.configMap.enabled |  | bool | `true` |
 | relayer.enabled |  | bool | `false` |
 | relayer.env | Environment variables | object | `{}` |
 | relayer.envFromConfigmap | Environment variables from ConfigMaps | object | `{}` |
 | relayer.extraContainers | Extra containers to add to the pod (templated) | object | `{}` |
 | relayer.extraVolumeMounts |  | object | `{}` |
 | relayer.extraVolumes | Extra volumes to add to the pod (templated) | list | `[]` |
 | relayer.fireeth | Firehose-specific configuration | object | `{}` |
 | relayer.fullnameOverride |  | string | `""` |
 | relayer.horizontalPodAutoscaler | Horizontal Pod Autoscaler configuration | object | `{}` |
 | relayer.image | Image configuration for firehose-evm | object | `{"pullPolicy":"IfNotPresent","repository":"ghcr.io/streamingfast/firehose-ethereum","tag":""}` |
 | relayer.image.tag | Overrides the image tag | string | Chart.appVersion |
 | relayer.imagePullSecrets | Pull secrets required to fetch images | list | `[]` |
 | relayer.initContainers | Init containers configuration | object | `{}` |
 | relayer.labels | Component level labels (templated) | object | `{}` |
 | relayer.lifecycle | Lifecycle hooks | object | `{}` |
 | relayer.nameOverride |  | string | `""` |
 | relayer.nodeSelector | Node selector configuration | object | `{}` |
 | relayer.persistence | Persistence configuration | object | `{"accessModes":["ReadWriteOnce"],"resources":{"requests":{"storage":"50Gi"}},"storageClassName":"openebs-zfs-localpv-compressed-128k"}` |
 | relayer.persistence.resources.requests.storage | The amount of disk space to provision | string | `"50Gi"` |
 | relayer.persistence.storageClassName | The storage class to use when provisioning a persistent volume | string | `"openebs-zfs-localpv-compressed-128k"` |
 | relayer.podDisruptionBudget | Pod Disruption Budget configuration | object | `{}` |
 | relayer.podSecurityContext | Pod-wide security context | object | `{}` |
 | relayer.replicas |  | int | `1` |
 | relayer.resources | Resource requests and limits | object | `{}` |
 | relayer.secretEnv | Environment variables from secrets | object | `{}` |
 | relayer.securityContext | Container level security context overrides | object | `{}` |
 | relayer.service | Service configuration | object | `{"ports":[{"containerPort":10014,"name":"relayer-grpc","protocol":"TCP"},{"containerPort":9102,"name":"metrics-fh","protocol":"TCP"}],"type":"ClusterIP"}` |
 | relayer.serviceAccount | Service account configuration | object | `{"annotations":{},"create":true,"name":""}` |
 | relayer.serviceAccount.annotations | Annotations to add to the service account | object | `{}` |
 | relayer.serviceAccount.create | Specifies whether a service account should be created | bool | `true` |
 | relayer.serviceAccount.name | The name of the service account to use. If not set and create is true, a name is generated using the fullname template | string | `""` |
 | relayer.serviceMonitor | ServiceMonitor configuration for Prometheus Operator | object | `{"enabled":true}` |
 | relayer.terminationGracePeriodSeconds | Amount of time to wait before force-killing the process | int | `10` |
 | relayer.tolerations | Tolerations configuration | list | `[]` |
 | relayer.topologySpreadConstraints | Topology spread constraints | list | `[]` |

## Contributing

We welcome and appreciate your contributions! Please see the [Contributor Guide](/CONTRIBUTING.md), [Code Of Conduct](/CODE_OF_CONDUCT.md) and [Security Notes](/SECURITY.md) for this repository.
