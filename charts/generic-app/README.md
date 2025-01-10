# Generic-App Helm Chart

A generic app chart

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) ![Version: 0.3.0](https://img.shields.io/badge/Version-0.3.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: generic-app](https://img.shields.io/badge/AppVersion-generic--app-informational?style=flat-square)

## Introduction

This is a generic chart for deploying applications using `Deployment`s or `StatefulSet`s, alongside `Service`s, `ConfigMap`s, and `Secret`s.

## Chart Features

- Actively maintained by [GraphOps](https://graphops.xyz) [and contributors](https://github.com/graphops/launchpad-charts/graphs/contributors)
- Supports multiple applications within a single release
- Flexible configuration for `ConfigMap`s and `Secret`s
- Init containers for pre-deployment operations
- Robust security configurations with `ServiceAccount`s and RBAC
- Comprehensive pod scheduling options including node selectors, tolerations, and affinity rules
- Customizable resource requests and limits

## Quickstart

To install the chart with the release name `my-release`:

```console
$ helm repo add graphops http://graphops.github.io/launchpad-charts
$ helm install my-release graphops/generic-app
```

## Configuring generic-app

This section provides a comprehensive guide to configuring the generic-app chart. Refer to the `values.yaml` file for all available configuration options.

### Applications Deployment

You can deploy one or more applications by configuring the `apps` section. Each application can be enabled or disabled, and configured to use either a `Deployment` or `StatefulSet`.

```yaml
apps:
  example-app:
    enabled: true
    kind: Deployment
    replicaCount: 3
    annotations:
      app.kubernetes.io/component: frontend
    imagePullSecrets:
      - name: my-regcred
    ...
```

### ConfigMaps and Secrets

#### Creating ConfigMaps

Define your `ConfigMap`s under the `configMaps` section using a local name (`lname`). This allows you to reference them within your application containers.

```yaml
configMaps:
  app-config:
    data:
      config.yaml: |-
        key: value
```

#### Creating Secrets

Define your `Secret`s under the `secrets` section using a local name (`lname`). Secrets are used to store sensitive information such as passwords and API keys.

```yaml
secrets:
  db-creds:
    data:
      password: s3cr3t
```

#### Referencing ConfigMaps and Secrets

Use the `lname` to reference `ConfigMap`s and `Secret`s within your application configurations.

**ConfigMap Mounts:**

```yaml
configMapMounts:
  /config:
    lname: app-config
```

**Secret Environment Variables:**

```yaml
secretEnv:
  DB_PASSWORD:
    lname: db-creds
    key: password
```

**When to Use `fullname`:**

Use `fullname` when referencing external resources or when you need to avoid naming collisions across different releases.

### Init Container Operations

Configure init containers to perform operations before your main application containers start. This is managed under the `initOperations` section.

```yaml
initOperations:
  enabled: true
  passthroughMountPath: /init-passthrough
  steps:
    config-prep:
      enabled: true
      image: busybox
      command:
        - sh
        - -c
        - envsubst < /config/template.yaml > /init-passthrough/config.yaml
      env:
        API_PORT: "8080"
        LOG_LEVEL: "debug"
      envRaw:
        - name: POD_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
      secretEnv:
        DB_PASSWORD:
          lname: db-creds
          key: password
      configMapMounts:
        /config:
          lname: app-config
      secretMounts:
        /secrets:
          lname: app-secrets
```

### Service Accounts and RBAC

The chart can create `ServiceAccount`s with associated `Role`s and `RoleBinding`s to manage permissions.

```yaml
serviceAccount:
  create: true
  annotations:
    eks.amazonaws.com/role-arn: "arn:aws:iam::123456789:role/app-role"
  name: "app-sa"
  role:
    rules:
      - apiGroups: [""]
        resources: ["pods", "services"]
        verbs: ["get", "list", "watch"]
```

### Containers Configuration

Configure each container with specific settings such as image repository, ports, commands, environment variables, and resource limits.

```yaml
containers:
  app:
    image:
      repository: company/app
      tag: v1.2.3
      pullPolicy: IfNotPresent
    ports:
      http: 8080
      metrics: 9090
    command:
      - /bin/app
      - serve
    args:
      - --config
      - /init-passthrough/config.yaml
    env:
      NODE_ENV: production
      LOG_FORMAT: json
      API_PORT: "8080"
    envRaw:
      - name: POD_IP
        valueFrom:
          fieldRef:
            fieldPath: status.podIP
    secretEnv:
      DB_PASSWORD:
        lname: db-creds
        key: password
      API_KEY:
        lname: api-secrets
        key: key
    secretMounts:
      /app/secrets:
        lname: app-secrets
      /app/certs:
        lname: tls-certs
    configMapMounts:
      /app/config:
        lname: app-config
    volumeClaimMounts:
      /app/data:
        lname: data
    securityContext:
      runAsUser: 1000
      runAsNonRoot: true
      readOnlyRootFilesystem: true
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
      limits:
        cpu: 1000m
        memory: 512Mi
    preInstallPod:
      enabled: true
      command: "python /app/db-migrate.py"
    preUpgradePod:
      enabled: true
      command: "python /app/db-backup.py"
```

### Services Configuration

Define how your applications are exposed within the Kubernetes cluster.

**Default Service:**

```yaml
service:
  enabled: true
  annotations:
    prometheus.io/scrape: "true"
  type: ClusterIP
  ports:
    http: 8080
    metrics: 9090
```

**Additional Services:**

```yaml
services:
  metrics:
    enabled: true
    type: ClusterIP
    ports:
      prometheus: 9090
```

### Ingress Configuration

Configure ingress resources to expose your applications externally.

```yaml
ingress:
  main:
    enabled: false
    annotations:
      kubernetes.io/ingress.class: nginx
      kubernetes.io/tls-acme: "true"
    tls:
      - secretName: chart-example-tls
        hosts:
          - chart-example.local
    rules:
      - host: chart-example.local
        paths:
          - path: /
            targetApp: app1
            serviceName: ""
            servicePort: 80
```

### Pod Security and Scheduling

Enhance the security and scheduling of your pods using various Kubernetes features.

```yaml
podSecurityContext:
  fsGroup: 2000

nodeSelector:
  kubernetes.io/arch: amd64
  kubernetes.io/os: linux

tolerations:
  - key: "node-role.kubernetes.io/master"
    operator: "Exists"
    effect: "NoSchedule"

affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
        - matchExpressions:
            - key: kubernetes.io/e2e-az-name
              operator: In
              values:
                - e2e-az1
                - e2e-az2

injectPodYaml:
  terminationGracePeriodSeconds: 60
  dnsPolicy: ClusterFirst
```

### Volume Claims

Specify persistent storage for your applications, especially when using `StatefulSet`s.

```yaml
volumeClaims:
  data:
    accessModes: [ReadWriteOnce]
    resources:
      requests:
        storage: 1Gi
```

## Upgrading

We recommend that you pin the version of the Chart that you deploy. You can use the `--version` flag with `helm install` and `helm upgrade` to specify a chart version constraint.

This project uses [Semantic Versioning](https://semver.org/). Changes to the version of the application (the `appVersion`) that the Chart deploys will generally result in a patch version bump for the Chart. Breaking changes to the Chart or its `values.yaml` interface will be reflected with a major version bump.

We do not recommend that you upgrade the application by overriding `image.tag`. Instead, use the version of the Chart that is built for your desired `appVersion`.

## Values

| Key | Description | Type | Default |
|-----|-------------|------|---------|
 | apps | Applications to deploy | object | `{"example-app":{"affinity":{"nodeAffinity":{"requiredDuringSchedulingIgnoredDuringExecution":{"nodeSelectorTerms":[{"matchExpressions":[{"key":"kubernetes.io/e2e-az-name","operator":"In","values":["e2e-az1","e2e-az2"]}]}]}}},"annotations":{"app.kubernetes.io/component":"api","prometheus.io/scrape":"true"},"containers":{"app":{"args":["--config","/init-passthrough/config.yaml"],"command":["/bin/app","serve"],"configMapMounts":{"/app/config":{"lname":"app-config"}},"env":{"API_PORT":"8080","LOG_FORMAT":"json","NODE_ENV":"production"},"envRaw":[{"name":"POD_IP","valueFrom":{"fieldRef":{"fieldPath":"status.podIP"}}}],"image":{"pullPolicy":"IfNotPresent","repository":"company/app","tag":"v1.2.3"},"ports":{"http":8080,"metrics":9090},"preInstallPod":{"command":"python /app/db-migrate.py","enabled":true},"preUpgradePod":{"command":"python /app/db-backup.py","enabled":true},"resources":{"limits":{"cpu":"1000m","memory":"512Mi"},"requests":{"cpu":"100m","memory":"128Mi"}},"secretEnv":{"API_KEY":{"key":"key","lname":"api-secrets"},"DB_PASSWORD":{"key":"password","lname":"db-creds"}},"secretMounts":{"/app/certs":{"lname":"tls-certs"},"/app/secrets":{"lname":"app-secrets"}},"securityContext":{"readOnlyRootFilesystem":true,"runAsNonRoot":true,"runAsUser":1000},"volumeClaimMounts":{"/app/data":{"lname":"data"}}}},"enabled":false,"imagePullSecrets":[{"name":"regcred"}],"initOperations":{"enabled":true,"passthroughMountPath":"/init-passthrough","steps":{"config-prep":{"command":["sh","-c","envsubst < /config/template.yaml > /init-passthrough/config.yaml"],"configMapMounts":{"/config":{"lname":"app-config"}},"enabled":true,"env":{"API_PORT":"8080","LOG_LEVEL":"debug"},"envRaw":[{"name":"POD_NAME","valueFrom":{"fieldRef":{"fieldPath":"metadata.name"}}}],"image":"busybox","secretEnv":{"API_KEY":{"key":"key","lname":"api-secrets"},"DB_PASSWORD":{"key":"password","lname":"db-creds"}},"secretMounts":{"/secrets":{"lname":"app-secrets"}}}}},"injectPodYaml":{"dnsPolicy":"ClusterFirst","terminationGracePeriodSeconds":60},"kind":"StatefulSet","nodeSelector":{"kubernetes.io/arch":"amd64","kubernetes.io/os":"linux"},"podSecurityContext":{"fsGroup":2000},"replicaCount":1,"service":{"annotations":{"prometheus.io/scrape":"true"},"enabled":true,"type":"ClusterIP"},"serviceAccount":{"annotations":{"eks.amazonaws.com/role-arn":"arn:aws:iam::123456789:role/app-role"},"create":true,"name":"app-sa","role":{"rules":[{"apiGroups":[""],"resources":["pods","services"],"verbs":["get","list","watch"]}]}},"services":{"metrics":{"enabled":true,"ports":{"prometheus":9090},"type":"ClusterIP"}},"tolerations":[{"effect":"NoSchedule","key":"node-role.kubernetes.io/master","operator":"Exists"}],"volumeClaims":{"data":{"accessModes":["ReadWriteOnce"],"resources":{"requests":{"storage":"1Gi"}}}}}}` |
 | apps.example-app | Example app configuration | object | `{"affinity":{"nodeAffinity":{"requiredDuringSchedulingIgnoredDuringExecution":{"nodeSelectorTerms":[{"matchExpressions":[{"key":"kubernetes.io/e2e-az-name","operator":"In","values":["e2e-az1","e2e-az2"]}]}]}}},"annotations":{"app.kubernetes.io/component":"api","prometheus.io/scrape":"true"},"containers":{"app":{"args":["--config","/init-passthrough/config.yaml"],"command":["/bin/app","serve"],"configMapMounts":{"/app/config":{"lname":"app-config"}},"env":{"API_PORT":"8080","LOG_FORMAT":"json","NODE_ENV":"production"},"envRaw":[{"name":"POD_IP","valueFrom":{"fieldRef":{"fieldPath":"status.podIP"}}}],"image":{"pullPolicy":"IfNotPresent","repository":"company/app","tag":"v1.2.3"},"ports":{"http":8080,"metrics":9090},"preInstallPod":{"command":"python /app/db-migrate.py","enabled":true},"preUpgradePod":{"command":"python /app/db-backup.py","enabled":true},"resources":{"limits":{"cpu":"1000m","memory":"512Mi"},"requests":{"cpu":"100m","memory":"128Mi"}},"secretEnv":{"API_KEY":{"key":"key","lname":"api-secrets"},"DB_PASSWORD":{"key":"password","lname":"db-creds"}},"secretMounts":{"/app/certs":{"lname":"tls-certs"},"/app/secrets":{"lname":"app-secrets"}},"securityContext":{"readOnlyRootFilesystem":true,"runAsNonRoot":true,"runAsUser":1000},"volumeClaimMounts":{"/app/data":{"lname":"data"}}}},"enabled":false,"imagePullSecrets":[{"name":"regcred"}],"initOperations":{"enabled":true,"passthroughMountPath":"/init-passthrough","steps":{"config-prep":{"command":["sh","-c","envsubst < /config/template.yaml > /init-passthrough/config.yaml"],"configMapMounts":{"/config":{"lname":"app-config"}},"enabled":true,"env":{"API_PORT":"8080","LOG_LEVEL":"debug"},"envRaw":[{"name":"POD_NAME","valueFrom":{"fieldRef":{"fieldPath":"metadata.name"}}}],"image":"busybox","secretEnv":{"API_KEY":{"key":"key","lname":"api-secrets"},"DB_PASSWORD":{"key":"password","lname":"db-creds"}},"secretMounts":{"/secrets":{"lname":"app-secrets"}}}}},"injectPodYaml":{"dnsPolicy":"ClusterFirst","terminationGracePeriodSeconds":60},"kind":"StatefulSet","nodeSelector":{"kubernetes.io/arch":"amd64","kubernetes.io/os":"linux"},"podSecurityContext":{"fsGroup":2000},"replicaCount":1,"service":{"annotations":{"prometheus.io/scrape":"true"},"enabled":true,"type":"ClusterIP"},"serviceAccount":{"annotations":{"eks.amazonaws.com/role-arn":"arn:aws:iam::123456789:role/app-role"},"create":true,"name":"app-sa","role":{"rules":[{"apiGroups":[""],"resources":["pods","services"],"verbs":["get","list","watch"]}]}},"services":{"metrics":{"enabled":true,"ports":{"prometheus":9090},"type":"ClusterIP"}},"tolerations":[{"effect":"NoSchedule","key":"node-role.kubernetes.io/master","operator":"Exists"}],"volumeClaims":{"data":{"accessModes":["ReadWriteOnce"],"resources":{"requests":{"storage":"1Gi"}}}}}` |
 | apps.example-app.affinity | Pod affinity rules | object | `{"nodeAffinity":{"requiredDuringSchedulingIgnoredDuringExecution":{"nodeSelectorTerms":[{"matchExpressions":[{"key":"kubernetes.io/e2e-az-name","operator":"In","values":["e2e-az1","e2e-az2"]}]}]}}}` |
 | apps.example-app.annotations | Pod/deployment annotations | object | `{"app.kubernetes.io/component":"api","prometheus.io/scrape":"true"}` |
 | apps.example-app.containers | Container configurations | object | `{"app":{"args":["--config","/init-passthrough/config.yaml"],"command":["/bin/app","serve"],"configMapMounts":{"/app/config":{"lname":"app-config"}},"env":{"API_PORT":"8080","LOG_FORMAT":"json","NODE_ENV":"production"},"envRaw":[{"name":"POD_IP","valueFrom":{"fieldRef":{"fieldPath":"status.podIP"}}}],"image":{"pullPolicy":"IfNotPresent","repository":"company/app","tag":"v1.2.3"},"ports":{"http":8080,"metrics":9090},"preInstallPod":{"command":"python /app/db-migrate.py","enabled":true},"preUpgradePod":{"command":"python /app/db-backup.py","enabled":true},"resources":{"limits":{"cpu":"1000m","memory":"512Mi"},"requests":{"cpu":"100m","memory":"128Mi"}},"secretEnv":{"API_KEY":{"key":"key","lname":"api-secrets"},"DB_PASSWORD":{"key":"password","lname":"db-creds"}},"secretMounts":{"/app/certs":{"lname":"tls-certs"},"/app/secrets":{"lname":"app-secrets"}},"securityContext":{"readOnlyRootFilesystem":true,"runAsNonRoot":true,"runAsUser":1000},"volumeClaimMounts":{"/app/data":{"lname":"data"}}}}` |
 | apps.example-app.containers.app | Main application container | object | `{"args":["--config","/init-passthrough/config.yaml"],"command":["/bin/app","serve"],"configMapMounts":{"/app/config":{"lname":"app-config"}},"env":{"API_PORT":"8080","LOG_FORMAT":"json","NODE_ENV":"production"},"envRaw":[{"name":"POD_IP","valueFrom":{"fieldRef":{"fieldPath":"status.podIP"}}}],"image":{"pullPolicy":"IfNotPresent","repository":"company/app","tag":"v1.2.3"},"ports":{"http":8080,"metrics":9090},"preInstallPod":{"command":"python /app/db-migrate.py","enabled":true},"preUpgradePod":{"command":"python /app/db-backup.py","enabled":true},"resources":{"limits":{"cpu":"1000m","memory":"512Mi"},"requests":{"cpu":"100m","memory":"128Mi"}},"secretEnv":{"API_KEY":{"key":"key","lname":"api-secrets"},"DB_PASSWORD":{"key":"password","lname":"db-creds"}},"secretMounts":{"/app/certs":{"lname":"tls-certs"},"/app/secrets":{"lname":"app-secrets"}},"securityContext":{"readOnlyRootFilesystem":true,"runAsNonRoot":true,"runAsUser":1000},"volumeClaimMounts":{"/app/data":{"lname":"data"}}}` |
 | apps.example-app.containers.app.args | Container arguments | list | `["--config","/init-passthrough/config.yaml"]` |
 | apps.example-app.containers.app.command | Container command | list | `["/bin/app","serve"]` |
 | apps.example-app.containers.app.configMapMounts | ConfigMap volume mounts | object | `{"/app/config":{"lname":"app-config"}}` |
 | apps.example-app.containers.app.env | Environment variables | object | `{"API_PORT":"8080","LOG_FORMAT":"json","NODE_ENV":"production"}` |
 | apps.example-app.containers.app.envRaw | Raw environment variable declarations | list | `[{"name":"POD_IP","valueFrom":{"fieldRef":{"fieldPath":"status.podIP"}}}]` |
 | apps.example-app.containers.app.image | Container image configuration | object | `{"pullPolicy":"IfNotPresent","repository":"company/app","tag":"v1.2.3"}` |
 | apps.example-app.containers.app.ports | Container ports to expose | object | `{"http":8080,"metrics":9090}` |
 | apps.example-app.containers.app.preInstallPod | Pre-install pod configuration | object | `{"command":"python /app/db-migrate.py","enabled":true}` |
 | apps.example-app.containers.app.preUpgradePod | Pre-upgrade pod configuration   | object | `{"command":"python /app/db-backup.py","enabled":true}` |
 | apps.example-app.containers.app.resources | Container resource requests/limits | object | `{"limits":{"cpu":"1000m","memory":"512Mi"},"requests":{"cpu":"100m","memory":"128Mi"}}` |
 | apps.example-app.containers.app.secretEnv | Environment variables from secrets | object | `{"API_KEY":{"key":"key","lname":"api-secrets"},"DB_PASSWORD":{"key":"password","lname":"db-creds"}}` |
 | apps.example-app.containers.app.secretMounts | Secret volume mounts | object | `{"/app/certs":{"lname":"tls-certs"},"/app/secrets":{"lname":"app-secrets"}}` |
 | apps.example-app.containers.app.securityContext | Container security context | object | `{"readOnlyRootFilesystem":true,"runAsNonRoot":true,"runAsUser":1000}` |
 | apps.example-app.containers.app.volumeClaimMounts | Persistent volume claim mounts (only for StatefulSets) | object | `{"/app/data":{"lname":"data"}}` |
 | apps.example-app.enabled | Enable/disable this app deployment | bool | `false` |
 | apps.example-app.imagePullSecrets | Image pull secrets for accessing private registries | list | `[{"name":"regcred"}]` |
 | apps.example-app.initOperations | Init container operations configuration | object | `{"enabled":true,"passthroughMountPath":"/init-passthrough","steps":{"config-prep":{"command":["sh","-c","envsubst < /config/template.yaml > /init-passthrough/config.yaml"],"configMapMounts":{"/config":{"lname":"app-config"}},"enabled":true,"env":{"API_PORT":"8080","LOG_LEVEL":"debug"},"envRaw":[{"name":"POD_NAME","valueFrom":{"fieldRef":{"fieldPath":"metadata.name"}}}],"image":"busybox","secretEnv":{"API_KEY":{"key":"key","lname":"api-secrets"},"DB_PASSWORD":{"key":"password","lname":"db-creds"}},"secretMounts":{"/secrets":{"lname":"app-secrets"}}}}}` |
 | apps.example-app.initOperations.enabled | Enable init containers | bool | `true` |
 | apps.example-app.initOperations.passthroughMountPath | Mount path for sharing data between init containers | string | `"/init-passthrough"` |
 | apps.example-app.initOperations.steps | Init container steps to run | object | `{"config-prep":{"command":["sh","-c","envsubst < /config/template.yaml > /init-passthrough/config.yaml"],"configMapMounts":{"/config":{"lname":"app-config"}},"enabled":true,"env":{"API_PORT":"8080","LOG_LEVEL":"debug"},"envRaw":[{"name":"POD_NAME","valueFrom":{"fieldRef":{"fieldPath":"metadata.name"}}}],"image":"busybox","secretEnv":{"API_KEY":{"key":"key","lname":"api-secrets"},"DB_PASSWORD":{"key":"password","lname":"db-creds"}},"secretMounts":{"/secrets":{"lname":"app-secrets"}}}}` |
 | apps.example-app.initOperations.steps.config-prep | Example init step | object | `{"command":["sh","-c","envsubst < /config/template.yaml > /init-passthrough/config.yaml"],"configMapMounts":{"/config":{"lname":"app-config"}},"enabled":true,"env":{"API_PORT":"8080","LOG_LEVEL":"debug"},"envRaw":[{"name":"POD_NAME","valueFrom":{"fieldRef":{"fieldPath":"metadata.name"}}}],"image":"busybox","secretEnv":{"API_KEY":{"key":"key","lname":"api-secrets"},"DB_PASSWORD":{"key":"password","lname":"db-creds"}},"secretMounts":{"/secrets":{"lname":"app-secrets"}}}` |
 | apps.example-app.initOperations.steps.config-prep.command | Command to run in init container | list | `["sh","-c","envsubst < /config/template.yaml > /init-passthrough/config.yaml"]` |
 | apps.example-app.initOperations.steps.config-prep.configMapMounts | ConfigMap volume mounts | object | `{"/config":{"lname":"app-config"}}` |
 | apps.example-app.initOperations.steps.config-prep.enabled | Enable this init step | bool | `true` |
 | apps.example-app.initOperations.steps.config-prep.env | Environment variables | object | `{"API_PORT":"8080","LOG_LEVEL":"debug"}` |
 | apps.example-app.initOperations.steps.config-prep.envRaw | Raw environment variable declarations | list | `[{"name":"POD_NAME","valueFrom":{"fieldRef":{"fieldPath":"metadata.name"}}}]` |
 | apps.example-app.initOperations.steps.config-prep.image | Container image for init step | string | `"busybox"` |
 | apps.example-app.initOperations.steps.config-prep.secretEnv | Environment variables from secrets | object | `{"API_KEY":{"key":"key","lname":"api-secrets"},"DB_PASSWORD":{"key":"password","lname":"db-creds"}}` |
 | apps.example-app.initOperations.steps.config-prep.secretMounts | Secret volume mounts   | object | `{"/secrets":{"lname":"app-secrets"}}` |
 | apps.example-app.injectPodYaml | Additional pod spec fields | object | `{"dnsPolicy":"ClusterFirst","terminationGracePeriodSeconds":60}` |
 | apps.example-app.kind | Kubernetes workload type - can be Deployment or StatefulSet | string | `"StatefulSet"` |
 | apps.example-app.nodeSelector | Node selector | object | `{"kubernetes.io/arch":"amd64","kubernetes.io/os":"linux"}` |
 | apps.example-app.podSecurityContext | Pod security context | object | `{"fsGroup":2000}` |
 | apps.example-app.replicaCount | Number of pod replicas to run | int | `1` |
 | apps.example-app.service | Default service configuration | object | `{"annotations":{"prometheus.io/scrape":"true"},"enabled":true,"type":"ClusterIP"}` |
 | apps.example-app.serviceAccount | Service account configuration | object | `{"annotations":{"eks.amazonaws.com/role-arn":"arn:aws:iam::123456789:role/app-role"},"create":true,"name":"app-sa","role":{"rules":[{"apiGroups":[""],"resources":["pods","services"],"verbs":["get","list","watch"]}]}}` |
 | apps.example-app.services | Additional named services | object | `{"metrics":{"enabled":true,"ports":{"prometheus":9090},"type":"ClusterIP"}}` |
 | apps.example-app.tolerations | Pod tolerations | list | `[{"effect":"NoSchedule","key":"node-role.kubernetes.io/master","operator":"Exists"}]` |
 | apps.example-app.volumeClaims | Volume claim templates (only used when kind=StatefulSet) | object | `{"data":{"accessModes":["ReadWriteOnce"],"resources":{"requests":{"storage":"1Gi"}}}}` |
 | apps.example-app.volumeClaims.data | Name of the volume claim | object | `{"accessModes":["ReadWriteOnce"],"resources":{"requests":{"storage":"1Gi"}}}` |
 | apps.example-app.volumeClaims.data.accessModes | Access modes for the volume | list | `["ReadWriteOnce"]` |
 | apps.example-app.volumeClaims.data.resources | Storage resource requests | object | `{"requests":{"storage":"1Gi"}}` |
 | configMaps | ConfigMaps to create | object | `{}` |
 | fullnameOverride |  | string | `""` |
 | ingress | Ingress configuration | object | `{"example-ingress":{"annotations":{},"enabled":false,"ingressClassName":"nginx","rules":[],"tls":[]}}` |
 | ingress.example-ingress.annotations | Ingress annotations | object | `{}` |
 | ingress.example-ingress.ingressClassName | Ingress class name (required for k8s >= 1.18) | string | `"nginx"` |
 | ingress.example-ingress.rules | Ingress rules | list | `[]` |
 | ingress.example-ingress.tls | TLS configuration | list | `[]` |
 | nameOverride |  | string | `""` |
 | secrets | Secrets to create | object | `{}` |

## Contributing

We welcome and appreciate your contributions! Please see the [Contributor Guide](/CONTRIBUTING.md), [Code Of Conduct](/CODE_OF_CONDUCT.md) and [Security Notes](/SECURITY.md) for this repository.
