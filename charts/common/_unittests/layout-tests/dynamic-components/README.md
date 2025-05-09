# dynamic-components-test

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square)

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../../.. | common | >=0.0.0-0 |

## Values

| Key | Description | Type | Default |
|-----|-------------|------|---------|
 | defaultLayer.__enabled |  | bool | `true` |
 | defaultLayer.workload.__enabled |  | bool | `true` |
 | defaultLayer.workload.__enabled |  | bool | `true` |
 | defaultLayer.workload.kind |  | string | `"Deployment"` |
 | defaultLayer.workload.kind |  | string | `"Deployment"` |
 | defaultLayer.workload.spec.selector.matchLabels.app |  | string | `"test-workload"` |
 | defaultLayer.workload.spec.template.metadata.labels.app |  | string | `"test-workload"` |
 | defaultLayer.workload.spec.template.spec.containers.main.image |  | string | `"nginx:latest"` |
 | defaultLayer.workload.spec.template.spec.containers.main.image |  | string | `"nginx:latest"` |
 | defaultLayer.workload.spec.template.spec.containers.main.name |  | string | `"main"` |
 | defaultLayer.workload.spec.template.spec.containers.main.name |  | string | `"main"` |
 | dynamicComponents.component-a.__enabled |  | bool | `true` |
 | dynamicComponents.component-a.workload.__enabled |  | bool | `true` |
 | dynamicComponents.component-a.workload.metadata.name |  | string | `"component-a"` |
 | dynamicComponents.component-a.workload.spec.replicas |  | int | `4` |
 | dynamicComponents.component-b.__enabled |  | bool | `false` |
 | dynamicComponents.component-b.workload.__enabled |  | bool | `true` |
 | dynamicComponents.component-b.workload.metadata.name |  | string | `"component-b"` |
 | dynamicComponents.component-b.workload.spec.replicas |  | int | `2` |
 | dynamicComponents.component-c.__enabled |  | bool | `true` |
 | dynamicComponents.component-c.workload.__enabled |  | bool | `true` |
 | dynamicComponents.component-c.workload.metadata.name |  | string | `"component-c"` |
 | dynamicComponents.component-c.workload.spec.replicas |  | int | `3` |

