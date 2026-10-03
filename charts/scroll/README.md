# scroll

![Version: 0.0.1](https://img.shields.io/badge/Version-0.0.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: scroll-v5.8.5](https://img.shields.io/badge/AppVersion-scroll--v5.8.5-informational?style=flat-square)

Deploy and scale [Scroll](https://github.com/scroll-tech/go-ethereum) inside Kubernetes with ease

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://graphops.github.io/launchpad-charts/canary | common | 0.0.1-canary.1 |

## Values

| Key | Description | Type | Default |
|-----|-------------|------|---------|
 | global.annotations | Global annotations added to all resources | object | `{}` |
 | global.fullnameOverride |  | string | `""` |
 | global.labels | Global labels added to all resources | object | `{"app.kubernetes.io/component":"{{ .componentName }}","app.kubernetes.io/instance":"{{ .Root.Release.Name }}","app.kubernetes.io/managed-by":"{{ .Root.Release.Service }}","app.kubernetes.io/name":"{{ .Root.Chart.Name }}","app.kubernetes.io/part-of":"{{ .Root.Release.Name }}","app.kubernetes.io/version":"{{ .Root.Chart.AppVersion }}","helm.sh/chart":"{{ include \"common.metadata.chart\" . }}"}` |
 | global.nameOverride |  | string | `""` |
 | global.storageClassName | Set a default storage class to use everywhere by default | string | `"openebs-zfs-localpv-compressed-8k"` |
 | scroll.__enabled |  | bool | `true` |
 | scroll.workload.__enabled |  | bool | `true` |
 | scroll.workload.replicaCount |  | int | `1` |
 | scrollDefaults.clusterRole | Cluster scoped RBAC role and binding configuration Used by the P2P init-container | object | `{"__enabled":true,"__name":"role","metadata":{"annotations":{},"labels":{"<<":{"app.kubernetes.io/component":"{{ .componentName }}","app.kubernetes.io/instance":"{{ .Root.Release.Name }}","app.kubernetes.io/managed-by":"{{ .Root.Release.Service }}","app.kubernetes.io/name":"{{ .Root.Chart.Name }}","app.kubernetes.io/part-of":"{{ .Root.Release.Name }}","app.kubernetes.io/version":"{{ .Root.Chart.AppVersion }}","helm.sh/chart":"{{ include \"common.metadata.chart\" . }}"}},"name":"{{ printf \"%s-%s-%s\" .Root.Release.Name .componentName $roleName }} @needs(.Self.clusterRole.__name as roleName)"},"rules":[{"apiGroups":[""],"resources":["nodes"],"verbs":["get","list","watch"]}]}` |
 | scrollDefaults.clusterRoleBinding.__enabled |  | bool | `true` |
 | scrollDefaults.clusterRoleBinding.metadata.annotations |  | object | `{}` |
 | scrollDefaults.clusterRoleBinding.metadata.labels.<<."app.kubernetes.io/component" |  | string | `"{{ .componentName }}"` |
 | scrollDefaults.clusterRoleBinding.metadata.labels.<<."app.kubernetes.io/instance" |  | string | `"{{ .Root.Release.Name }}"` |
 | scrollDefaults.clusterRoleBinding.metadata.labels.<<."app.kubernetes.io/managed-by" |  | string | `"{{ .Root.Release.Service }}"` |
 | scrollDefaults.clusterRoleBinding.metadata.labels.<<."app.kubernetes.io/name" |  | string | `"{{ .Root.Chart.Name }}"` |
 | scrollDefaults.clusterRoleBinding.metadata.labels.<<."app.kubernetes.io/part-of" |  | string | `"{{ .Root.Release.Name }}"` |
 | scrollDefaults.clusterRoleBinding.metadata.labels.<<."app.kubernetes.io/version" |  | string | `"{{ .Root.Chart.AppVersion }}"` |
 | scrollDefaults.clusterRoleBinding.metadata.labels.<<."helm.sh/chart" |  | string | `"{{ include \"common.metadata.chart\" . }}"` |
 | scrollDefaults.clusterRoleBinding.metadata.name |  | string | `"{{ print \"%s-binding\" $roleName }} @needs(.Self.clusterRole.metadata.name as roleName)"` |
 | scrollDefaults.clusterRoleBinding.roleRef.apiGroup |  | string | `"rbac.authorization.k8s.io"` |
 | scrollDefaults.clusterRoleBinding.roleRef.kind |  | string | `"ClusterRole"` |
 | scrollDefaults.clusterRoleBinding.roleRef.name |  | string | `"{{ $roleName }} @needs(.Self.clusterRole.metadata.name as roleName)"` |
 | scrollDefaults.clusterRoleBinding.subjects.default.kind |  | string | `"ServiceAccount"` |
 | scrollDefaults.clusterRoleBinding.subjects.default.name |  | string | `"{{ $SAName }} @needs(.Self.serviceAccount.metadata.name as SAName)"` |
 | scrollDefaults.clusterRoleBinding.subjects.default.namespace |  | string | `"{{ .Root.Release.Namespace }}"` |
 | scrollDefaults.config.args."cache.noprefetch" |  | string | `"__none"` |
 | scrollDefaults.config.args."da.blob.beaconnode" |  | string | `"http://nimbus-1-nimbus.eth-mainnet-canary.svc.cluster.local.:5052"` |
 | scrollDefaults.config.args."da.sync" |  | bool | `false` |
 | scrollDefaults.config.args."http.addr" |  | string | `"0.0.0.0"` |
 | scrollDefaults.config.args."http.api" |  | string | `"eth,net,web3,debug,scroll"` |
 | scrollDefaults.config.args."http.corsdomain" |  | string | `"*"` |
 | scrollDefaults.config.args."http.port" |  | int | `8545` |
 | scrollDefaults.config.args."http.vhosts" |  | string | `"*"` |
 | scrollDefaults.config.args."l1.endpoint" |  | string | `"http://proxyd-proxyd.eth-mainnet.svc.cluster.local.:8545"` |
 | scrollDefaults.config.args."metrics.addr" |  | string | `"{{ $metrics.enabled \| ternary ($metrics.addr \| quote) nil }} @needs(.Self.config.metrics as metrics)"` |
 | scrollDefaults.config.args."metrics.port" |  | string | `"{{ $metrics.enabled \| ternary ($metrics.port \| int) nil }} @needs(.Self.config.metrics as metrics)"` |
 | scrollDefaults.config.args."pprof.addr" |  | string | `"{{ $pprof.enabled \| ternary ($pprof.addr \| quote) nil }} @needs(.Self.config.pprof as pprof)"` |
 | scrollDefaults.config.args."pprof.port" |  | string | `"{{ $pprof.enabled \| ternary ($pprof.port \| int) nil }} @needs(.Self.config.pprof as pprof)"` |
 | scrollDefaults.config.args."rollup.verify" |  | string | `"__none"` |
 | scrollDefaults.config.args."ws.api" |  | string | `"eth,net,web3,debug,scroll"` |
 | scrollDefaults.config.args."ws.origins" |  | string | `"*"` |
 | scrollDefaults.config.args."ws.port" |  | int | `8546` |
 | scrollDefaults.config.args.__prefix |  | string | `"--"` |
 | scrollDefaults.config.args.__separator |  | string | `"="` |
 | scrollDefaults.config.args.datadir |  | string | `"/storage"` |
 | scrollDefaults.config.args.gcmode |  | string | `"archive"` |
 | scrollDefaults.config.args.http |  | string | `"__none"` |
 | scrollDefaults.config.args.metrics |  | string | `"{{ $metrics.enabled \| ternary (print \"__none\") nil }} @needs(.Self.config.metrics as metrics)"` |
 | scrollDefaults.config.args.nat |  | string | `"{{ $p2p.enabled \| ternary \"extip:${EXTERNAL_IP}\" nil }} @needs(.Self.config.p2p as p2p)"` |
 | scrollDefaults.config.args.port |  | string | `"{{ $p2p.enabled \| ternary \"30301\" nil }} @needs(.Self.config.p2p as p2p)"` |
 | scrollDefaults.config.args.pprof |  | string | `"{{ $pprof.enabled \| ternary (print \"__none\") nil }} @needs(.Self.config.pprof as pprof)"` |
 | scrollDefaults.config.args.scroll |  | string | `"__none"` |
 | scrollDefaults.config.args.syncmode |  | string | `"full"` |
 | scrollDefaults.config.args.ws |  | bool | `true` |
 | scrollDefaults.config.argsOrder |  | list | `[]` |
 | scrollDefaults.config.metrics | Enable support for metrics | object | `{"addr":"0.0.0.0","enabled":true,"port":9090}` |
 | scrollDefaults.config.p2p | Enable a NodePort for P2P support in node | object | `{"enabled":true,"port":30303}` |
 | scrollDefaults.config.p2p.enabled | Expose P2P port via NodePort | bool | `true` |
 | scrollDefaults.config.p2p.port | NodePorts must be unique, or left as empty string "" to be obtained dynamically.  | int | `30303` |
 | scrollDefaults.config.pprof | Enable pprof interface support for profiling data | object | `{"addr":"127.0.0.1","enabled":true,"port":6060}` |
 | scrollDefaults.image | Image configuration for scroll | object | `{"digest":"","pullPolicy":"IfNotPresent","repository":"docker.io/scrolltech/l2geth","tag":"{{ .Root.Chart.AppVersion }}"}` |
 | scrollDefaults.image.digest | Overrides the image reference using a specific digest | string | `""` |
 | scrollDefaults.image.pullPolicy | Image pull policy | string | `"IfNotPresent"` |
 | scrollDefaults.image.repository | Docker image repository | string | `"docker.io/scrolltech/l2geth"` |
 | scrollDefaults.image.tag | Overrides the image reference using a tag digest takes precedence over tag if both are set | string | `"{{ .Root.Chart.AppVersion }}"` |
 | scrollDefaults.podDisruptionBudget | .Self.Disruption Budget configuration | object | `{"__enabled":true,"metadata":{"annotations":{},"labels":{"<<":{"app.kubernetes.io/component":"{{ .componentName }}","app.kubernetes.io/instance":"{{ .Root.Release.Name }}","app.kubernetes.io/managed-by":"{{ .Root.Release.Service }}","app.kubernetes.io/name":"{{ .Root.Chart.Name }}","app.kubernetes.io/part-of":"{{ .Root.Release.Name }}","app.kubernetes.io/version":"{{ .Root.Chart.AppVersion }}","helm.sh/chart":"{{ include \"common.metadata.chart\" . }}"}},"name":"{{ .Root.Release.Name }}-{{ .componentName }}"},"spec":{"selector":{"matchLabels":{"app.kubernetes.io/component":"{{ .componentName }}","app.kubernetes.io/instance":"{{ .Root.Release.Name }}","app.kubernetes.io/name":"{{ .Root.Chart.Name }}"}}}}` |
 | scrollDefaults.role | RBAC role and binding configuration | object | `{"__enabled":"{{ $SAEnabled }} @needs(.Self.serviceAccount.__enabled as SAEnabled)","__name":"role","metadata":{"annotations":{},"labels":{"<<":{"app.kubernetes.io/component":"{{ .componentName }}","app.kubernetes.io/instance":"{{ .Root.Release.Name }}","app.kubernetes.io/managed-by":"{{ .Root.Release.Service }}","app.kubernetes.io/name":"{{ .Root.Chart.Name }}","app.kubernetes.io/part-of":"{{ .Root.Release.Name }}","app.kubernetes.io/version":"{{ .Root.Chart.AppVersion }}","helm.sh/chart":"{{ include \"common.metadata.chart\" . }}"}},"name":"{{ printf \"%s-%s-%s\" .Root.Release.Name .componentName $roleName }} @needs(.Self.role.__name as roleName)"},"rules":[{"apiGroups":[""],"resources":["services"],"verbs":["get","list","watch"]},{"apiGroups":[""],"resources":["secrets"],"verbs":["get","create"]}]}` |
 | scrollDefaults.roleBinding.__enabled |  | string | `"{{ $roleEnabled }} @needs(.Self.role.__enabled as roleEnabled)"` |
 | scrollDefaults.roleBinding.metadata.annotations |  | object | `{}` |
 | scrollDefaults.roleBinding.metadata.labels.<<."app.kubernetes.io/component" |  | string | `"{{ .componentName }}"` |
 | scrollDefaults.roleBinding.metadata.labels.<<."app.kubernetes.io/instance" |  | string | `"{{ .Root.Release.Name }}"` |
 | scrollDefaults.roleBinding.metadata.labels.<<."app.kubernetes.io/managed-by" |  | string | `"{{ .Root.Release.Service }}"` |
 | scrollDefaults.roleBinding.metadata.labels.<<."app.kubernetes.io/name" |  | string | `"{{ .Root.Chart.Name }}"` |
 | scrollDefaults.roleBinding.metadata.labels.<<."app.kubernetes.io/part-of" |  | string | `"{{ .Root.Release.Name }}"` |
 | scrollDefaults.roleBinding.metadata.labels.<<."app.kubernetes.io/version" |  | string | `"{{ .Root.Chart.AppVersion }}"` |
 | scrollDefaults.roleBinding.metadata.labels.<<."helm.sh/chart" |  | string | `"{{ include \"common.metadata.chart\" . }}"` |
 | scrollDefaults.roleBinding.metadata.name |  | string | `"{{ printf \"%s-%s-%s\" .Root.Release.Name .componentName $roleName }} @needs(.Self.role.__name as roleName)"` |
 | scrollDefaults.roleBinding.roleRef.apiGroup |  | string | `"rbac.authorization.k8s.io"` |
 | scrollDefaults.roleBinding.roleRef.kind |  | string | `"Role"` |
 | scrollDefaults.roleBinding.roleRef.name |  | string | `"{{ $roleName }} @needs(.Self.role.metadata.name as roleName)"` |
 | scrollDefaults.roleBinding.subjects[0].kind |  | string | `"ServiceAccount"` |
 | scrollDefaults.roleBinding.subjects[0].name |  | string | `"{{ $SAName }} @needs(.Self.serviceAccount.metadata.name as SAName)"` |
 | scrollDefaults.roleBinding.subjects[0].namespace |  | string | `"{{ .Root.Release.Namespace }}"` |
 | scrollDefaults.serviceAccount | Service account configuration | object | `{"__enabled":true,"metadata":{"annotations":{},"labels":{"<<":{"app.kubernetes.io/component":"{{ .componentName }}","app.kubernetes.io/instance":"{{ .Root.Release.Name }}","app.kubernetes.io/managed-by":"{{ .Root.Release.Service }}","app.kubernetes.io/name":"{{ .Root.Chart.Name }}","app.kubernetes.io/part-of":"{{ .Root.Release.Name }}","app.kubernetes.io/version":"{{ .Root.Chart.AppVersion }}","helm.sh/chart":"{{ include \"common.metadata.chart\" . }}"}},"name":"{{ printf \"%s-%s\" (include \"common.metadata.fullname\" $) .componentName }}"}}` |
 | scrollDefaults.serviceAccount.__enabled | Specifies whether a service account should be created | bool | `true` |
 | scrollDefaults.serviceAccount.metadata | Rest spec | object | `{"annotations":{},"labels":{"<<":{"app.kubernetes.io/component":"{{ .componentName }}","app.kubernetes.io/instance":"{{ .Root.Release.Name }}","app.kubernetes.io/managed-by":"{{ .Root.Release.Service }}","app.kubernetes.io/name":"{{ .Root.Chart.Name }}","app.kubernetes.io/part-of":"{{ .Root.Release.Name }}","app.kubernetes.io/version":"{{ .Root.Chart.AppVersion }}","helm.sh/chart":"{{ include \"common.metadata.chart\" . }}"}},"name":"{{ printf \"%s-%s\" (include \"common.metadata.fullname\" $) .componentName }}"}` |
 | scrollDefaults.serviceAccount.metadata.annotations | Annotations to add to the service account | object | `{}` |
 | scrollDefaults.serviceAccount.metadata.labels | Labels to add to the service account | object | `{"<<":{"app.kubernetes.io/component":"{{ .componentName }}","app.kubernetes.io/instance":"{{ .Root.Release.Name }}","app.kubernetes.io/managed-by":"{{ .Root.Release.Service }}","app.kubernetes.io/name":"{{ .Root.Chart.Name }}","app.kubernetes.io/part-of":"{{ .Root.Release.Name }}","app.kubernetes.io/version":"{{ .Root.Chart.AppVersion }}","helm.sh/chart":"{{ include \"common.metadata.chart\" . }}"}}` |
 | scrollDefaults.serviceAccount.metadata.name | The name of the service account to use. If not set and create is true, a name is generated using the fullname template | string | `"{{ printf \"%s-%s\" (include \"common.metadata.fullname\" $) .componentName }}"` |
 | scrollDefaults.serviceMonitor | ServiceMonitor configuration for Prometheus Operator | object | `{"__enabled":true,"metadata":{"annotations":{},"labels":{"<<":{"app.kubernetes.io/component":"{{ .componentName }}","app.kubernetes.io/instance":"{{ .Root.Release.Name }}","app.kubernetes.io/managed-by":"{{ .Root.Release.Service }}","app.kubernetes.io/name":"{{ .Root.Chart.Name }}","app.kubernetes.io/part-of":"{{ .Root.Release.Name }}","app.kubernetes.io/version":"{{ .Root.Chart.AppVersion }}","helm.sh/chart":"{{ include \"common.metadata.chart\" . }}"}},"name":"{{ printf \"%s-%s\" (include \"common.metadata.fullname\" $) .componentName }}"},"spec":{"endpoints":{"http-metrics":{"honorLabels":true,"interval":"30s","path":"/metrics","scrapeTimeout":"10s"}},"jobLabel":"{{- .Root.Release.Name }}","namespaceSelector":{"matchNames":["{{- .Root.Release.Namespace }}"]},"selector":{"matchLabels":{"app.kubernetes.io/component":"{{ .componentName }}","app.kubernetes.io/instance":"{{ .Root.Release.Name }}","app.kubernetes.io/name":"{{ .Root.Chart.Name }}"}}}}` |
 | scrollDefaults.serviceMonitor.__enabled | Enable monitoring by creating `ServiceMonitor` CRDs ([prometheus-operator](https://github.com/prometheus-operator/prometheus-operator)) | bool | `true` |
 | scrollDefaults.services.default.__enabled |  | bool | `true` |
 | scrollDefaults.services.default.metadata.annotations | Additional service annotations | object | `{}` |
 | scrollDefaults.services.default.metadata.labels | Additional service labels | object | `{"<<":{"app.kubernetes.io/component":"{{ .componentName }}","app.kubernetes.io/instance":"{{ .Root.Release.Name }}","app.kubernetes.io/managed-by":"{{ .Root.Release.Service }}","app.kubernetes.io/name":"{{ .Root.Chart.Name }}","app.kubernetes.io/part-of":"{{ .Root.Release.Name }}","app.kubernetes.io/version":"{{ .Root.Chart.AppVersion }}","helm.sh/chart":"{{ include \"common.metadata.chart\" . }}"}}` |
 | scrollDefaults.services.default.metadata.name |  | string | `"{{ include \"common.metadata.fullname\" $ }}-{{ .componentName }}"` |
 | scrollDefaults.services.default.spec.ports | Service ports configuration | object | `{"http-jsonrpc":{"__enabled":"{{ if $args.http }}true{{else}}false{{ end }} @needs(.Self.config.args as args)","name":"http-jsonrpc","port":"{{ index $args \"http.port\" \| int }} @needs(.Self.config.args as args)","protocol":"TCP"},"http-metrics":{"__enabled":"{{ $metrics.enabled }} @needs(.Self.config.metrics as metrics)","name":"http-metrics","port":"{{ $metrics.port \| int }} @needs(.Self.config.metrics as metrics)","protocol":"TCP"},"ws-rpc":{"__enabled":"{{ index $args \"ws\" }} @needs(.Self.config.args as args)","name":"ws-rpc","port":"{{ index $args \"ws.port\" \| int }} @needs(.Self.config.args as args)","protocol":"TCP"}}` |
 | scrollDefaults.services.default.spec.selector."app.kubernetes.io/component" |  | string | `"{{ .componentName }}"` |
 | scrollDefaults.services.default.spec.selector."app.kubernetes.io/instance" |  | string | `"{{ .Root.Release.Name }}"` |
 | scrollDefaults.services.default.spec.selector."app.kubernetes.io/name" |  | string | `"{{ .Root.Chart.Name }}"` |
 | scrollDefaults.services.default.spec.type | Service type | string | `"ClusterIP"` |
 | scrollDefaults.services.headless.__enabled |  | bool | `true` |
 | scrollDefaults.services.headless.metadata.annotations | Additional service annotations | object | `{}` |
 | scrollDefaults.services.headless.metadata.labels | Additional service labels | object | `{"<<":{"app.kubernetes.io/component":"{{ .componentName }}","app.kubernetes.io/instance":"{{ .Root.Release.Name }}","app.kubernetes.io/managed-by":"{{ .Root.Release.Service }}","app.kubernetes.io/name":"{{ .Root.Chart.Name }}","app.kubernetes.io/part-of":"{{ .Root.Release.Name }}","app.kubernetes.io/version":"{{ .Root.Chart.AppVersion }}","helm.sh/chart":"{{ include \"common.metadata.chart\" . }}"}}` |
 | scrollDefaults.services.headless.metadata.name |  | string | `"{{ include \"common.metadata.fullname\" $ }}-{{ .componentName }}-headless"` |
 | scrollDefaults.services.headless.spec.<<.ports | Service ports configuration | object | `{"http-jsonrpc":{"__enabled":"{{ if $args.http }}true{{else}}false{{ end }} @needs(.Self.config.args as args)","name":"http-jsonrpc","port":"{{ index $args \"http.port\" \| int }} @needs(.Self.config.args as args)","protocol":"TCP"},"http-metrics":{"__enabled":"{{ $metrics.enabled }} @needs(.Self.config.metrics as metrics)","name":"http-metrics","port":"{{ $metrics.port \| int }} @needs(.Self.config.metrics as metrics)","protocol":"TCP"},"ws-rpc":{"__enabled":"{{ index $args \"ws\" }} @needs(.Self.config.args as args)","name":"ws-rpc","port":"{{ index $args \"ws.port\" \| int }} @needs(.Self.config.args as args)","protocol":"TCP"}}` |
 | scrollDefaults.services.headless.spec.<<.selector."app.kubernetes.io/component" |  | string | `"{{ .componentName }}"` |
 | scrollDefaults.services.headless.spec.<<.selector."app.kubernetes.io/instance" |  | string | `"{{ .Root.Release.Name }}"` |
 | scrollDefaults.services.headless.spec.<<.selector."app.kubernetes.io/name" |  | string | `"{{ .Root.Chart.Name }}"` |
 | scrollDefaults.services.headless.spec.<<.type | Service type | string | `"ClusterIP"` |
 | scrollDefaults.services.headless.spec.ClusterIP |  | string | `"None"` |
 | scrollDefaults.services.p2p.__enabled |  | string | `"{{ $p2p.enabled }} @needs(.Self.config.p2p as p2p)"` |
 | scrollDefaults.services.p2p.metadata.annotations | Additional service annotations | object | `{}` |
 | scrollDefaults.services.p2p.metadata.labels | Additional service labels | object | `{"<<":{"app.kubernetes.io/component":"{{ .componentName }}","app.kubernetes.io/instance":"{{ .Root.Release.Name }}","app.kubernetes.io/managed-by":"{{ .Root.Release.Service }}","app.kubernetes.io/name":"{{ .Root.Chart.Name }}","app.kubernetes.io/part-of":"{{ .Root.Release.Name }}","app.kubernetes.io/version":"{{ .Root.Chart.AppVersion }}","helm.sh/chart":"{{ include \"common.metadata.chart\" . }}"},"pod":"{{ include \"common.metadata.fullname\" $ }}-{{ .componentName }}-0","type":"p2p"}` |
 | scrollDefaults.services.p2p.metadata.name |  | string | `"{{ include \"common.metadata.fullname\" $ }}-{{ .componentName }}-p2p"` |
 | scrollDefaults.services.p2p.spec.ports.p2p-tcp.__enabled |  | bool | `true` |
 | scrollDefaults.services.p2p.spec.ports.p2p-tcp.containerPort |  | string | `nil` |
 | scrollDefaults.services.p2p.spec.ports.p2p-tcp.name |  | string | `"p2p-tcp"` |
 | scrollDefaults.services.p2p.spec.ports.p2p-tcp.nodePort |  | string | `"{{- if not (empty $p2p.port) }}\n{{ $p2p.port \| int }}\n{{- else }}\nnull\n{{- end }}\n@needs(.Self.config.p2p as p2p)\n"` |
 | scrollDefaults.services.p2p.spec.ports.p2p-tcp.port |  | int | `30303` |
 | scrollDefaults.services.p2p.spec.ports.p2p-tcp.protocol |  | string | `"TCP"` |
 | scrollDefaults.services.p2p.spec.ports.p2p-udp.__enabled |  | bool | `true` |
 | scrollDefaults.services.p2p.spec.ports.p2p-udp.containerPort |  | string | `nil` |
 | scrollDefaults.services.p2p.spec.ports.p2p-udp.name |  | string | `"p2p-udp"` |
 | scrollDefaults.services.p2p.spec.ports.p2p-udp.nodePort |  | string | `"{{- if not (empty $p2p.port) }}\n{{ $p2p.port \| int }}\n{{- else }}\nnull\n{{- end }}\n@needs(.Self.config.p2p as p2p)\n"` |
 | scrollDefaults.services.p2p.spec.ports.p2p-udp.port |  | int | `30303` |
 | scrollDefaults.services.p2p.spec.ports.p2p-udp.protocol |  | string | `"UDP"` |
 | scrollDefaults.services.p2p.spec.selector."app.kubernetes.io/component" |  | string | `"{{ .componentName }}"` |
 | scrollDefaults.services.p2p.spec.selector."app.kubernetes.io/instance" |  | string | `"{{ .Root.Release.Name }}"` |
 | scrollDefaults.services.p2p.spec.selector."app.kubernetes.io/name" |  | string | `"{{ .Root.Chart.Name }}"` |
 | scrollDefaults.workload.__enabled |  | bool | `true` |
 | scrollDefaults.workload.kind |  | string | `"StatefulSet"` |
 | scrollDefaults.workload.metadata.annotations | Component level annotations (templated) | object | `{}` |
 | scrollDefaults.workload.metadata.labels | Component level labels (templated) | object | `{"<<":{"app.kubernetes.io/component":"{{ .componentName }}","app.kubernetes.io/instance":"{{ .Root.Release.Name }}","app.kubernetes.io/managed-by":"{{ .Root.Release.Service }}","app.kubernetes.io/name":"{{ .Root.Chart.Name }}","app.kubernetes.io/part-of":"{{ .Root.Release.Name }}","app.kubernetes.io/version":"{{ .Root.Chart.AppVersion }}","helm.sh/chart":"{{ include \"common.metadata.chart\" . }}"},"app.kubernetes.io/component":"{{ .componentName }}","app.kubernetes.io/part-of":"{{ .Root.Release.Name }}"}` |
 | scrollDefaults.workload.metadata.name |  | string | `"{{ printf \"%s-%s\" (include \"common.metadata.fullname\" $) .componentName }}"` |
 | scrollDefaults.workload.spec.podManagementPolicy | , scaling behavior: (OrderedReady | Parallel) | StatefulSet only | `"{{ eq $kind \"StatefulSet\" \| ternary \"OrderedReady\" nil }} @needs(.Self.workload.kind as kind)"` |
 | scrollDefaults.workload.spec.selector.matchLabels."app.kubernetes.io/component" |  | string | `"{{ .componentName }}"` |
 | scrollDefaults.workload.spec.selector.matchLabels."app.kubernetes.io/instance" |  | string | `"{{ .Root.Release.Name }}"` |
 | scrollDefaults.workload.spec.selector.matchLabels."app.kubernetes.io/name" |  | string | `"{{ .Root.Chart.Name }}"` |
 | scrollDefaults.workload.spec.serviceName | Required for StatefulSets | string | `"{{ include \"common.metadata.fullname\" $ }}-{{ .componentName }}-headless"` |
 | scrollDefaults.workload.spec.template.metadata.labels.<<."app.kubernetes.io/component" |  | string | `"{{ .componentName }}"` |
 | scrollDefaults.workload.spec.template.metadata.labels.<<."app.kubernetes.io/instance" |  | string | `"{{ .Root.Release.Name }}"` |
 | scrollDefaults.workload.spec.template.metadata.labels.<<."app.kubernetes.io/managed-by" |  | string | `"{{ .Root.Release.Service }}"` |
 | scrollDefaults.workload.spec.template.metadata.labels.<<."app.kubernetes.io/name" |  | string | `"{{ .Root.Chart.Name }}"` |
 | scrollDefaults.workload.spec.template.metadata.labels.<<."app.kubernetes.io/part-of" |  | string | `"{{ .Root.Release.Name }}"` |
 | scrollDefaults.workload.spec.template.metadata.labels.<<."app.kubernetes.io/version" |  | string | `"{{ .Root.Chart.AppVersion }}"` |
 | scrollDefaults.workload.spec.template.metadata.labels.<<."helm.sh/chart" |  | string | `"{{ include \"common.metadata.chart\" . }}"` |
 | scrollDefaults.workload.spec.template.spec.affinity | Affinity configuration | object | `{}` |
 | scrollDefaults.workload.spec.template.spec.containers.scroll.command | Container entrypoint | list | `["/bin/bash","-c","set -ex\n\nENV_DIR=\"/env\"\n\nif [ -d /env ]; then\n  set -o allexport\n  for env_file in \"$ENV_DIR\"/*; do\n    [ -f \"$env_file\" ] && source \"$env_file\"\n  done\n  set +o allexport\nfi\n\n{{- $__parameters := dict\n  \"map\" $args\n  \"orderList\" ( $argsOrder \| default list )\n}}\n{{- $argsList := include \"common.utils.generateArgsList\" $__parameters \| fromYamlArray }}\nexec /usr/local/bin/geth \\\n{{ join \" \\\\\\n\" (initial $argsList) }}\n{{ (last $argsList) }}\n@needs(.Self.config.args as args)\n@needs(.Self.config.argsOrder as argsOrder)\n"]` |
 | scrollDefaults.workload.spec.template.spec.containers.scroll.env | Environment variables | object | `{"POD_NAME":{"valueFrom":{"fieldRef":{"fieldPath":"metadata.name"}}}}` |
 | scrollDefaults.workload.spec.template.spec.containers.scroll.image |  | string | `"{{ printf \"%s:%s\" $repository $tag }} @needs(.Self.image.repository as repository) @needs(.Self.image.tag as tag)"` |
 | scrollDefaults.workload.spec.template.spec.containers.scroll.imagePullPolicy |  | string | `"IfNotPresent"` |
 | scrollDefaults.workload.spec.template.spec.containers.scroll.lifecycle | Lifecycle hooks | object | `{}` |
 | scrollDefaults.workload.spec.template.spec.containers.scroll.ports.http-jsonrpc.__enabled |  | string | `"{{ index $args \"http.enabled\" }} @needs(.Self.config.args as args)"` |
 | scrollDefaults.workload.spec.template.spec.containers.scroll.ports.http-jsonrpc.containerPort |  | string | `"{{ index $args \"http.port\" }} @needs(.Self.config.args as args)"` |
 | scrollDefaults.workload.spec.template.spec.containers.scroll.ports.http-jsonrpc.name |  | string | `"http-jsonrpc"` |
 | scrollDefaults.workload.spec.template.spec.containers.scroll.ports.http-jsonrpc.protocol |  | string | `"TCP"` |
 | scrollDefaults.workload.spec.template.spec.containers.scroll.ports.http-metrics.__enabled |  | string | `"{{ $metrics.enabled }} @needs(.Self.config.metrics as metrics)"` |
 | scrollDefaults.workload.spec.template.spec.containers.scroll.ports.http-metrics.containerPort |  | string | `"{{ $metrics.port \| int }} @needs(.Self.config.metrics as metrics)"` |
 | scrollDefaults.workload.spec.template.spec.containers.scroll.ports.http-metrics.name |  | string | `"http-metrics"` |
 | scrollDefaults.workload.spec.template.spec.containers.scroll.ports.http-metrics.protocol |  | string | `"TCP"` |
 | scrollDefaults.workload.spec.template.spec.containers.scroll.ports.p2p-tcp.__enabled |  | string | `"{{ $p2p.enabled }} @needs(.Self.config.p2p as p2p)"` |
 | scrollDefaults.workload.spec.template.spec.containers.scroll.ports.p2p-tcp.containerPort |  | int | `30303` |
 | scrollDefaults.workload.spec.template.spec.containers.scroll.ports.p2p-tcp.name |  | string | `"p2p-tcp"` |
 | scrollDefaults.workload.spec.template.spec.containers.scroll.ports.p2p-tcp.protocol |  | string | `"TCP"` |
 | scrollDefaults.workload.spec.template.spec.containers.scroll.ports.p2p-udp.__enabled |  | string | `"{{ $p2p.enabled }} @needs(.Self.config.p2p as p2p)"` |
 | scrollDefaults.workload.spec.template.spec.containers.scroll.ports.p2p-udp.containerPort |  | int | `30303` |
 | scrollDefaults.workload.spec.template.spec.containers.scroll.ports.p2p-udp.name |  | string | `"p2p-udp"` |
 | scrollDefaults.workload.spec.template.spec.containers.scroll.ports.p2p-udp.protocol |  | string | `"UDP"` |
 | scrollDefaults.workload.spec.template.spec.containers.scroll.ports.ws-rpc.__enabled |  | string | `"{{ index $args \"ws\" }} @needs(.Self.config.args as args)"` |
 | scrollDefaults.workload.spec.template.spec.containers.scroll.ports.ws-rpc.containerPort |  | string | `"{{ index $args \"ws.port\" }} @needs(.Self.config.args as args)"` |
 | scrollDefaults.workload.spec.template.spec.containers.scroll.ports.ws-rpc.name |  | string | `"ws-rpc"` |
 | scrollDefaults.workload.spec.template.spec.containers.scroll.ports.ws-rpc.protocol |  | string | `"TCP"` |
 | scrollDefaults.workload.spec.template.spec.containers.scroll.resources | Resource requests and limits | object | `{"limits":{"cpu":2,"memory":"24Gi"},"requests":{"cpu":2,"memory":"24Gi"}}` |
 | scrollDefaults.workload.spec.template.spec.containers.scroll.securityContext | Container level security context overrides | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":true}` |
 | scrollDefaults.workload.spec.template.spec.containers.scroll.volumeMounts.env-dir.mountPath |  | string | `"/env"` |
 | scrollDefaults.workload.spec.template.spec.containers.scroll.volumeMounts.storage.mountPath |  | string | `"/storage"` |
 | scrollDefaults.workload.spec.template.spec.containers.scroll.volumeMounts.storage.name |  | string | `"storage"` |
 | scrollDefaults.workload.spec.template.spec.containers.scroll.volumeMounts.tmp.mountPath |  | string | `"/tmp"` |
 | scrollDefaults.workload.spec.template.spec.containers.scroll.volumeMounts.tmp.name |  | string | `"tmp"` |
 | scrollDefaults.workload.spec.template.spec.initContainers | Init containers configuration | object | `{"10-init-nodeport@common":{"__enabled":"{{ $p2p.enabled }} @needs(.Self.config.p2p as p2p)","image":"ghcr.io/graphops/docker-builds/init-toolbox:main","imagePullPolicy":"IfNotPresent","resources":{}}}` |
 | scrollDefaults.workload.spec.template.spec.nodeSelector | Node selector configuration | object | `{}` |
 | scrollDefaults.workload.spec.template.spec.securityContext | .Self.wide security context | object | `{"fsGroup":"{{ $runAsUser }} @needs(.Self.workload.spec.template.spec.securityContext.runAsUser as runAsUser)","runAsGroup":"{{ $runAsUser }} @needs(.Self.workload.spec.template.spec.securityContext.runAsUser as runAsUser)","runAsNonRoot":true,"runAsUser":1000}` |
 | scrollDefaults.workload.spec.template.spec.serviceAccountName |  | string | `"{{ $sa.__enabled \| ternary $sa.metadata.name nil }} @needs(.Self.serviceAccount as sa)"` |
 | scrollDefaults.workload.spec.template.spec.terminationGracePeriodSeconds | Amount of time to wait before force-killing the process | int | `10` |
 | scrollDefaults.workload.spec.template.spec.tolerations | Tolerations configuration | list | `[]` |
 | scrollDefaults.workload.spec.template.spec.topologySpreadConstraints | Topology spread constraints | list | `[]` |
 | scrollDefaults.workload.spec.template.spec.volumes | .Self.volumes | object | `{"env-dir":{"__enabled":"{{ $p2p.enabled }} @needs(.Self.config.p2p as p2p)","emptyDir":{"medium":"Memory"}},"tmp":{"emptyDir":{}}}` |
 | scrollDefaults.workload.spec.updateStrategy.rollingUpdate.partition |  | int | `0` |
 | scrollDefaults.workload.spec.updateStrategy.type |  | string | `"RollingUpdate"` |
 | scrollDefaults.workload.spec.volumeClaimTemplates | Update Strategy, (RollingUpdate | Recreate) for Deployments, (RollingUpdate | OnDelete) for StatefulSets | object | `{"storage":{"__enabled":true,"metadata":{"labels":{"<<":{"app.kubernetes.io/component":"{{ .componentName }}","app.kubernetes.io/instance":"{{ .Root.Release.Name }}","app.kubernetes.io/managed-by":"{{ .Root.Release.Service }}","app.kubernetes.io/name":"{{ .Root.Chart.Name }}","app.kubernetes.io/part-of":"{{ .Root.Release.Name }}","app.kubernetes.io/version":"{{ .Root.Chart.AppVersion }}","helm.sh/chart":"{{ include \"common.metadata.chart\" . }}"}},"name":"storage"},"spec":{"accessModes":["ReadWriteOnce"],"resources":{"requests":{"storage":"2Ti"}},"storageClassName":"{{ default nil .Root.Values.global.storageClassName }}"}}}` |
 | scrollDefaults.workload.spec.volumeClaimTemplates.storage.spec.resources.requests.storage | The amount of disk space to provision for Erigon | string | `"2Ti"` |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
