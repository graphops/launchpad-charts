# templating-test

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square)

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../../ | common | >=0.0.0-0 |

## Values

| Key | Description | Type | Default |
|-----|-------------|------|---------|
 | testComponent.__enabled |  | bool | `true` |
 | testComponent.configMap.__enabled |  | bool | `true` |
 | testComponent.configMap.data.greeting |  | string | `"Hello from {{ .Root.Release.Name }} for {{ .componentName }}"` |
 | testComponent.workload.__enabled |  | bool | `true` |
 | testComponent.workload.kind |  | string | `"Deployment"` |
 | testComponent.workload.spec.replicas |  | string | `"@needs(.Self.configMap.data.greeting as myGreeting)\n@type(int)\n{{ if eq $myGreeting \"Hello from release-name for testComponent\" -}}\n3\n{{ else -}}\n0\n{{ end -}}\n"` |
 | testComponent.workload.spec.selector.matchLabels.app |  | string | `"test-workload"` |
 | testComponent.workload.spec.template.metadata.labels.app |  | string | `"test-workload"` |
 | testComponent.workload.spec.template.spec.containers.main.image |  | string | `"nginx:latest"` |
 | testComponent.workload.spec.template.spec.containers.main.name |  | string | `"main"` |

