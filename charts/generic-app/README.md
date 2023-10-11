# Generic-App Helm Chart

A generic app chart

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) ![Version: 0.1.1](https://img.shields.io/badge/Version-0.1.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: generic-app](https://img.shields.io/badge/AppVersion-generic--app-informational?style=flat-square)

## Introduction

This is generic chart for deploying applications using `Deployment`s or `StatefulSet`s, alongside `Service`s, `ConfigMap`s and `Secret`s.

## Chart Features

- Actively maintained by [GraphOps](https://graphops.xyz) [and contributors](https://github.com/graphops/launchpad-charts/graphs/contributors)

## Quickstart

To install the chart with the release name `my-release`:

```console
$ helm repo add graphops http://graphops.github.io/launchpad-charts
$ helm install my-release graphops/generic-app
```

## Configuring generic-app

...

## Upgrading

We recommend that you pin the version of the Chart that you deploy. You can use the `--version` flag with `helm install` and `helm upgrade` to specify a chart version constraint.

This project uses [Semantic Versioning](https://semver.org/). Changes to the version of the application (the `appVersion`) that the Chart deploys will generally result in a patch version bump for the Chart. Breaking changes to the Chart or its `values.yaml` interface will be reflected with a major version bump.

We do not recommend that you upgrade the application by overriding `image.tag`. Instead, use the version of the Chart that is built for your desired `appVersion`.

## Values

| Key | Description | Type | Default |
|-----|-------------|------|---------|
 | apps | Applications to deploy | object | `{}` |
 | configMaps | ConfigMaps to create | object | `{}` |
 | fullnameOverride |  | string | `""` |
 | ingress | Ingress | object | `{"annotations":{},"enabled":false,"hosts":[{"host":"chart-example.local","paths":[]}],"tls":[]}` |
 | nameOverride |  | string | `""` |
 | secrets | Secrets to create | object | `{}` |

## Contributing

We welcome and appreciate your contributions! Please see the [Contributor Guide](/CONTRIBUTING.md), [Code Of Conduct](/CODE_OF_CONDUCT.md) and [Security Notes](/SECURITY.md) for this repository.
