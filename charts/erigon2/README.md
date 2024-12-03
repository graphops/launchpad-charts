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
 | erigonDefaults.config.args."metrics.addr" |  | string | `"{{ with .Self.config.metrics }}{{ .enabled \| ternary (.addr \| quote) nil }}{{ end }}"` |
 | erigonDefaults.config.args."metrics.port" |  | string | `"{{ with .Self.config.metrics }}{{ .enabled \| ternary (.port \| int) nil }}{{ end }}"` |
 | erigonDefaults.config.args."p2p.allowed-ports" |  | string | `"{{- if .Self.config.p2p.enabled }}\n{{- $strList := list }}\n{{- range $proto, $port := .Self.config.p2p.protocols }}\n{{- if not (empty $port) }}\n{{- $strList = append $strList $proto }}\n{{- else }}\n{{- $strList = append $strList (printf \"${EXTERNAL_PORT_%s}\" $proto) }}\n{{- end }}\n{{- end }}\n{{- printf (join \",\" $strList) }}\n{{- else }}\n{{- print \"null\" }}\n{{- end }}\n"` |
 | erigonDefaults.config.args."p2p.protocol" |  | string | `"{{ join \",\" (keys .Self.config.p2p.protocols) }}"` |
 | erigonDefaults.config.args."pprof.addr" |  | string | `"{{ with .Self.config.pprof }}{{ .enabled \| ternary (.addr \| quote) nil }}{{ end }}"` |
 | erigonDefaults.config.args."pprof.port" |  | string | `"{{ with .Self.config.pprof }}{{ .enabled \| ternary (.port \| int) nil }}{{ end }}"` |
 | erigonDefaults.config.args."private.api.addr" |  | string | `"{{ .ComponentValues.rpcdaemon.__enabled \| ternary \"0.0.0.0:9090\" \"127.0.0.1:9090\" }}"` |
 | erigonDefaults.config.args."rpc.batch.concurrency" |  | int | `16` |
 | erigonDefaults.config.args."rpc.returndata.limit" |  | int | `4096000` |
 | erigonDefaults.config.args."torrent.download.rate" |  | string | `"100mb"` |
 | erigonDefaults.config.args."torrent.download.slots" |  | int | `6` |
 | erigonDefaults.config.args."torrent.port" |  | string | `nil` |
 | erigonDefaults.config.args."trace.maxtraces" |  | int | `1000000` |
 | erigonDefaults.config.args."ws.compression" |  | bool | `true` |
 | erigonDefaults.config.args."ws.port" |  | int | `8546` |
 | erigonDefaults.config.args.__prefix |  | string | `"--"` |
 | erigonDefaults.config.args.__separator |  | string | `"="` |
 | erigonDefaults.config.args.datadir |  | string | `"/storage"` |
 | erigonDefaults.config.args.healthcheck |  | string | `"__none"` |
 | erigonDefaults.config.args.metrics |  | string | `"{{ .Self.config.metrics.enabled \| ternary (print \"__none\") nil }}"` |
 | erigonDefaults.config.args.nat |  | string | `"{{ .Self.config.p2p.enabled \| ternary \"extip:${EXTERNAL_IP}\" nil }}"` |
 | erigonDefaults.config.args.port |  | string | `"{{ tpl (index .Self.config.args \"p2p.allowed-ports\") $ \| splitList \",\" \| first }}"` |
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
 | erigonDefaults.services.default.__enabled |  | bool | `true` |
 | erigonDefaults.services.default.spec.ports.portName.protocol |  | string | `"TCP"` |
 | erigonDefaults.services.default.spec.selector |  | string | `nil` |
 | erigonDefaults.services.default.spec.type |  | string | `"ClusterIP"` |
 | erigonDefaults.services.p2p.__enabled |  | bool | `true` |
 | erigonDefaults.services.p2p.spec.ports.p2p-tcp-67.__enabled |  | string | `"{{ with .Self.config.p2p }}{{ and (.enabled) (hasKey .protocols \"67\") }}{{ end }}"` |
 | erigonDefaults.services.p2p.spec.ports.p2p-tcp-67.name |  | string | `"p2p-tcp-67"` |
 | erigonDefaults.services.p2p.spec.ports.p2p-tcp-67.nodePort |  | string | `"{{- with .Self.config.p2p }}\n{{- if and (hasKey .protocols \"67\") (not (empty (index .protocols \"67\"))) }}\n{{ index .protocols \"67\" \| int }}\n{{- else }}\nnull\n{{- end }}\n{{- end }}\n"` |
 | erigonDefaults.services.p2p.spec.ports.p2p-tcp-67.port |  | int | `30301` |
 | erigonDefaults.services.p2p.spec.ports.p2p-tcp-67.protocol |  | string | `"TCP"` |
 | erigonDefaults.services.p2p.spec.ports.p2p-tcp-67.targetPort |  | string | `nil` |
 | erigonDefaults.services.p2p.spec.ports.p2p-tcp-68.__enabled |  | string | `"{{ with .Self.config.p2p }}{{ and (.enabled) (hasKey .protocols \"68\") }}{{ end }}"` |
 | erigonDefaults.services.p2p.spec.ports.p2p-tcp-68.name |  | string | `"p2p-tcp-68"` |
 | erigonDefaults.services.p2p.spec.ports.p2p-tcp-68.nodePort |  | string | `"{{- with .Self.config.p2p }}\n{{- if and (hasKey .protocols \"68\") (not (empty (index .protocols \"68\"))) }}\n{{ index .protocols \"68\" \| int }}\n{{- else }}\nnull\n{{- end }}\n{{- end }}\n"` |
 | erigonDefaults.services.p2p.spec.ports.p2p-tcp-68.port |  | int | `30302` |
 | erigonDefaults.services.p2p.spec.ports.p2p-tcp-68.protocol |  | string | `"TCP"` |
 | erigonDefaults.services.p2p.spec.ports.p2p-tcp-68.targetPort |  | string | `nil` |
 | erigonDefaults.services.p2p.spec.ports.p2p-udp-67.__enabled |  | string | `"{{ with .Self.config.p2p }}{{ and (.enabled) (hasKey .protocols \"67\") }}{{ end }}"` |
 | erigonDefaults.services.p2p.spec.ports.p2p-udp-67.name |  | string | `"p2p-udp-67"` |
 | erigonDefaults.services.p2p.spec.ports.p2p-udp-67.nodePort |  | string | `"{{- with .Self.config.p2p }}\n{{- if and (hasKey .protocols \"67\") (not (empty (index .protocols \"67\"))) }}\n{{ index .protocols \"67\" \| int }}\n{{- else }}\nnull\n{{- end }}\n{{- end }}\n"` |
 | erigonDefaults.services.p2p.spec.ports.p2p-udp-67.port |  | int | `30301` |
 | erigonDefaults.services.p2p.spec.ports.p2p-udp-67.protocol |  | string | `"UDP"` |
 | erigonDefaults.services.p2p.spec.ports.p2p-udp-67.targetPort |  | string | `nil` |
 | erigonDefaults.services.p2p.spec.ports.p2p-udp-68.__enabled |  | string | `"{{ with .Self.config.p2p }}{{ and (.enabled) (hasKey .protocols \"68\") }}{{ end }}"` |
 | erigonDefaults.services.p2p.spec.ports.p2p-udp-68.name |  | string | `"p2p-udp-68"` |
 | erigonDefaults.services.p2p.spec.ports.p2p-udp-68.nodePort |  | string | `"{{- with .Self.config.p2p }}\n{{- if and (hasKey .protocols \"68\") (not (empty (index .protocols \"68\"))) }}\n{{ index .protocols \"68\" \| int }}\n{{- else }}\nnull\n{{- end }}\n{{- end }}\n"` |
 | erigonDefaults.services.p2p.spec.ports.p2p-udp-68.port |  | int | `30302` |
 | erigonDefaults.services.p2p.spec.ports.p2p-udp-68.protocol |  | string | `"UDP"` |
 | erigonDefaults.services.p2p.spec.ports.p2p-udp-68.targetPort |  | string | `nil` |
 | erigonDefaults.services.p2p.spec.ports.torrent-tcp.__enabled |  | bool | `true` |
 | erigonDefaults.services.p2p.spec.ports.torrent-tcp.containerPort |  | int | `42069` |
 | erigonDefaults.services.p2p.spec.ports.torrent-tcp.name |  | string | `"tcp-torrent"` |
 | erigonDefaults.services.p2p.spec.ports.torrent-tcp.protocol |  | string | `"TCP"` |
 | erigonDefaults.services.p2p.spec.ports.torrent-udp.__enabled |  | bool | `false` |
 | erigonDefaults.services.p2p.spec.ports.torrent-udp.containerPort |  | int | `42069` |
 | erigonDefaults.services.p2p.spec.ports.torrent-udp.name |  | string | `"udp-torrent"` |
 | erigonDefaults.services.p2p.spec.ports.torrent-udp.protocol |  | string | `"UDP"` |
 | erigonDefaults.workload.kind |  | string | `"StatefulSet"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.command[0] |  | string | `"sh"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.command[1] |  | string | `"-ac"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.command[2] |  | string | `"{{- $args := dict }}\n{{- range $arg, $value := .Self.config.args }}\n{{- $_ := set $args $arg (tpl (printf \"%v\" $value) $) }}\n{{- end }}\n{{- $__parameters := dict\n  \"map\" $args\n  \"orderList\" ( .Self.config.argsOrder \| default list )\n}}\n{{- $argsList := include \"common.utils.generateArgsList\" $__parameters \| fromJsonArray }}\nset -ex;\nexec erigon \\\n{{ join \" \\\\\\n\" $argsList }}\n"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.ports.grpc-erigon.__enabled |  | string | `"{{ .ComponentValues.rpcdaemon.__enabled }}"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.ports.grpc-erigon.containerPort |  | string | `"{{- $privateAddr := default nil (index .ComponentValues.statefulNode.config.args \"private.api.addr\") }}\n{{- if $privateAddr }}{{ $privateAddr \| splitList \":\" \| last \| int }}{{ else }}{{ nil }}{{ end }}\n"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.ports.grpc-erigon.name |  | string | `"grpc-erigon"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.ports.grpc-erigon.protocol |  | string | `"TCP"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.ports.http-engineapi.__enabled |  | bool | `true` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.ports.http-engineapi.containerPort |  | string | `"{{ index .Self.config.args \"authrpc.port\" }}"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.ports.http-engineapi.name |  | string | `"http-engineapi"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.ports.http-engineapi.protocol |  | string | `"TCP"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.ports.http-jsonrpc.__enabled |  | string | `"{{ index .Self.config.args \"http.enabled\" }}"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.ports.http-jsonrpc.containerPort |  | string | `"{{ index .Self.config.args \"http.port\" }}"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.ports.http-jsonrpc.name |  | string | `"http-jsonrpc"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.ports.http-jsonrpc.protocol |  | string | `"TCP"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.ports.http-metrics.__enabled |  | string | `"{{ .Self.config.metrics.enabled }}"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.ports.http-metrics.containerPort |  | string | `"{{ .Self.config.metrics.port \| int }}"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.ports.http-metrics.name |  | string | `"http-metrics"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.ports.http-metrics.protocol |  | string | `"TCP"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.ports.ws-rpc.__enabled |  | string | `"{{ index .Self.config.args \"ws\" }}"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.ports.ws-rpc.containerPort |  | string | `"{{ index .Self.config.args \"ws.port\" }}"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.ports.ws-rpc.name |  | string | `"ws-rpc"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.ports.ws-rpc.protocol |  | string | `"TCP"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.readinessProbe.grpc.port |  | int | `9090` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.securityContext.capabilities.drop[0] |  | string | `"ALL"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.securityContext.readOnlyRootFilesystem |  | bool | `true` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.volumeMounts.storage.mountPath |  | string | `"/storage"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.volumeMounts.storage.name |  | string | `"storage"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.volumeMounts.tmp.mountPath |  | string | `"/tmp"` |
 | erigonDefaults.workload.spec.template.spec.containers.erigon.volumeMounts.tmp.name |  | string | `"tmp"` |
 | erigonDefaults.workload.spec.template.spec.initContainers.10-init-nodeport@common.__enabled |  | bool | `true` |
 | erigonDefaults.workload.spec.template.spec.initContainers.10-init-nodeport@common.mykey |  | string | `"test"` |
 | erigonDefaults.workload.spec.template.spec.securityContext.fsGroup |  | int | `101337` |
 | erigonDefaults.workload.spec.template.spec.securityContext.runAsGroup |  | int | `101337` |
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
 | rpcdaemon.__enabled | Enable a Deployment of rpcdaemon that can be scaled independently | bool | `false` |
 | rpcdaemon.workload.kind |  | string | `"Deployment"` |
 | statefulNode.__enabled |  | bool | `true` |
 | statefulNode.workload.__enabled |  | bool | `true` |
 | statefulNode.workload.replicaCount |  | int | `1` |
 | statefulNode.workload.test |  | string | `"{{ .ComponentValues.statefulNode.replicaCount }}"` |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.3](https://github.com/norwoodj/helm-docs/releases/v1.11.3)
