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
 | erigon.__enabled |  | bool | `true` |
 | erigon.workload.__enabled |  | bool | `true` |
 | erigon.workload.replicaCount |  | int | `1` |
 | erigonDefaults.__enabled |  | bool | `true` |
 | erigonDefaults.config.args."authrpc.addr" |  | string | `"0.0.0.0"` |
 | erigonDefaults.config.args."authrpc.jwtsecret" |  | string | `""` |
 | erigonDefaults.config.args."authrpc.port" |  | int | `8551` |
 | erigonDefaults.config.args."authrpc.vhosts" |  | string | `"*"` |
 | erigonDefaults.config.args."db.pagesize" |  | string | `"8KB"` |
 | erigonDefaults.config.args."db.read.concurrency" |  | int | `16` |
 | erigonDefaults.config.args."http.addr" |  | string | `"0.0.0.0"` |
 | erigonDefaults.config.args."http.api" |  | string | `"eth,debug,net,trace,erigon,engine"` |
 | erigonDefaults.config.args."http.compression" |  | bool | `true` |
 | erigonDefaults.config.args."http.corsdomain" |  | string | `"*"` |
 | erigonDefaults.config.args."http.enabled" |  | bool | `true` |
 | erigonDefaults.config.args."http.port" |  | int | `8545` |
 | erigonDefaults.config.args."http.vhosts" |  | string | `"*"` |
 | erigonDefaults.config.args."metrics.addr" |  | string | `"{{ .Self.config.metrics.enabled \| ternary .Self.config.metrics.addr nil }}"` |
 | erigonDefaults.config.args."metrics.port" |  | string | `"{{ .Self.config.metrics.enabled \| ternary .Self.config.metrics.port nil }}"` |
 | erigonDefaults.config.args."pprof.addr" |  | string | `"{{ .Self.config.pprof.enabled \| ternary .Self.config.pprof.addr nil }}"` |
 | erigonDefaults.config.args."pprof.port" |  | string | `"{{ .Self.config.pprof.enabled \| ternary .Self.config.pprof.port nil }}"` |
 | erigonDefaults.config.args."private.api.addr" |  | string | `"{{ $rpcdaemonEnabled \| ternary \"0.0.0.0:9090\" \"127.0.0.1:9090\" }} @needs(.ComponentValues.rpcdaemon.__enabled as rpcdaemonEnabled)"` |
 | erigonDefaults.config.args."rpc.batch.concurrency" |  | int | `16` |
 | erigonDefaults.config.args."rpc.returndata.limit" |  | int | `4096000` |
 | erigonDefaults.config.args."trace.maxtraces" |  | int | `1000000` |
 | erigonDefaults.config.args."ws.port" |  | int | `8546` |
 | erigonDefaults.config.args.__prefix |  | string | `"--"` |
 | erigonDefaults.config.args.__separator |  | string | `"="` |
 | erigonDefaults.config.args.datadir |  | string | `"/storage"` |
 | erigonDefaults.config.args.healthcheck |  | string | `"__none"` |
 | erigonDefaults.config.args.metrics |  | string | `"{{ .Self.config.metrics.enabled \| ternary \"__none\" nil }}"` |
 | erigonDefaults.config.args.ws |  | bool | `true` |
 | erigonDefaults.config.argsOrder |  | list | `[]` |
 | erigonDefaults.config.jwt | Provision or use an existing JWT secret If it's enabled and neither existingSecret nor fromLiteral are set, a random secret will be generated and then re-used in the future | object | `{"enabled":false,"existingSecret":{"key":null,"name":null},"fromLiteral":null}` |
 | erigonDefaults.config.jwt.enabled | Provision or make use of a JWT secret for Node | bool | `false` |
 | erigonDefaults.config.jwt.existingSecret | Load the JWT from an existing Kubernetes Secret. Takes precedence over `fromLiteral` if set. | object | `{"key":null,"name":null}` |
 | erigonDefaults.config.jwt.existingSecret.key | Data key for the JWT in the Secret | string | `nil` |
 | erigonDefaults.config.jwt.existingSecret.name | Name of the Secret resource in the same namespace | string | `nil` |
 | erigonDefaults.config.jwt.fromLiteral | Use this literal value for the JWT | string | `nil` |
 | erigonDefaults.config.metrics | Enable support for metrics | object | `{"addr":"0.0.0.0","enabled":true,"port":9102}` |
 | erigonDefaults.config.p2p | Enable a NodePort for P2P support in node | object | `{"enabled":false,"protocols":{"67":"","68":""},"torrents":{"enabled":true,"nodePort":null}}` |
 | erigonDefaults.config.p2p.enabled | Expose P2P port via NodePort | bool | `false` |
 | erigonDefaults.config.p2p.protocols | NodePorts must be unique, or left as empty string "" to be obtained dynamically.  | object | `{"67":"","68":""}` |
 | erigonDefaults.config.p2p.torrents.enabled | Enable for torrents NodePort | bool | `true` |
 | erigonDefaults.config.p2p.torrents.nodePort | Specify nodePort to use or Leave null for dynamic | string | `nil` |
 | erigonDefaults.config.pprof | Enable pprof interface support for profiling data | object | `{"addr":"127.0.0.1","enabled":true,"port":6070}` |
 | erigonDefaults.service.__enabled |  | bool | `true` |
 | erigonDefaults.service.metadata.name |  | string | `"{{ .Root.Release.Name }}-{{ .componentName }}-svc"` |
 | erigonDefaults.service.spec.ports.grpc-erigon.__enabled |  | string | `"{{ $rpcdaemonEnabled \| toYaml }} @needs(.ComponentValues.rpcdaemon.__enabled as rpcdaemonEnabled)"` |
 | erigonDefaults.service.spec.ports.grpc-erigon.name |  | string | `"grpc-erigon"` |
 | erigonDefaults.service.spec.ports.grpc-erigon.port |  | int | `9090` |
 | erigonDefaults.service.spec.ports.grpc-erigon.protocol |  | string | `"TCP"` |
 | erigonDefaults.service.spec.ports.http-engineapi.__enabled |  | bool | `true` |
 | erigonDefaults.service.spec.ports.http-engineapi.name |  | string | `"http-engineapi"` |
 | erigonDefaults.service.spec.ports.http-engineapi.port |  | string | `"{{ index $args \"authrpc.port\" \| int }} @needs(.Self.config.args as args)"` |
 | erigonDefaults.service.spec.ports.http-engineapi.protocol |  | string | `"TCP"` |
 | erigonDefaults.service.spec.ports.http-jsonrpc.__enabled |  | string | `"{{ index $args \"http.enabled\" }} @needs(.Self.config.args as args)"` |
 | erigonDefaults.service.spec.ports.http-jsonrpc.name |  | string | `"http-jsonrpc"` |
 | erigonDefaults.service.spec.ports.http-jsonrpc.port |  | string | `"{{ index $args \"http.port\" \| int }} @needs(.Self.config.args as args)"` |
 | erigonDefaults.service.spec.ports.http-jsonrpc.protocol |  | string | `"TCP"` |
 | erigonDefaults.service.spec.ports.http-metrics.__enabled |  | string | `"{{ $metrics.enabled }} @needs(.Self.config.metrics as metrics)"` |
 | erigonDefaults.service.spec.ports.http-metrics.name |  | string | `"http-metrics"` |
 | erigonDefaults.service.spec.ports.http-metrics.port |  | string | `"{{ $metrics.port \| int }} @needs(.Self.config.metrics as metrics)"` |
 | erigonDefaults.service.spec.ports.http-metrics.protocol |  | string | `"TCP"` |
 | erigonDefaults.service.spec.ports.ws-rpc.__enabled |  | string | `"{{ index $args \"ws\" }} @needs(.Self.config.args as args)"` |
 | erigonDefaults.service.spec.ports.ws-rpc.name |  | string | `"ws-rpc"` |
 | erigonDefaults.service.spec.ports.ws-rpc.port |  | string | `"{{ index $args \"ws.port\" \| int }} @needs(.Self.config.args as args)"` |
 | erigonDefaults.service.spec.ports.ws-rpc.protocol |  | string | `"TCP"` |
 | erigonDefaults.workload.__enabled |  | bool | `false` |
 | erigonDefaults.workload.kind |  | string | `"StatefulSet"` |
 | erigonDefaults.workload.metadata.name |  | string | `"{{ .Root.Release.Name }}-{{ .componentName }}"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.command[0] |  | string | `"sh"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.command[1] |  | string | `"-ac"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.command[2] |  | string | `"{{- $__parameters := dict\n  \"map\" $args\n  \"orderList\" ( $argsOrder \| default list )\n}}\n{{- $argsList := include \"common.utils.generateArgsList\" $__parameters \| fromYamlArray }}\nset -ex;\nexec erigon \\\n{{ join \" \\\\\\n\" (initial $argsList) }}\n{{ (last $argsList) }}\n@needs(.Self.config.args as args)\n@needs(.Self.config.argsOrder as argsOrder)\n"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.ports.http-engineapi.__enabled |  | bool | `true` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.ports.http-engineapi.containerPort |  | string | `"{{ index $args \"authrpc.port\" }} @needs(.Self.config.args as args)"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.ports.http-engineapi.name |  | string | `"http-engineapi"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.ports.http-engineapi.protocol |  | string | `"TCP"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.ports.http-jsonrpc.__enabled |  | string | `"{{ index $args \"http.enabled\" }} @needs(.Self.config.args as args)"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.ports.http-jsonrpc.containerPort |  | string | `"{{ index $args \"http.port\" }} @needs(.Self.config.args as args)"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.ports.http-jsonrpc.name |  | string | `"http-jsonrpc"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.ports.http-jsonrpc.protocol |  | string | `"TCP"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.ports.http-metrics.__enabled |  | string | `"{{ $metrics.enabled }} @needs(.Self.config.metrics as metrics)"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.ports.http-metrics.containerPort |  | string | `"{{ $metrics.port \| int }} @needs(.Self.config.metrics as metrics)"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.ports.http-metrics.name |  | string | `"http-metrics"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.ports.http-metrics.protocol |  | string | `"TCP"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.ports.ws-rpc.__enabled |  | string | `"{{ index $args \"ws\" }} @needs(.Self.config.args as args)"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.ports.ws-rpc.containerPort |  | string | `"{{ index $args \"ws.port\" }} @needs(.Self.config.args as args)"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.ports.ws-rpc.name |  | string | `"ws-rpc"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.ports.ws-rpc.protocol |  | string | `"TCP"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.readinessProbe.grpc.port |  | int | `9090` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.securityContext.capabilities.drop[0] |  | string | `"ALL"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.securityContext.readOnlyRootFilesystem |  | bool | `true` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.volumeMounts.storage.mountPath |  | string | `"/storage"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.volumeMounts.storage.name |  | string | `"storage"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.volumeMounts.tmp.mountPath |  | string | `"/tmp"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.volumeMounts.tmp.name |  | string | `"tmp"` |
 | erigonDefaults.workload.spec.template.spec.initContainers.10-init-nodeport@common.__enabled |  | bool | `false` |
 | erigonDefaults.workload.spec.template.spec.securityContext.fsGroup |  | int | `101337` |
 | erigonDefaults.workload.spec.template.spec.securityContext.runAsGroup |  | int | `101337` |
 | erigonDefaults.workload.spec.template.spec.securityContext.runAsNonRoot |  | bool | `true` |
 | erigonDefaults.workload.spec.template.spec.securityContext.runAsUser |  | int | `101337` |
 | erigonDefaults.workload.spec.template.spec.terminationGracePeriodSeconds |  | string | `"60"` |
 | erigonDefaults.workload.spec.template.spec.volumes.tmp.emptyDir |  | object | `{}` |
 | erigonDefaults.workload.spec.updateStrategy.rollingUpdate.partition |  | int | `0` |
 | erigonDefaults.workload.spec.updateStrategy.type |  | string | `"RollingUpdate"` |
 | erigonDefaults.workload.spec.volumeClaimTemplates.__enabled |  | string | `"{{ eq .Self.workload.kind \"StatefulSet\" \| ternary true nil }}"` |
 | erigonDefaults.workload.spec.volumeClaimTemplates.storage.accessModes[0] |  | string | `"ReadWriteOnce"` |
 | erigonDefaults.workload.spec.volumeClaimTemplates.storage.resources.requests.storage | The amount of disk space to provision for Erigon | string | `"3Ti"` |
 | erigonDefaults.workload.spec.volumeClaimTemplates.storage.storageClassName |  | string | `"{{ default nil .Root.Values.globals.storageClassName }}"` |
 | globals.storageClassName | Set a default storage class to use everywhere by default | string | `"blah"` |
 | opnode.__enabled |  | bool | `false` |
 | opnode.workload.__enabled |  | bool | `false` |
 | opnode.workload.replicaCount |  | int | `1` |
 | optimismDefaults.__enabled |  | bool | `true` |
 | optimismDefaults.config.args."l1.beacon" |  | string | `"http://lighthouse:8546"` |
 | optimismDefaults.config.args."l1.rpckind" |  | string | `"erigon"` |
 | optimismDefaults.config.args."l1.trustrpc" |  | string | `"__none"` |
 | optimismDefaults.config.args."metrics.addr" |  | string | `"{{ .Self.config.metrics.enabled \| ternary .Self.config.metrics.addr nil }}"` |
 | optimismDefaults.config.args."metrics.enabled" |  | string | `"{{ .Self.config.metrics.enabled \| ternary \"__none\" nil }}"` |
 | optimismDefaults.config.args."metrics.port" |  | string | `"{{ .Self.config.metrics.enabled \| ternary .Self.config.metrics.port nil }}"` |
 | optimismDefaults.config.args."rpc.addr" |  | string | `"0.0.0.0"` |
 | optimismDefaults.config.args."rpc.port" |  | int | `9545` |
 | optimismDefaults.config.args.__prefix |  | string | `"--"` |
 | optimismDefaults.config.args.__separator |  | string | `"="` |
 | optimismDefaults.config.args.l1 |  | string | `"http://erigon:8545"` |
 | optimismDefaults.config.args.l2 |  | string | `"http://erigon:8551"` |
 | optimismDefaults.config.args.network |  | string | `"mainnet"` |
 | optimismDefaults.config.argsOrder |  | list | `[]` |
 | optimismDefaults.config.metrics.addr |  | string | `"0.0.0.0"` |
 | optimismDefaults.config.metrics.enabled |  | bool | `true` |
 | optimismDefaults.config.metrics.port |  | int | `7600` |
 | optimismDefaults.service.__enabled |  | bool | `true` |
 | optimismDefaults.service.metadata.name |  | string | `"{{ .Root.Release.Name }}-{{ .componentName }}"` |
 | optimismDefaults.service.spec.ports.http-jsonrpc.__enabled |  | string | `"{{ index $args \"rpc.port\" }} @needs(.Self.config.args as args)"` |
 | optimismDefaults.service.spec.ports.http-jsonrpc.name |  | string | `"http-jsonrpc"` |
 | optimismDefaults.service.spec.ports.http-jsonrpc.port |  | string | `"{{ index $args \"rpc.port\" \| int }} @needs(.Self.config.args as args)"` |
 | optimismDefaults.service.spec.ports.http-jsonrpc.protocol |  | string | `"TCP"` |
 | optimismDefaults.workload.__enabled |  | bool | `false` |
 | optimismDefaults.workload.kind |  | string | `"Deployment"` |
 | optimismDefaults.workload.spec.template.spec.containers.opnode.command[0] |  | string | `"sh"` |
 | optimismDefaults.workload.spec.template.spec.containers.opnode.command[1] |  | string | `"-ac"` |
 | optimismDefaults.workload.spec.template.spec.containers.opnode.command[2] |  | string | `"{{- $__parameters := dict\n  \"map\" $args\n  \"orderList\" ( $argsOrder \| default list )\n}}\n{{- $argsList := include \"common.utils.generateArgsList\" $__parameters \| fromYamlArray }}\nset -ex;\nexec op-node \\\n{{ join \" \\\\\\n\" (initial $argsList) }}\n{{ (last $argsList) }}\n@needs(.Self.config.args as args)\n@needs(.Self.config.argsOrder as argsOrder)\n"` |
 | optimismDefaults.workload.spec.template.spec.containers.opnode.securityContext.capabilities.drop[0] |  | string | `"ALL"` |
 | optimismDefaults.workload.spec.template.spec.containers.opnode.securityContext.readOnlyRootFilesystem |  | bool | `true` |
 | optimismDefaults.workload.spec.template.spec.initContainers.10-init-nodeport@common.__enabled |  | bool | `false` |
 | optimismDefaults.workload.spec.template.spec.securityContext.fsGroup |  | int | `101337` |
 | optimismDefaults.workload.spec.template.spec.securityContext.runAsGroup |  | int | `101337` |
 | optimismDefaults.workload.spec.template.spec.securityContext.runAsNonRoot |  | bool | `true` |
 | optimismDefaults.workload.spec.template.spec.securityContext.runAsUser |  | int | `101337` |
 | optimismDefaults.workload.spec.template.spec.terminationGracePeriodSeconds |  | string | `"60"` |
 | optimismDefaults.workload.spec.template.spec.volumes.tmp.emptyDir |  | object | `{}` |
 | rpcdaemon.__enabled | Enable a Deployment of rpcdaemon that can be scaled independently | bool | `true` |
 | rpcdaemon.workload.__enabled |  | bool | `true` |
 | rpcdaemon.workload.kind |  | string | `"Deployment"` |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
