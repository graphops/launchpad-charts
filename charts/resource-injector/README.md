# Resource-Injector Helm Chart

Manage Raw Kubernetes Resources using Helm

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) ![Version: 0.2.0](https://img.shields.io/badge/Version-0.2.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

## Usage

Set `resources` to an object, with each value being a Kubernetes Resources to inject into the Helm Release. The name of the key does not matter, but can be used to reference an object and override values in a layered values.yaml approach.

Example:

```yaml
# values.yaml

resources:
  secret1:
    apiVersion: v1
    kind: Secret
    metadata:
      name: mysecret
    type: Opaque
    data:
      username: YWRtaW4=
      password: MWYyZDFlMmU2N2Rm
  secret2:
    apiVersion: v1
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

| Key | Description | Type | Default |
|-----|-------------|------|---------|
 | resources | Resources in the release. Each map value should be YAML for a valid Kubernetes Resource. The name of the key does not matter, other than for overriding values. | object | `{}` |

## Contributing

We welcome and appreciate your contributions! Please see the [Contributor Guide](/CONTRIBUTING.md), [Code Of Conduct](/CODE_OF_CONDUCT.md) and [Security Notes](/SECURITY.md) for this repository.
