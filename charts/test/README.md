# firehose-evm

![Version: 0.0.0](https://img.shields.io/badge/Version-0.0.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v2.6.7](https://img.shields.io/badge/AppVersion-v2.6.7-informational?style=flat-square)

Deploy and scale all components of [Firehose EVM](https://github.com/streamingfast/firehose-ethereum) inside Kubernetes with ease

## Values

| Key | Description | Type | Default |
|-----|-------------|------|---------|
 | common.env.FIREETH_COMMON_LIVE_BLOCKS_ADDR |  | string | `"relayer:10014"` |
 | common.env.FIREETH_GLOBAL_DATA_DIR |  | string | `"/var/lib/fireeth"` |
 | common.env.FIREETH_GLOBAL_LOG_TO_FILE |  | string | `"false"` |
 | common.env.MANAGER_API_PORT |  | string | `"10011"` |
 | common.secretEnv | Environment variable defaults that come from secret | object | `{"FIREETH_COMMON_FORKED_BLOCKS_STORE_URL":{"key":null,"secretName":null},"FIREETH_COMMON_INDEX_STORE_URL":{"key":null,"secretName":null},"FIREETH_COMMON_MERGED_BLOCKS_STORE_URL":{"key":null,"secretName":null},"FIREETH_COMMON_ONE_BLOCK_STORE_URL":{"key":null,"secretName":null}}` |
 | common.secretEnv.FIREETH_COMMON_FORKED_BLOCKS_STORE_URL.key | Name of the data key in the secret that contains your S3 bucket url for storing forked blocks  | string | `nil` |
 | common.secretEnv.FIREETH_COMMON_FORKED_BLOCKS_STORE_URL.secretName | Name of the secret that contains your S3 bucket url for storing forked blocks  | string | `nil` |
 | common.secretEnv.FIREETH_COMMON_INDEX_STORE_URL.key | Name of the data key in the secret that contains your S3 bucket url of your index store | string | `nil` |
 | common.secretEnv.FIREETH_COMMON_INDEX_STORE_URL.secretName | Name of the secret that contains your S3 bucket url of your index store | string | `nil` |
 | common.secretEnv.FIREETH_COMMON_MERGED_BLOCKS_STORE_URL.key | Name of the data key in the secret that contains your S3 bucket url for storing merged blocks  | string | `nil` |
 | common.secretEnv.FIREETH_COMMON_MERGED_BLOCKS_STORE_URL.secretName | Name of the secret that contains your S3 bucket url for storing merged blocks  | string | `nil` |
 | common.secretEnv.FIREETH_COMMON_ONE_BLOCK_STORE_URL.key | Name of the data key in the secret that contains your S3 bucket url for storing one blocks  | string | `nil` |
 | common.secretEnv.FIREETH_COMMON_ONE_BLOCK_STORE_URL.secretName | Name of the secret that contains your S3 bucket url for storing one blocks  | string | `nil` |
 | config.common-index-block-sizes |  | int | `10000` |
 | config.data-dir |  | string | `"/var/lib/fireeth"` |
 | config.firehose-rate-limit-bucket-fill-rate |  | string | `"1s"` |
 | config.firehose-rate-limit-bucket-size |  | int | `20` |
 | config.metrics-listen-addr |  | string | `":9102"` |
 | configTemplate |  | string | `"{{- range $key, $value := . }}\n{{ $key }}: \"{{ $value }}\"\n{{- end }}\n"` |
 | grpc.affinity |  | object | `{}` |
 | grpc.config.firehose-grpc-listen-addr |  | string | `":10015"` |
 | grpc.configMap.enabled |  | bool | `true` |
 | grpc.enabled |  | bool | `true` |
 | grpc.env |  | object | `{}` |
 | grpc.existingConfigMap |  | string | `""` |
 | grpc.extraArgs | Additional CLI arguments to pass to `indexer-agent` | list | `[]` |
 | grpc.fullnameOverride |  | string | `""` |
 | grpc.image | Image for firehose-evm | object | `{"pullPolicy":"IfNotPresent","repository":"ghcr.io/streamingfast/firehose-ethereum","tag":""}` |
 | grpc.image.tag | Overrides the image tag | string | Chart.appVersion |
 | grpc.imagePullSecrets | Pull secrets required to fetch the Image | list | `[]` |
 | grpc.nameOverride |  | string | `""` |
 | grpc.nodeSelector |  | object | `{}` |
 | grpc.podAnnotations | Annotations for the `Pod` | object | `{}` |
 | grpc.podSecurityContext | Pod-wide security context | object | `{}` |
 | grpc.prometheus.serviceMonitors.enabled |  | bool | `true` |
 | grpc.replicas |  | int | `1` |
 | grpc.resources |  | object | `{}` |
 | grpc.secretEnv |  | object | `{}` |
 | grpc.service.ports[0].containerPort |  | int | `10015` |
 | grpc.service.ports[0].name |  | string | `"grpc"` |
 | grpc.service.ports[0].protocol |  | string | `"TCP"` |
 | grpc.service.ports[1].containerPort |  | int | `9102` |
 | grpc.service.ports[1].name |  | string | `"metrics-fh"` |
 | grpc.service.ports[1].protocol |  | string | `"TCP"` |
 | grpc.service.type |  | string | `"ClusterIP"` |
 | grpc.serviceAccount.annotations | Annotations to add to the service account | object | `{}` |
 | grpc.serviceAccount.create | Specifies whether a service account should be created | bool | `true` |
 | grpc.serviceAccount.name | The name of the service account to use. If not set and create is true, a name is generated using the fullname template | string | `""` |
 | grpc.terminationGracePeriodSeconds | Amount of time to wait before force-killing the process | int | `10` |
 | grpc.tolerations |  | list | `[]` |
 | grpc.volumeClaimSpec.accessModes[0] |  | string | `"ReadWriteOnce"` |
 | grpc.volumeClaimSpec.resources.requests.storage | The amount of disk space to provision | string | `"50Gi"` |
 | grpc.volumeClaimSpec.storageClassName | The storage class to use when provisioning a persistent volume | string | `"openebs-zfs-localpv-compressed-128k"` |
 | image | Image for firehose-evm | object | `{"digest":"","labels":{"firehose":"v2.6.7","node":"v1.13.15","protocol":"2.4"},"pullPolicy":"IfNotPresent","repository":"ghcr.io/streamingfast/firehose-ethereum","tag":"v2.6.7-geth-v1.13.15-fh2.4"}` |
 | image.labels | Image related labels | object | `{"firehose":"v2.6.7","node":"v1.13.15","protocol":"2.4"}` |
 | image.tag | Overrides the image reference digest takes precedence over tag if both are set | string | `"v2.6.7-geth-v1.13.15-fh2.4"` |
 | indexer.affinity |  | object | `{}` |
 | indexer.config.index-builder-grpc-listen-addr |  | string | `":10009"` |
 | indexer.config.index-builder-index-size |  | string | `"1000"` |
 | indexer.configMap.enabled |  | bool | `true` |
 | indexer.enabled |  | bool | `true` |
 | indexer.env |  | object | `{}` |
 | indexer.extraArgs | Additional CLI arguments to pass to `indexer-agent` | list | `[]` |
 | indexer.fullnameOverride |  | string | `""` |
 | indexer.image | Image for firehose-evm | object | `{"pullPolicy":"IfNotPresent","repository":"ghcr.io/streamingfast/firehose-ethereum","tag":""}` |
 | indexer.image.tag | Overrides the image tag | string | Chart.appVersion |
 | indexer.imagePullSecrets | Pull secrets required to fetch the Image | list | `[]` |
 | indexer.nameOverride |  | string | `""` |
 | indexer.nodeSelector |  | object | `{}` |
 | indexer.podAnnotations | Annotations for the `Pod` | object | `{}` |
 | indexer.podSecurityContext | Pod-wide security context | object | `{}` |
 | indexer.prometheus.serviceMonitors.enabled |  | bool | `true` |
 | indexer.resources |  | object | `{}` |
 | indexer.secretEnv |  | object | `{}` |
 | indexer.service.ports[0].containerPort |  | int | `10009` |
 | indexer.service.ports[0].name |  | string | `"indexer-grpc"` |
 | indexer.service.ports[0].protocol |  | string | `"TCP"` |
 | indexer.service.ports[1].containerPort |  | int | `9102` |
 | indexer.service.ports[1].name |  | string | `"metrics-fh"` |
 | indexer.service.ports[1].protocol |  | string | `"TCP"` |
 | indexer.service.type |  | string | `"ClusterIP"` |
 | indexer.serviceAccount.annotations | Annotations to add to the service account | object | `{}` |
 | indexer.serviceAccount.create | Specifies whether a service account should be created | bool | `true` |
 | indexer.serviceAccount.name | The name of the service account to use. If not set and create is true, a name is generated using the fullname template | string | `""` |
 | indexer.terminationGracePeriodSeconds | Amount of time to wait before force-killing the process | int | `10` |
 | indexer.tolerations |  | list | `[]` |
 | indexer.volumeClaimSpec.accessModes[0] |  | string | `"ReadWriteOnce"` |
 | indexer.volumeClaimSpec.resources.requests.storage | The amount of disk space to provision | string | `"50Gi"` |
 | indexer.volumeClaimSpec.storageClassName | The storage class to use when provisioning a persistent volume | string | `"openebs-zfs-localpv-compressed-128k"` |
 | merger.affinity |  | object | `{}` |
 | merger.config.merger-grpc-listen-addr |  | string | `":10012"` |
 | merger.configMap.enabled |  | bool | `true` |
 | merger.enabled |  | bool | `true` |
 | merger.env |  | object | `{}` |
 | merger.extraArgs | Additional CLI arguments to pass to `indexer-agent` | list | `[]` |
 | merger.fullnameOverride |  | string | `""` |
 | merger.image | Image for firehose-evm | object | `{"pullPolicy":"IfNotPresent","repository":"ghcr.io/streamingfast/firehose-ethereum","tag":""}` |
 | merger.image.tag | Overrides the image tag | string | Chart.appVersion |
 | merger.imagePullSecrets | Pull secrets required to fetch the Image | list | `[]` |
 | merger.nameOverride |  | string | `""` |
 | merger.nodeSelector |  | object | `{}` |
 | merger.podAnnotations | Annotations for the `Pod` | object | `{}` |
 | merger.podSecurityContext | Pod-wide security context | object | `{}` |
 | merger.prometheus.serviceMonitors.enabled |  | bool | `true` |
 | merger.resources |  | object | `{}` |
 | merger.secretEnv |  | object | `{}` |
 | merger.service.ports[0].containerPort |  | int | `10012` |
 | merger.service.ports[0].name |  | string | `"merger-grpc"` |
 | merger.service.ports[0].protocol |  | string | `"TCP"` |
 | merger.service.ports[1].containerPort |  | int | `9102` |
 | merger.service.ports[1].name |  | string | `"metrics-fh"` |
 | merger.service.ports[1].protocol |  | string | `"TCP"` |
 | merger.service.type |  | string | `"ClusterIP"` |
 | merger.serviceAccount.annotations | Annotations to add to the service account | object | `{}` |
 | merger.serviceAccount.create | Specifies whether a service account should be created | bool | `true` |
 | merger.serviceAccount.name | The name of the service account to use. If not set and create is true, a name is generated using the fullname template | string | `""` |
 | merger.terminationGracePeriodSeconds | Amount of time to wait before force-killing the process | int | `10` |
 | merger.tolerations |  | list | `[]` |
 | merger.volumeClaimSpec.accessModes[0] |  | string | `"ReadWriteOnce"` |
 | merger.volumeClaimSpec.resources.requests.storage | The amount of disk space to provision | string | `"50Gi"` |
 | merger.volumeClaimSpec.storageClassName | The storage class to use when provisioning a persistent volume | string | `"openebs-zfs-localpv-compressed-128k"` |
 | prometheus.serviceMonitors.enabled | Enable monitoring by creating `ServiceMonitor` CRDs ([prometheus-operator](https://github.com/prometheus-operator/prometheus-operator)) | bool | `false` |
 | prometheus.serviceMonitors.interval |  | string | `nil` |
 | prometheus.serviceMonitors.labels |  | object | `{}` |
 | prometheus.serviceMonitors.relabelings |  | list | `[]` |
 | prometheus.serviceMonitors.scrapeTimeout |  | string | `nil` |
 | rbac.clusterRules | Required ClusterRole rules | list | See `values.yaml` |
 | rbac.create | Specifies whether RBAC resources are to be created | bool | `true` |
 | rbac.rules | Required ClusterRole rules | list | See `values.yaml` |
 | reader.affinity |  | object | `{}` |
 | reader.config.metrics-listen-addr |  | string | `":9102"` |
 | reader.config.reader-node-grpc-listen-addr |  | string | `":10010"` |
 | reader.config.reader-node-manager-api-addr |  | string | `":10011"` |
 | reader.configMap.enabled |  | bool | `true` |
 | reader.dataDir |  | string | `"/var/lib/geth"` |
 | reader.enabled |  | bool | `true` |
 | reader.env.FIREETH_READER_NODE_LOG_TO_ZAP |  | string | `"false"` |
 | reader.extraArgs | Additional CLI arguments to pass to `indexer-agent` | list | `[]` |
 | reader.fullnameOverride |  | string | `""` |
 | reader.image | Image for firehose-evm | object | `{"pullPolicy":"IfNotPresent","repository":"ghcr.io/streamingfast/firehose-ethereum","tag":""}` |
 | reader.image.tag | Overrides the image tag | string | Chart.appVersion |
 | reader.imagePullSecrets | Pull secrets required to fetch the Image | list | `[]` |
 | reader.initSnapshot.enabled |  | bool | `true` |
 | reader.initSnapshot.env.SNAPSHOT_REMOTE_LOCATION |  | string | `"add_snapshot_location"` |
 | reader.jwt | JWT for clients to authenticate with the Engine API. Specify either `existingSecret` OR `fromLiteral`. | object | `{"existingSecret":{"key":null,"name":null},"fromLiteral":"1ce5c87e81573667e685eae935d988a92742d5f466d696605cc207a36389c480"}` |
 | reader.jwt.existingSecret | Load the JWT from an existing Kubernetes Secret. Takes precedence over `fromLiteral` if set. | object | `{"key":null,"name":null}` |
 | reader.jwt.existingSecret.key | Data key for the JWT in the Secret | string | `nil` |
 | reader.jwt.existingSecret.name | Name of the Secret resource in the same namespace | string | `nil` |
 | reader.jwt.fromLiteral | Use this literal value for the JWT | string | `"1ce5c87e81573667e685eae935d988a92742d5f466d696605cc207a36389c480"` |
 | reader.nameOverride |  | string | `""` |
 | reader.nodePath |  | string | `"/usr/lib/geth"` |
 | reader.nodeSelector |  | object | `{}` |
 | reader.p2pNodePort.enabled | Expose P2P port via NodePort | bool | `true` |
 | reader.p2pNodePort.initContainer.image.pullPolicy | Container pull policy | string | `"IfNotPresent"` |
 | reader.p2pNodePort.initContainer.image.repository | Container image to fetch nodeport information | string | `"lachlanevenson/k8s-kubectl"` |
 | reader.p2pNodePort.initContainer.image.tag | Container tag | string | `"v1.25.4"` |
 | reader.p2pNodePort.port | NodePort to be used. Must be unique. | int | `32310` |
 | reader.podAnnotations | Annotations for the `Pod` | object | `{}` |
 | reader.podSecurityContext | Pod-wide security context | object | `{}` |
 | reader.prometheus.serviceMonitors.enabled |  | bool | `true` |
 | reader.readerConfig.extraArgs | Additional CLI arguments to pass to `reader-node` | string | `""` |
 | reader.readerConfig.httpRpc | RPC config parameters | object | `{"addr":"0.0.0.0","api":"net,web3,eth,debug","enabled":true,"vhosts":"*"}` |
 | reader.readerConfig.httpRpc.addr | Listen address | string | `"0.0.0.0"` |
 | reader.readerConfig.httpRpc.api | Enabled APIs | string | `"net,web3,eth,debug"` |
 | reader.readerConfig.httpRpc.enabled | Enable HTTP-RPC server | bool | `true` |
 | reader.readerConfig.httpRpc.vhosts | Allowed vhosts | string | `"*"` |
 | reader.readerConfig.metrics | Metrics parameters | object | `{"addr":"0.0.0.0","enabled":true,"port":6061}` |
 | reader.readerConfig.metrics.addr | Listen address | string | `"0.0.0.0"` |
 | reader.readerConfig.metrics.enabled | Enable metrics | bool | `true` |
 | reader.readerConfig.metrics.port | Metrics port | int | `6061` |
 | reader.readerConfig.snapshot.enabled |  | bool | `true` |
 | reader.readerConfig.syncMode |  | string | `"full"` |
 | reader.reader_node.volumeClaimSpec.accessModes[0] |  | string | `"ReadWriteOnce"` |
 | reader.reader_node.volumeClaimSpec.resources.requests.storage | The amount of disk space to provision | string | `"3Ti"` |
 | reader.reader_node.volumeClaimSpec.storageClassName | The storage class to use when provisioning a persistent volume | string | `"openebs-zfs-localpv-compressed-8k"` |
 | reader.replicas |  | int | `1` |
 | reader.resources |  | object | `{}` |
 | reader.secretEnv |  | object | `{}` |
 | reader.service.ports[0].containerPort |  | int | `10010` |
 | reader.service.ports[0].name |  | string | `"reader-grpc"` |
 | reader.service.ports[0].protocol |  | string | `"TCP"` |
 | reader.service.ports[1].containerPort |  | int | `9102` |
 | reader.service.ports[1].name |  | string | `"metrics-fh"` |
 | reader.service.ports[1].protocol |  | string | `"TCP"` |
 | reader.service.ports[2].containerPort |  | int | `6061` |
 | reader.service.ports[2].name |  | string | `"metrics-geth"` |
 | reader.service.ports[2].protocol |  | string | `"TCP"` |
 | reader.service.ports[3].containerPort |  | int | `10011` |
 | reader.service.ports[3].name |  | string | `"node-mgr"` |
 | reader.service.ports[3].protocol |  | string | `"TCP"` |
 | reader.service.ports[4].containerPort |  | int | `8551` |
 | reader.service.ports[4].name |  | string | `"geth-auth"` |
 | reader.service.ports[4].protocol |  | string | `"TCP"` |
 | reader.service.type |  | string | `"ClusterIP"` |
 | reader.serviceAccount.annotations | Annotations to add to the service account | object | `{}` |
 | reader.serviceAccount.create | Specifies whether a service account should be created | bool | `true` |
 | reader.serviceAccount.name | The name of the service account to use. If not set and create is true, a name is generated using the fullname template | string | `""` |
 | reader.terminationGracePeriodSeconds | Amount of time to wait before force-killing the process | int | `10` |
 | reader.tolerations |  | list | `[]` |
 | reader.volumeClaimSpec.accessModes[0] |  | string | `"ReadWriteOnce"` |
 | reader.volumeClaimSpec.resources.requests.storage | The amount of disk space to provision | string | `"50Gi"` |
 | reader.volumeClaimSpec.storageClassName | The storage class to use when provisioning a persistent volume | string | `"openebs-zfs-localpv-compressed-128k"` |
 | relayer.affinity |  | object | `{}` |
 | relayer.config.relayer-grpc-listen-addr |  | string | `":10014"` |
 | relayer.config.relayer-max-source-latency |  | string | `"1h"` |
 | relayer.config.relayer-source |  | string | `"reader:10010"` |
 | relayer.configMap.enabled |  | bool | `true` |
 | relayer.enabled |  | bool | `true` |
 | relayer.env |  | object | `{}` |
 | relayer.extraArgs | Additional CLI arguments to pass to `indexer-agent` | list | `[]` |
 | relayer.fullnameOverride |  | string | `""` |
 | relayer.image | Image for firehose-evm | object | `{"pullPolicy":"IfNotPresent","repository":"ghcr.io/streamingfast/firehose-ethereum","tag":""}` |
 | relayer.image.tag | Overrides the image tag | string | Chart.appVersion |
 | relayer.imagePullSecrets | Pull secrets required to fetch the Image | list | `[]` |
 | relayer.nameOverride |  | string | `""` |
 | relayer.nodeSelector |  | object | `{}` |
 | relayer.podAnnotations | Annotations for the `Pod` | object | `{}` |
 | relayer.podSecurityContext | Pod-wide security context | object | `{}` |
 | relayer.prometheus.serviceMonitors.enabled |  | bool | `true` |
 | relayer.replicas |  | int | `1` |
 | relayer.resources |  | object | `{}` |
 | relayer.secretEnv |  | object | `{}` |
 | relayer.service.ports[0].containerPort |  | int | `10014` |
 | relayer.service.ports[0].name |  | string | `"relayer-grpc"` |
 | relayer.service.ports[0].protocol |  | string | `"TCP"` |
 | relayer.service.ports[1].containerPort |  | int | `9102` |
 | relayer.service.ports[1].name |  | string | `"metrics-fh"` |
 | relayer.service.ports[1].protocol |  | string | `"TCP"` |
 | relayer.service.type |  | string | `"ClusterIP"` |
 | relayer.serviceAccount.annotations | Annotations to add to the service account | object | `{}` |
 | relayer.serviceAccount.create | Specifies whether a service account should be created | bool | `true` |
 | relayer.serviceAccount.name | The name of the service account to use. If not set and create is true, a name is generated using the fullname template | string | `""` |
 | relayer.terminationGracePeriodSeconds | Amount of time to wait before force-killing the process | int | `10` |
 | relayer.tolerations |  | list | `[]` |
 | relayer.volumeClaimSpec.accessModes[0] |  | string | `"ReadWriteOnce"` |
 | relayer.volumeClaimSpec.resources.requests.storage | The amount of disk space to provision | string | `"50Gi"` |
 | relayer.volumeClaimSpec.storageClassName | The storage class to use when provisioning a persistent volume | string | `"openebs-zfs-localpv-compressed-128k"` |
 | serviceAccount.annotations | Annotations to add to the service account | object | `{}` |
 | serviceAccount.create | Specifies whether a service account should be created | bool | `true` |
 | serviceAccount.name | The name of the service account to use. If not set and create is true, a name is generated using the fullname template | string | `""` |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.3](https://github.com/norwoodj/helm-docs/releases/v1.11.3)
