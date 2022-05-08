# Resource-Injector Helm Chart

Manage Raw Kubernetes Resources using Helm

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) ![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

## Usage

Set `resources` to an array of Kubernetes Resources to inject into the Helm Release.

Example:

```yaml
# values.yaml

resources:
  - apiVersion: v1
    kind: Secret
    metadata:
      name: mysecret
    type: Opaque
    data:
      username: YWRtaW4=
      password: MWYyZDFlMmU2N2Rm
  - apiVersion: v1
    kind: Service
    metadata:
      name: my-service
    spec:
      selector:
        app: MyApp
      ports:
        - protocol: TCP
          port: 80
          targetPort: 9376
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| resources | list | `[]` | Resources in the release. Each entry should be YAML for a valid Kubernetes Resource. |

## Contributing

We welcome and appreciate your contributions! Please see the [Contributor Guide](/CONTRIBUTING.md), [Code Of Conduct](/CODE_OF_CONDUCT.md) and [Security Notes](/SECURITY.md) for this repository.