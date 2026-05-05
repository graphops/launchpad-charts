# Reth Dashboard Provenance

The dashboards in this directory are vendored from the upstream Reth repository:

- Source repository: `https://github.com/paradigmxyz/reth`
- Source directory: `etc/grafana/dashboards`
- Vendored commit: `d577814eb1c3bbf6393448dcabd0d152ce45ccc4`
- Upstream license: Reth is distributed under Apache-2.0 OR MIT.

Each included dashboard is expected to be aligned with this chart's workload: a Reth node exposing its built-in Prometheus metrics endpoint through `reth.metrics.enabled`. Dashboards that require external workloads are not included.

| Dashboard | Source path | Vendored version | Workload alignment |
| --- | --- | --- | --- |
| `overview.json` | `etc/grafana/dashboards/overview.json` | `d577814eb1c3bbf6393448dcabd0d152ce45ccc4` | Aligned: uses Reth Prometheus metrics. |
| `reth-discovery.json` | `etc/grafana/dashboards/reth-discovery.json` | `d577814eb1c3bbf6393448dcabd0d152ce45ccc4` | Aligned: uses Reth discovery Prometheus metrics. |
| `reth-mempool.json` | `etc/grafana/dashboards/reth-mempool.json` | `d577814eb1c3bbf6393448dcabd0d152ce45ccc4` | Aligned: uses Reth transaction pool and network Prometheus metrics. |
| `reth-persistence.json` | `etc/grafana/dashboards/reth-persistence.json` | `d577814eb1c3bbf6393448dcabd0d152ce45ccc4` | Aligned: uses Reth storage/persistence Prometheus metrics. |
| `reth-state-growth.json` | `etc/grafana/dashboards/reth-state-growth.json` | `d577814eb1c3bbf6393448dcabd0d152ce45ccc4` | Aligned: uses Reth database/static-file Prometheus metrics. |

`metrics-exporter.json` from the same upstream directory is intentionally excluded. It is the Ethereum Metrics Exporter dashboard and requires the separate `ethereum-metrics-exporter` workload, which this chart does not deploy.

When updating dashboards, refresh from a pinned upstream commit, re-check that every query is backed by metrics emitted by this chart's Reth workload, and update this file plus the dashboard metadata watermarks.
