# Openebs-Rawfile-Localpv Helm Chart

RawFile Driver Container Storage Interface

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) ![Version: 0.8.3](https://img.shields.io/badge/Version-0.8.3-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.8.0](https://img.shields.io/badge/AppVersion-0.8.0-informational?style=flat-square)

## Features

- Actively maintained by [GraphOps](https://graphops.xyz) and contributors, forked from [Openebs Rawfile-localpv](https://github.com/openebs/rawfile-localpv)
- Includes RBAC
- Support for `ServiceMonitor`s to configure Prometheus to scrape metrics ([prometheus-operator](https://github.com/prometheus-operator/prometheus-operator))

## Reasons to consider using node-based (rather than network-based) storage solutions:

Performance: Almost no network-based storage solution can keep up with baremetal disk performance in terms of IOPS/latency/throughput combined. And you’d like to get the best out of the SSD you’ve got!
On-premise Environment: You might not be able to afford the cost of upgrading all your networking infrastructure, to get the best out of your network-based storage solution.
Complexity: Network-based solutions are distributed systems. And distributed systems are not easy! You might want to have a system that is easier to understand and to reason about. Also, with less complexity, you can fix unpredicted issues more easily.
Using node-based storage has come a long way since k8s was born. Right now, OpenEBS’s hostPath makes it pretty easy to automatically provision hostPath PVs and use them in your workloads. There are known limitations though:

- You can’t monitor volume usage: There are hacky workarounds to run “du” regularly, but that could prove to be a performance killer, since it could put a lot of burden on your CPU and cause your filesystem cache to fill up. Not really good for a production workload.
- You can’t enforce hard limits on your volume’s size: Again, you can hack your way around it, with the same caveats.
- You are stuck with whatever filesystem your kubelet node is offering
- You can’t customize your filesystem:
- All these issues stem from the same root cause: hostPath/LocalPVs are simple bind-mounts from the host filesystem into the pod.

The idea here is to use a single file as the block device, using Linux’s loop, and create a volume based on it. That way:

You can monitor volume usage by running df in O(1) since devices are mounted separately.
The size limit is enforced by the operating system, based on the backing file size.
Since volumes are backed by different files, each file could be formatted using different filesystems, and/or customized with different filesystem options.

## Quickstart

To install the chart with the release name `my-release`:

```console
$ helm repo add graphops http://graphops.github.io/launchpad-charts
$ helm install my-release graphops/openebs-rawfile-localpv
```

## Upgrading

We recommend that you pin the version of the Chart that you deploy. You can use the `--version` flag with `helm install` and `helm upgrade` to specify a chart version constraint.

This project uses [Semantic Versioning](https://semver.org/). Changes to the version of the application (the `appVersion`) that the Chart deploys will generally result in a patch version bump for the Chart. Breaking changes to the Chart or its `values.yaml` interface will be reflected with a major version bump.

We do not recommend that you upgrade the application by overriding `image.tag`. Instead, use the version of the Chart that is built for your desired `appVersion`.

## Values

| Key | Description | Type | Default |
|-----|-------------|------|---------|
 | controller.<<.image.pullPolicy |  | string | `"Always"` |
 | controller.<<.image.repository |  | string | `"docker.io/openebs/rawfile-localpv"` |
 | controller.<<.image.tag |  | string | `"v0.10.0"` |
 | controller.<<.resources.limits.cpu |  | int | `1` |
 | controller.<<.resources.limits.memory |  | string | `"100Mi"` |
 | controller.<<.resources.requests.cpu |  | string | `"10m"` |
 | controller.<<.resources.requests.memory |  | string | `"100Mi"` |
 | controller.<<.tolerations |  | list | `[]` |
 | defaults.image.pullPolicy |  | string | `"Always"` |
 | defaults.image.repository |  | string | `"docker.io/openebs/rawfile-localpv"` |
 | defaults.image.tag |  | string | `"v0.10.0"` |
 | defaults.resources.limits.cpu |  | int | `1` |
 | defaults.resources.limits.memory |  | string | `"100Mi"` |
 | defaults.resources.requests.cpu |  | string | `"10m"` |
 | defaults.resources.requests.memory |  | string | `"100Mi"` |
 | defaults.tolerations |  | list | `[]` |
 | imagePullSecrets |  | list | `[]` |
 | node.<<.image.pullPolicy |  | string | `"Always"` |
 | node.<<.image.repository |  | string | `"docker.io/openebs/rawfile-localpv"` |
 | node.<<.image.tag |  | string | `"v0.10.0"` |
 | node.<<.resources.limits.cpu |  | int | `1` |
 | node.<<.resources.limits.memory |  | string | `"100Mi"` |
 | node.<<.resources.requests.cpu |  | string | `"10m"` |
 | node.<<.resources.requests.memory |  | string | `"100Mi"` |
 | node.<<.tolerations |  | list | `[]` |
 | node.data_dir_path |  | string | `"/data"` |
 | node.metrics.enabled |  | bool | `false` |
 | provisionerName |  | string | `"rawfile.csi.openebs.io"` |
 | serviceMonitor.enabled |  | bool | `false` |
 | serviceMonitor.interval |  | string | `"1m"` |

## Contributing

We welcome and appreciate your contributions! Please see the [Contributor Guide](/CONTRIBUTING.md), [Code Of Conduct](/CODE_OF_CONDUCT.md) and [Security Notes](/SECURITY.md) for this repository.