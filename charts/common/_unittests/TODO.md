# Test Cases Todo List

## 1. Layout Tests (/layout-tests) ✓
- [x] Single Component
  - Basic workload deployment test
  - Value inheritance test
- [x] Multiple Components
  - Multiple component rendering
  - Shared defaults inheritance
  - Component-specific overrides
- [x] Dynamic Components
  - Dynamic component discovery
  - Enabled/disabled components
  - Default layering inheritance

## 2. Resource Tests (/resource-tests)
- [x] All Resource Kinds
  - ConfigMap generation
  - PodDisruptionBudget generation
  - Role generation
  - RoleBinding generation
  - Secret generation
  - Service generation
  - ServiceAccount generation
  - ServiceMonitor generation
  - Workload (Deployment/StatefulSet) generation

## 3. Definition Blocks (/definition-blocks)
- [x] deepMerge Function
  - Basic map merging
  - Nested structure merging
  - Null value handling
- [x] transformMapToList Function
  - Basic map to list conversion
  - Custom index key usage
  - Default value handling

## 4. Templating Tests (/templating-tests)
- [x] Template Variable References
  - .Self reference usage
  - .Root reference usage
  - .componentName reference usage
- [x] Preprocessing Directives
  - @needs directive
  - @type directive
  - Complex template resolution

## Progress Tracking
- [x] Layout Tests - Single Component
- [x] Layout Tests - Multiple Components
- [x] Layout Tests - Dynamic Components
- [ ] Resource Tests - All Resource Kinds
- [x] Definition Blocks Tests - deepMerge
- [x] Definition Blocks Tests - transformMapToList
- [x] Templating Tests

Note: Checkmarks indicate completed test implementations
