# Loki-Operator Helm Chart

A Helm chart for the Loki Operator

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) ![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.8.0](https://img.shields.io/badge/AppVersion-0.8.0-informational?style=flat-square)

## Features

- Actively maintained by [GraphOps](https://graphops.xyz) [and contributors](https://github.com/graphops/launchpad-charts/graphs/contributors)
- Deploys the Loki Operator, which manages Loki deployments in Kubernetes clusters
- Supports custom resources for managing Loki stacks, alerting rules, and recording rules
- Strong security defaults (non-root execution, ready-only root filesystem, drops all capabilities)
- Readiness checks to ensure traffic only hits `Pod`s that are healthy and ready to serve requests
- Support for `ServiceMonitor`s to configure Prometheus to scrape metrics ([prometheus-operator](https://github.com/prometheus-operator/prometheus-operator))

## Quickstart

To install the chart with the release name `my-release`:

```console
$ helm repo add graphops http://graphops.github.io/launchpad-charts
$ helm install my-release graphops/loki-operator
```

Once the release is installed, the Loki Operator will be deployed and ready to manage Loki resources.

## Custom Resources

The Loki Operator provides the following custom resources:

- **LokiStack**: Defines a Loki deployment with all its components.
- **AlertingRule**: Defines alerting rules for Loki.
- **RecordingRule**: Defines recording rules for Loki.
- **RulerConfig**: Defines ruler configuration for Loki.

### Creating a LokiStack

```yaml
apiVersion: loki.grafana.com/v1
kind: LokiStack
metadata:
  name: example-lokistack
  namespace: loki
spec:
  size: 1x.small
  storage:
    schemas:
    - effectiveDate: "2020-10-11"
      version: v11
    secret:
      name: loki-s3
      type: s3
  storageClassName: standard
  tenants:
    mode: openshift-logging
```

## Upgrading

We recommend that you pin the version of the Chart that you deploy. You can use the `--version` flag with `helm install` and `helm upgrade` to specify a chart version constraint.

This project uses [Semantic Versioning](https://semver.org/). Changes to the version of the application (the `appVersion`) that the Chart deploys will generally result in a patch version bump for the Chart. Breaking changes to the Chart or its `values.yaml` interface will be reflected with a major version bump.

We do not recommend that you upgrade the application by overriding `image.tag`. Instead, use the version of the Chart that is built for your desired `appVersion`.

## Values

| Key | Description | Type | Default |
|-----|-------------|------|---------|
 | affinity |  | object | `{}` |
 | crds.create |  | bool | `true` |
 | crds.keep |  | bool | `true` |
 | env |  | list | `[]` |
 | extraArgs |  | list | `[]` |
 | fullnameOverride |  | string | `""` |
 | image.pullPolicy |  | string | `"IfNotPresent"` |
 | image.repository |  | string | `"docker.io/grafana/loki-operator"` |
 | image.tag |  | string | `""` |
 | imagePullSecrets |  | list | `[]` |
 | livenessProbe.httpGet.path |  | string | `"/healthz"` |
 | livenessProbe.httpGet.port |  | int | `8081` |
 | livenessProbe.initialDelaySeconds |  | int | `15` |
 | livenessProbe.periodSeconds |  | int | `20` |
 | metrics.enabled |  | bool | `true` |
 | metrics.port |  | int | `8443` |
 | metrics.serviceAnnotations |  | object | `{}` |
 | metrics.serviceMonitor.additionalLabels |  | object | `{}` |
 | metrics.serviceMonitor.enabled |  | bool | `false` |
 | metrics.serviceMonitor.interval |  | string | `"15s"` |
 | metrics.serviceMonitor.scrapeTimeout |  | string | `"10s"` |
 | metrics.serviceType |  | string | `"ClusterIP"` |
 | nameOverride |  | string | `""` |
 | nodeSelector |  | object | `{}` |
 | podAnnotations |  | object | `{}` |
 | podLabels |  | object | `{}` |
 | podSecurityContext |  | object | `{}` |
 | rbac.create |  | bool | `true` |
 | readinessProbe.httpGet.path |  | string | `"/readyz"` |
 | readinessProbe.httpGet.port |  | int | `8081` |
 | readinessProbe.initialDelaySeconds |  | int | `5` |
 | readinessProbe.periodSeconds |  | int | `10` |
 | replicaCount |  | int | `1` |
 | resources |  | object | `{}` |
 | securityContext |  | object | `{}` |
 | serviceAccount.annotations |  | object | `{}` |
 | serviceAccount.create |  | bool | `true` |
 | serviceAccount.name |  | string | `""` |
 | tolerations |  | list | `[]` |
 | webhook.enabled |  | bool | `true` |
 | webhook.port |  | int | `9443` |
 | webhook.serviceAnnotations |  | object | `{}` |
 | webhook.serviceType |  | string | `"ClusterIP"` |

## Contributing

We welcome and appreciate your contributions! Please see the [Contributor Guide](/CONTRIBUTING.md), [Code Of Conduct](/CODE_OF_CONDUCT.md) and [Security Notes](/SECURITY.md) for this repository.
