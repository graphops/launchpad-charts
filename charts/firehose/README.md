# firehose

![Version: 0.0.0](https://img.shields.io/badge/Version-0.0.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v2.0.0-rc.1-geth-v1.13.4-fh2.3-1](https://img.shields.io/badge/AppVersion-v2.0.0--rc.1--geth--v1.13.4--fh2.3--1-informational?style=flat-square)

-_-

## Requirements

| Repository | Name | Version |
|------------|------|---------|
|  | helpers | >= 0 |
| https://graphops.github.io/launchpad-charts | nimbus | >= 0 |

## Values

| Key | Description | Type | Default |
|-----|-------------|------|---------|
 | common.env.FIREETH_COMMON_CHAIN_ID |  | string | `"1"` |
 | common.env.FIREETH_COMMON_LIVE_BLOCKS_ADDR |  | string | `"relayer:13011"` |
 | common.env.FIREETH_COMMON_NETWORK_ID |  | string | `"1"` |
 | common.env.FIREETH_GLOBAL_DATA_DIR |  | string | `"/var/lib/fireeth"` |
 | common.env.FIREETH_GLOBAL_LOG_TO_FILE |  | string | `"false"` |
 | common.secretEnv.FIREETH_COMMON_FORKED_BLOCKS_STORE_URL.key |  | string | `"forked-blocks"` |
 | common.secretEnv.FIREETH_COMMON_FORKED_BLOCKS_STORE_URL.secretName |  | string | `"firehose-seaweedfs-urls"` |
 | common.secretEnv.FIREETH_COMMON_INDEX_STORE_URL.key |  | string | `"index-store"` |
 | common.secretEnv.FIREETH_COMMON_INDEX_STORE_URL.secretName |  | string | `"firehose-seaweedfs-urls"` |
 | common.secretEnv.FIREETH_COMMON_MERGED_BLOCKS_STORE_URL.key |  | string | `"merged-blocks"` |
 | common.secretEnv.FIREETH_COMMON_MERGED_BLOCKS_STORE_URL.secretName |  | string | `"firehose-seaweedfs-urls"` |
 | common.secretEnv.FIREETH_COMMON_ONE_BLOCK_STORE_URL.key |  | string | `"one-blocks"` |
 | common.secretEnv.FIREETH_COMMON_ONE_BLOCK_STORE_URL.secretName |  | string | `"firehose-seaweedfs-urls"` |
 | configTemplate | [Configuration for graph-node](https://github.com/graphprotocol/graph-node/blob/master/docs/config.md) | string | See default template in [values.yaml](values.yaml) |
 | grpc.affinity |  | object | `{}` |
 | grpc.aliases | Set custom aliases for preconfigured commands in your environment | object | `{}` |
 | grpc.env |  | object | `{}` |
 | grpc.extraArgs | Additional CLI arguments to pass to `indexer-agent` | list | `[]` |
 | grpc.fullnameOverride |  | string | `""` |
 | grpc.image | Image for subgraph-radio | object | `{"pullPolicy":"IfNotPresent","repository":"ghcr.io/streamingfast/firehose-ethereum","tag":""}` |
 | grpc.image.tag | Overrides the image tag | string | Chart.appVersion |
 | grpc.imagePullSecrets | Pull secrets required to fetch the Image | list | `[]` |
 | grpc.nameOverride |  | string | `""` |
 | grpc.nodeSelector |  | object | `{}` |
 | grpc.podAnnotations | Annotations for the `Pod` | object | `{}` |
 | grpc.podSecurityContext | Pod-wide security context | object | `{}` |
 | grpc.resources |  | object | `{}` |
 | grpc.secretEnv |  | object | `{}` |
 | grpc.service.ports.grpc | Service Port to expose Erigon GRPC interface on | int | `13042` |
 | grpc.service.topologyAwareRouting.enabled |  | bool | `false` |
 | grpc.service.type |  | string | `"ClusterIP"` |
 | grpc.serviceAccount.annotations | Annotations to add to the service account | object | `{}` |
 | grpc.serviceAccount.create | Specifies whether a service account should be created | bool | `true` |
 | grpc.serviceAccount.name | The name of the service account to use. If not set and create is true, a name is generated using the fullname template | string | `""` |
 | grpc.terminationGracePeriodSeconds | Amount of time to wait before force-killing the process | int | `10` |
 | grpc.tolerations |  | list | `[]` |
 | grpc.volumeClaimSpec.accessModes[0] |  | string | `"ReadWriteOnce"` |
 | grpc.volumeClaimSpec.resources.requests.storage | The amount of disk space to provision | string | `"50Gi"` |
 | grpc.volumeClaimSpec.storageClassName | The storage class to use when provisioning a persistent volume | string | `"openebs-zfs-localpv-compressed-128k"` |
 | image | Image for subgraph-radio | object | `{"pullPolicy":"IfNotPresent","repository":"ghcr.io/streamingfast/firehose-ethereum","tag":""}` |
 | image.tag | Overrides the image tag | string | Chart.appVersion |
 | merger.affinity |  | object | `{}` |
 | merger.aliases | Set custom aliases for preconfigured commands in your environment | object | `{}` |
 | merger.env |  | object | `{}` |
 | merger.extraArgs | Additional CLI arguments to pass to `indexer-agent` | list | `[]` |
 | merger.fullnameOverride |  | string | `""` |
 | merger.image | Image for subgraph-radio | object | `{"pullPolicy":"IfNotPresent","repository":"ghcr.io/streamingfast/firehose-ethereum","tag":""}` |
 | merger.image.tag | Overrides the image tag | string | Chart.appVersion |
 | merger.imagePullSecrets | Pull secrets required to fetch the Image | list | `[]` |
 | merger.nameOverride |  | string | `""` |
 | merger.nodeSelector |  | object | `{}` |
 | merger.podAnnotations | Annotations for the `Pod` | object | `{}` |
 | merger.podSecurityContext | Pod-wide security context | object | `{}` |
 | merger.resources |  | object | `{}` |
 | merger.secretEnv |  | object | `{}` |
 | merger.service.ports.metrics | Service Port to expose Erigon GRPC interface on | int | `9102` |
 | merger.service.topologyAwareRouting.enabled |  | bool | `false` |
 | merger.service.type |  | string | `"ClusterIP"` |
 | merger.serviceAccount.annotations | Annotations to add to the service account | object | `{}` |
 | merger.serviceAccount.create | Specifies whether a service account should be created | bool | `true` |
 | merger.serviceAccount.name | The name of the service account to use. If not set and create is true, a name is generated using the fullname template | string | `""` |
 | merger.terminationGracePeriodSeconds | Amount of time to wait before force-killing the process | int | `10` |
 | merger.tolerations |  | list | `[]` |
 | merger.volumeClaimSpec.accessModes[0] |  | string | `"ReadWriteOnce"` |
 | merger.volumeClaimSpec.resources.requests.storage | The amount of disk space to provision | string | `"50Gi"` |
 | merger.volumeClaimSpec.storageClassName | The storage class to use when provisioning a persistent volume | string | `"openebs-zfs-localpv-compressed-128k"` |
 | nimbus.nimbus.executionClientUrl |  | string | `"http://firehose-reader:8547"` |
 | nimbus.nimbus.jwt.existingSecret.key |  | string | `"jwt.hex"` |
 | nimbus.nimbus.jwt.existingSecret.name |  | string | `"firehose-reader-jwt"` |
 | nimbus.nimbus.trustedNodeSync.enabled |  | bool | `true` |
 | nimbus.nimbus.trustedNodeSync.trustedNodeUrl |  | string | `"https://beaconstate.ethstaker.cc"` |
 | nimbus.nimbus.volumeClaimSpec.storageClassName |  | string | `"openebs-zfs-localpv-compressed-8k"` |
 | nimbus.prometheus.serviceMonitors.enabled |  | bool | `true` |
 | rbac.clusterRules | Required ClusterRole rules | list | See `values.yaml` |
 | rbac.create | Specifies whether RBAC resources are to be created | bool | `true` |
 | rbac.rules | Required ClusterRole rules | list | See `values.yaml` |
 | reader.affinity |  | object | `{}` |
 | reader.aliases | Set custom aliases for preconfigured commands in your environment | object | `{}` |
 | reader.env.FIREETH_READER_NODE_ARGUMENTS |  | string | `"--networkid=1 --datadir={node-data-dir} --port=30310 --http --http.api=eth,net,web3 --http.port=8545 --http.addr=0.0.0.0 --http.vhosts=* --firehose-enabled --cache=8192 --maxpeers=100 --mainnet --syncmode full --metrics --metrics.addr=0.0.0.0 --metrics.port=6061 --discovery.port=30310 --authrpc.port=8547 --authrpc.addr=0.0.0.0 --authrpc.vhosts=* --authrpc.jwtsecret=/jwt/jwt.hex --snapshot=true --txlookuplimit=1000"` |
 | reader.env.FIREETH_READER_NODE_DATA_DIR |  | string | `"/var/lib/geth"` |
 | reader.env.FIREETH_READER_NODE_LOG_TO_ZAP |  | string | `"false"` |
 | reader.extraArgs | Additional CLI arguments to pass to `indexer-agent` | list | `[]` |
 | reader.fullnameOverride |  | string | `""` |
 | reader.image | Image for subgraph-radio | object | `{"pullPolicy":"IfNotPresent","repository":"ghcr.io/streamingfast/firehose-ethereum","tag":""}` |
 | reader.image.tag | Overrides the image tag | string | Chart.appVersion |
 | reader.imagePullSecrets | Pull secrets required to fetch the Image | list | `[]` |
 | reader.jwt | JWT for clients to authenticate with the Engine API. Specify either `existingSecret` OR `fromLiteral`. | object | `{"existingSecret":{"key":null,"name":null},"fromLiteral":"1ce5c87e81573667e685eae935d988a92742d5f466d696605cc207a36389c480"}` |
 | reader.jwt.existingSecret | Load the JWT from an existing Kubernetes Secret. Takes precedence over `fromLiteral` if set. | object | `{"key":null,"name":null}` |
 | reader.jwt.existingSecret.key | Data key for the JWT in the Secret | string | `nil` |
 | reader.jwt.existingSecret.name | Name of the Secret resource in the same namespace | string | `nil` |
 | reader.jwt.fromLiteral | Use this literal value for the JWT | string | `"1ce5c87e81573667e685eae935d988a92742d5f466d696605cc207a36389c480"` |
 | reader.nameOverride |  | string | `""` |
 | reader.nodeSelector |  | object | `{}` |
 | reader.p2pNodePort.enabled | Expose P2P port via NodePort | bool | `true` |
 | reader.p2pNodePort.port | NodePort to be used. Must be unique. | int | `32310` |
 | reader.podAnnotations | Annotations for the `Pod` | object | `{}` |
 | reader.podSecurityContext | Pod-wide security context | object | `{}` |
 | reader.reader_node.volumeClaimSpec.accessModes[0] |  | string | `"ReadWriteOnce"` |
 | reader.reader_node.volumeClaimSpec.resources.requests.storage | The amount of disk space to provision | string | `"3Ti"` |
 | reader.reader_node.volumeClaimSpec.storageClassName | The storage class to use when provisioning a persistent volume | string | `"openebs-zfs-localpv-compressed-8k"` |
 | reader.resources |  | object | `{}` |
 | reader.secretEnv |  | object | `{}` |
 | reader.service.ports.eth-consensus | Service Port to expose Erigon GRPC interface on | int | `8547` |
 | reader.service.ports.grpc |  | int | `13010` |
 | reader.service.ports.metrics-fh |  | int | `9102` |
 | reader.service.ports.metrics-geth |  | int | `6061` |
 | reader.service.ports.node-mgr |  | int | `13009` |
 | reader.service.topologyAwareRouting.enabled |  | bool | `false` |
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
 | relayer.aliases | Set custom aliases for preconfigured commands in your environment | object | `{}` |
 | relayer.env.FIREETH_RELAYER_SOURCE |  | string | `"reader-node:13010"` |
 | relayer.extraArgs | Additional CLI arguments to pass to `indexer-agent` | list | `[]` |
 | relayer.fullnameOverride |  | string | `""` |
 | relayer.image | Image for subgraph-radio | object | `{"pullPolicy":"IfNotPresent","repository":"ghcr.io/streamingfast/firehose-ethereum","tag":""}` |
 | relayer.image.tag | Overrides the image tag | string | Chart.appVersion |
 | relayer.imagePullSecrets | Pull secrets required to fetch the Image | list | `[]` |
 | relayer.nameOverride |  | string | `""` |
 | relayer.nodeSelector |  | object | `{}` |
 | relayer.podAnnotations | Annotations for the `Pod` | object | `{}` |
 | relayer.podSecurityContext | Pod-wide security context | object | `{}` |
 | relayer.resources |  | object | `{}` |
 | relayer.secretEnv |  | object | `{}` |
 | relayer.service.ports.grpc | Service Port to expose Erigon GRPC interface on | int | `13011` |
 | relayer.service.topologyAwareRouting.enabled |  | bool | `false` |
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
