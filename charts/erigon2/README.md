# erigon

![Version: 0.11.0](https://img.shields.io/badge/Version-0.11.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v2.60.10](https://img.shields.io/badge/AppVersion-v2.60.10-informational?style=flat-square)

Deploy and scale [Erigon](https://github.com/ledgerwatch/erigon) inside Kubernetes with ease

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../common | common | 0.1.0 |

## Values

| Key | Description | Type | Default |
|-----|-------------|------|---------|
 | erigonDefaults.config.args."authrpc.addr" |  | string | `"0.0.0.0"` |
 | erigonDefaults.config.args."authrpc.vhosts" |  | string | `"*"` |
 | erigonDefaults.config.args."http.addr" |  | string | `"0.0.0.0"` |
 | erigonDefaults.config.args."http.vhosts" |  | string | `"*"` |
 | erigonDefaults.config.args."metrics.addr" |  | string | `"0.0.0.0"` |
 | erigonDefaults.config.args."private.api.addr" |  | string | `"0.0.0.0:9090"` |
 | erigonDefaults.config.args.__prefix |  | string | `"--"` |
 | erigonDefaults.config.args.__separator |  | string | `"="` |
 | erigonDefaults.config.args.datadir |  | string | `"/storage"` |
 | erigonDefaults.config.args.healthcheck |  | string | `"__none"` |
 | erigonDefaults.config.args.http |  | string | `"__none"` |
 | erigonDefaults.config.args.metrics |  | string | `"__none"` |
 | erigonDefaults.config.argsOrder |  | list | `[]` |
 | erigonDefaults.workload.kind |  | string | `"StatefulSet"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.command[0] |  | string | `"sh"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.command[1] |  | string | `"-ac"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.command[2] |  | string | `"{{- $__parameters := dict\n  \"map\" ( .Self.config.args \| default dict )\n  \"orderList\" ( .Self.config.argsOrder \| default list )\n}}\n{{- $args := include \"common.utils.generateArgsList\" $__parameters \| fromJsonArray }}\nset -ex;\nexec erigon \\\n{{- range $flag := $args }}\n  {{ $flag }} \\\n{{- end }}\n"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.ports.grpc-erigon.containerPort |  | int | `9090` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.ports.grpc-erigon.name |  | string | `"grpc-erigon"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.ports.grpc-erigon.protocol |  | string | `"TCP"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.ports.http-engineapi.containerPort |  | int | `8551` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.ports.http-engineapi.name |  | string | `"http-engineapi"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.ports.http-engineapi.protocol |  | string | `"TCP"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.ports.http-jsonrpc.containerPort |  | int | `8545` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.ports.http-jsonrpc.name |  | string | `"http-jsonrpc"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.ports.http-jsonrpc.protocol |  | string | `"TCP"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.ports.http-metrics.containerPort |  | int | `6060` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.ports.http-metrics.name |  | string | `"http-metrics"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.ports.http-metrics.protocol |  | string | `"TCP"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.ports.tcp-p2p.name |  | string | `"tcp-p2p"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.ports.tcp-p2p.protocol |  | string | `"TCP"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.ports.tcp-torrent.containerPort |  | int | `42069` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.ports.tcp-torrent.name |  | string | `"tcp-torrent"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.ports.tcp-torrent.protocol |  | string | `"TCP"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.ports.udp-p2p.name |  | string | `"udp-p2p"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.ports.udp-p2p.protocol |  | string | `"UDP"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.ports.udp-torrent.containerPort |  | int | `42069` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.ports.udp-torrent.name |  | string | `"udp-torrent"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.ports.udp-torrent.protocol |  | string | `"UDP"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.ports.ws-rpc.containerPort |  | int | `8546` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.ports.ws-rpc.name |  | string | `"ws-rpc"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.ports.ws-rpc.protocol |  | string | `"TCP"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.readinessProbe.grpc.port |  | int | `9090` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.securityContext.capabilities.drop[0] |  | string | `"ALL"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.securityContext.readOnlyRootFilesystem |  | bool | `true` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.volumeMounts.storage.mountPath |  | string | `"/storage"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.volumeMounts.storage.name |  | string | `"storage"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.volumeMounts.tmp.mountPath |  | string | `"/tmp"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.volumeMounts.tmp.name |  | string | `"tmp"` |
 | erigonDefaults.workload.spec.template.spec.securityContext.fsGroup |  | int | `101337` |
 | erigonDefaults.workload.spec.template.spec.securityContext.runAsGroup |  | string | `"{{ .Self.workload.spec.template.spec.securityContext.runAsUser }}"` |
 | erigonDefaults.workload.spec.template.spec.securityContext.runAsNonRoot |  | bool | `true` |
 | erigonDefaults.workload.spec.template.spec.securityContext.runAsUser |  | int | `101337` |
 | erigonDefaults.workload.spec.template.spec.terminationGracePeriodSeconds |  | string | `"60"` |
 | erigonDefaults.workload.spec.template.spec.volumes.tmp.emptyDir |  | object | `{}` |
 | erigonDefaults.workload.spec.updateStrategy.rollingUpdate.partition |  | int | `0` |
 | erigonDefaults.workload.spec.updateStrategy.type |  | string | `"RollingUpdate"` |
 | erigonDefaults.workload.spec.volumeClaimTemplates.storage.accessModes[0] |  | string | `"ReadWriteOnce"` |
 | erigonDefaults.workload.spec.volumeClaimTemplates.storage.resources.requests.storage | The amount of disk space to provision for Erigon | string | `"3Ti"` |
 | erigonDefaults.workload.spec.volumeClaimTemplates.storage.storageClassName |  | string | `"{{ default nil .Root.Values.globals.storageClassName }}"` |
 | globals.storageClassName | Set a default storage class to use everywhere | string | `nil` |
 | rpcdaemon.__enabled | Enable a Deployment of rpcdaemon that can be scaled independently | bool | `true` |
 | rpcdaemon.clusterRbac | Cluster scoped RBAC role and binding configuration Used by the P2P init-container | object | `{"__enabled":false,"bindingSpec":{"roleRef":{}},"roleSpec":null}` |
 | rpcdaemon.configMap | ConfigMap customization | object | `{"__enabled":true,"metadata":{"annotations":{},"labels":{}},"options":{"useEnvSubst":false}}` |
 | rpcdaemon.configMap.__enabled | Create a ConfigMap (highly recommended) | bool | `true` |
 | rpcdaemon.configMap.metadata | Any remaiing key/values can be added and will be merged with the templated ConfigMap resource | object | `{"annotations":{},"labels":{}}` |
 | rpcdaemon.configMap.options | ConfigMap specific options | object | `{"useEnvSubst":false}` |
 | rpcdaemon.configMap.options.useEnvSubst | Run an envsubst initcontainer at runtime | bool | `false` |
 | rpcdaemon.horizontalPodAutoscaler | Horizontal Pod Autoscaler configuration | object | `{"__enabled":false,"metadata":{"annotations":{},"labels":{}},"spec":{}}` |
 | rpcdaemon.horizontalPodAutoscaler.metadata | Anything else will be marge on the final horizontalPodAutoscaler resource template | object | `{"annotations":{},"labels":{}}` |
 | rpcdaemon.image | Image configuration for firehose-ethereum | object | `{"digest":"","pullPolicy":"IfNotPresent","repository":"ghcr.io/streamingfast/firehose-ethereum","tag":"v2.6.7-geth-v1.13.15-fh2.4"}` |
 | rpcdaemon.image.digest | Overrides the image reference using a specific digest | string | `""` |
 | rpcdaemon.image.pullPolicy | Image pull policy | string | `"IfNotPresent"` |
 | rpcdaemon.image.repository | Docker image repository | string | `"ghcr.io/streamingfast/firehose-ethereum"` |
 | rpcdaemon.image.tag | Overrides the image reference using a tag digest takes precedence over tag if both are set | string | `"v2.6.7-geth-v1.13.15-fh2.4"` |
 | rpcdaemon.imagePullSecrets | Pull secrets required to fetch images | list | `[]` |
 | rpcdaemon.kind | Additional CLI arguments to pass to `rpcdaemon` | string | `"Deployment"` |
 | rpcdaemon.podDisruptionBudget | Pod Disruption Budget configuration | object | `{"__enabled":false,"metadata":{"annotations":{},"labels":{}},"spec":null}` |
 | rpcdaemon.rbac | RBAC role and binding configuration | object | `{"__enabled":"{{ default false .Self.serviceAccount.__enabled }}","bindingSpec":{"metadata":{"annotations":{},"labels":{}},"roleRef":{}},"roleSpec":{"metadata":{"annotations":{},"labels":{}}}}` |
 | rpcdaemon.replicaCount | Number of replicas to run | int | `2` |
 | rpcdaemon.secret.__enabled |  | bool | `true` |
 | rpcdaemon.service | Service customization | object | `{"__enabled":true,"metadata":{"annotations":{},"labels":{}},"spec":{"ports":{"fh-metrics":{"port":24,"protocol":"TCP"}},"type":"ClusterIP"}}` |
 | rpcdaemon.service.__enabled | Create a Service | bool | `true` |
 | rpcdaemon.service.metadata.annotations | Additional service annotations | object | `{}` |
 | rpcdaemon.service.metadata.labels | Additional service labels | object | `{}` |
 | rpcdaemon.service.spec | Any other key/values will be merged with the final Service resource `spec.ports` is a key-value map, with the port name as key, and the spec as value | object | `{"ports":{"fh-metrics":{"port":24,"protocol":"TCP"}},"type":"ClusterIP"}` |
 | rpcdaemon.service.spec.ports | Service ports configuration | object | `{"fh-metrics":{"port":24,"protocol":"TCP"}}` |
 | rpcdaemon.service.spec.type | Service type | string | `"ClusterIP"` |
 | rpcdaemon.serviceAccount | Service account configuration | object | `{"__enabled":true,"metadata":{"annotations":{},"labels":{}}}` |
 | rpcdaemon.serviceAccount.__enabled | Specifies whether a service account should be created | bool | `true` |
 | rpcdaemon.serviceAccount.metadata | Rest spec | object | `{"annotations":{},"labels":{}}` |
 | rpcdaemon.serviceAccount.metadata.annotations | Annotations to add to the service account | object | `{}` |
 | rpcdaemon.serviceAccount.metadata.labels | Labels to add to the service account | object | `{}` |
 | rpcdaemon.serviceHeadless | Also create headless services, mandatory for StatefulSets and true by default | string | `"{{ eq .Self.workload.kind \"StatefulSet\" \| ternary true true }}"` |
 | rpcdaemon.serviceMonitor | ServiceMonitor configuration for Prometheus Operator | object | `{"__enabled":true,"metadata":{"annotations":{},"labels":{}},"spec":{"endpoints":{"metrics-fh":{"honorLabels":true,"interval":"30s","path":"/metrics","scrapeTimeout":"10s"}}}}` |
 | rpcdaemon.serviceMonitor.__enabled | Enable monitoring by creating `ServiceMonitor` CRDs ([prometheus-operator](https://github.com/prometheus-operator/prometheus-operator)) | bool | `true` |
 | rpcdaemon.serviceP2P | Creates a NodePort service (used in P2P support) if a nodePort isn't specified, kubernetes will dinamically attribute one | object | `{"__enabled":true,"metadata":{"annotations":{},"labels":{}},"spec":{"ports":{"p2p-tcp":{"nodePort":null,"port":32222,"protocol":"TCP","targetPort":null},"p2p-udp":{"nodePort":null,"port":30303,"protocol":"UDP","targetPort":null}}}}` |
 | rpcdaemon.serviceP2P.metadata.annotations | Additional service annotations | object | `{}` |
 | rpcdaemon.serviceP2P.metadata.labels | Additional service labels | object | `{}` |
 | rpcdaemon.serviceP2P.spec | Any other key/values will be merged with the final Service resource `spec.ports` is a key-value map, with the port name as key, and the spec as value | object | `{"ports":{"p2p-tcp":{"nodePort":null,"port":32222,"protocol":"TCP","targetPort":null},"p2p-udp":{"nodePort":null,"port":30303,"protocol":"UDP","targetPort":null}}}` |
 | rpcdaemon.serviceP2P.spec.ports | Service ports configuration | object | `{"p2p-tcp":{"nodePort":null,"port":32222,"protocol":"TCP","targetPort":null},"p2p-udp":{"nodePort":null,"port":30303,"protocol":"UDP","targetPort":null}}` |
 | rpcdaemon.serviceP2P.spec.ports.p2p-tcp.nodePort | nodePort to use, if left null a dynamic one will be atributed | optional | `nil` |
 | rpcdaemon.serviceP2P.spec.ports.p2p-tcp.port | default is to use nodePort if specified, or 30303 | mandatory | `32222` |
 | rpcdaemon.serviceP2P.spec.ports.p2p-tcp.targetPort | default is to use the port's name | optional | `nil` |
 | rpcdaemon.serviceP2P.spec.ports.p2p-udp.nodePort | nodePort to use, if left null a dynamic one will be atributed | optional | `nil` |
 | rpcdaemon.serviceP2P.spec.ports.p2p-udp.port | default is to use nodePort if specified, or 30303 | mandatory | `30303` |
 | rpcdaemon.serviceP2P.spec.ports.p2p-udp.targetPort | default is to use the port's name | optional | `nil` |
 | rpcdaemon.workload.__enabled |  | bool | `true` |
 | rpcdaemon.workload.imagePullSecrets |  | list | `[]` |
 | rpcdaemon.workload.kind |  | string | `"Deployment"` |
 | rpcdaemon.workload.serviceName | Required for StatefulSets | string | `"template"` |
 | rpcdaemon.workload.spec.template.spec.affinity |  | object | `{}` |
 | rpcdaemon.workload.spec.template.spec.containers.main.annotations |  | object | `{}` |
 | rpcdaemon.workload.spec.template.spec.containers.main.command |  | list | `[]` |
 | rpcdaemon.workload.spec.template.spec.containers.main.env |  | object | `{}` |
 | rpcdaemon.workload.spec.template.spec.containers.main.envFrom.secretKeyRef.FIREETH_COMMON_FORKED_BLOCKS_STORE_URL.key | Name of the data key in the secret that contains your S3 bucket url for storing forked blocks | string | `""` |
 | rpcdaemon.workload.spec.template.spec.containers.main.envFrom.secretKeyRef.FIREETH_COMMON_FORKED_BLOCKS_STORE_URL.name | Name of the secret that contains your S3 bucket url for storing forked blocks | string | `""` |
 | rpcdaemon.workload.spec.template.spec.containers.main.envFrom.secretKeyRef.FIREETH_COMMON_MERGED_BLOCKS_STORE_URL.key | Name of the data key in the secret that contains your S3 bucket url for storing merged blocks | string | `""` |
 | rpcdaemon.workload.spec.template.spec.containers.main.envFrom.secretKeyRef.FIREETH_COMMON_MERGED_BLOCKS_STORE_URL.name | Name of the secret that contains your S3 bucket url for storing merged blocks | string | `""` |
 | rpcdaemon.workload.spec.template.spec.containers.main.envFrom.secretKeyRef.FIREETH_COMMON_ONE_BLOCK_STORE_URL.key | Name of the data key in the secret that contains your S3 bucket url for storing one blocks | string | `""` |
 | rpcdaemon.workload.spec.template.spec.containers.main.envFrom.secretKeyRef.FIREETH_COMMON_ONE_BLOCK_STORE_URL.name | Name of the secret that contains your S3 bucket url for storing one blocks | string | `""` |
 | rpcdaemon.workload.spec.template.spec.containers.main.labels."app.kubernetes.io/part-of" |  | string | `"{{ .Root.Release.Name }}"` |
 | rpcdaemon.workload.spec.template.spec.containers.main.ports.fh-metrics.containerPort |  | int | `32222` |
 | rpcdaemon.workload.spec.template.spec.containers.main.ports.fh-metrics.protocol |  | string | `"TCP"` |
 | rpcdaemon.workload.spec.template.spec.containers.main.ports.fh-pprof.containerPort |  | int | `30303` |
 | rpcdaemon.workload.spec.template.spec.containers.main.ports.fh-pprof.protocol |  | string | `"TCP"` |
 | rpcdaemon.workload.spec.template.spec.containers.main.resources |  | object | `{}` |
 | rpcdaemon.workload.spec.template.spec.containers.main.securityContext.allowPrivilegeEscalation |  | bool | `false` |
 | rpcdaemon.workload.spec.template.spec.containers.main.securityContext.capabilities.drop[0] |  | string | `"ALL"` |
 | rpcdaemon.workload.spec.template.spec.containers.main.securityContext.readOnlyRootFilesystem |  | bool | `true` |
 | rpcdaemon.workload.spec.template.spec.containers.main.volumeMounts.data-dir.__enabled |  | bool | `true` |
 | rpcdaemon.workload.spec.template.spec.containers.main.volumeMounts.data-dir.mountPath |  | string | `"/mnt"` |
 | rpcdaemon.workload.spec.template.spec.containers.main.volumeMounts.data-dir.readOnly |  | bool | `false` |
 | rpcdaemon.workload.spec.template.spec.lifecycle |  | object | `{}` |
 | rpcdaemon.workload.spec.template.spec.nodeSelector |  | object | `{}` |
 | rpcdaemon.workload.spec.template.spec.podManagementPolicy |  | string | `"OrderedReady"` |
 | rpcdaemon.workload.spec.template.spec.podSecurityContext.fsGroup |  | string | `"{{ .Self.workload.spec.template.spec.podSecurityContext.runAsUser }}"` |
 | rpcdaemon.workload.spec.template.spec.podSecurityContext.runAsGroup |  | string | `"{{ .Self.workload.spec.template.spec.podSecurityContext.runAsUser }}"` |
 | rpcdaemon.workload.spec.template.spec.podSecurityContext.runAsNonRoot |  | bool | `true` |
 | rpcdaemon.workload.spec.template.spec.podSecurityContext.runAsUser |  | int | `1000` |
 | rpcdaemon.workload.spec.template.spec.terminationGracePeriodSeconds |  | int | `10` |
 | rpcdaemon.workload.spec.template.spec.tolerations |  | list | `[]` |
 | rpcdaemon.workload.spec.template.spec.topologySpreadConstraints |  | list | `[]` |
 | rpcdaemon.workload.spec.template.spec.updateStrategy.type |  | string | `"RollingUpdate"` |
 | rpcdaemon.workload.spec.template.spec.volumes.config.__enabled |  | string | `"{{ .Self.configMap.__enabled }}"` |
 | rpcdaemon.workload.spec.template.spec.volumes.config.configMap.defaultMode |  | int | `420` |
 | rpcdaemon.workload.spec.template.spec.volumes.config.configMap.name |  | string | `"template"` |
 | rpcdaemon.workload.spec.template.spec.volumes.data-dir.__enabled |  | bool | `true` |
 | rpcdaemon.workload.spec.template.spec.volumes.data-dir.emptyDir |  | object | `{}` |
 | statefulNode.workload.__enabled |  | bool | `true` |
 | statefulNode.workload.replicaCount |  | int | `1` |
 | statefulNode.workload.test |  | string | `"{{ .ComponentValues.statefulNode.replicaCount }}"` |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.3](https://github.com/norwoodj/helm-docs/releases/v1.11.3)
