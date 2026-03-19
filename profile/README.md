<p align="center">
  <img src="https://raw.githubusercontent.com/privilegedescalation/org/main/privilegedescalation-logo.jpg" alt="Privileged Escalation" width="300" />
</p>

<h3 align="center">Headlamp plugins for the infrastructure you actually run.</h3>

<p align="center">
  <a href="https://artifacthub.io/packages/search?org=privilegedescalation&kind=21">Artifact Hub</a> &middot;
  <a href="https://github.com/sponsors/privilegedescalation">Sponsor</a>
</p>

---

We build open source [Headlamp](https://headlamp.dev) plugins that bring deep visibility into Kubernetes storage, networking, GPU, and security subsystems — right inside your cluster dashboard.

## Our Plugins

| Plugin | What it does | Artifact Hub |
|--------|-------------|:---:|
| [headlamp-rook-plugin](https://github.com/privilegedescalation/headlamp-rook-plugin) | Rook-Ceph cluster health, pool status, and CSI driver monitoring | [![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/headlamp-rook-plugin)](https://artifacthub.io/packages/headlamp/headlamp-rook-plugin/headlamp-rook-plugin) |
| [headlamp-tns-csi-plugin](https://github.com/privilegedescalation/headlamp-tns-csi-plugin) | TrueNAS CSI driver visibility and kbench storage benchmarking | [![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/headlamp-tns-csi-plugin)](https://artifacthub.io/packages/headlamp/headlamp-tns-csi-plugin/headlamp-tns-csi-plugin) |
| [headlamp-sealed-secrets-plugin](https://github.com/privilegedescalation/headlamp-sealed-secrets-plugin) | Manage Bitnami Sealed Secrets with client-side encryption | [![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/headlamp-sealed-secrets-plugin)](https://artifacthub.io/packages/headlamp/headlamp-sealed-secrets-plugin/headlamp-sealed-secrets-plugin) |
| [headlamp-polaris-plugin](https://github.com/privilegedescalation/headlamp-polaris-plugin) | Fairwinds Polaris security and best-practices auditing | [![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/headlamp-polaris-plugin)](https://artifacthub.io/packages/headlamp/headlamp-polaris-plugin/headlamp-polaris-plugin) |
| [headlamp-intel-gpu-plugin](https://github.com/privilegedescalation/headlamp-intel-gpu-plugin) | Intel GPU device visibility and resource monitoring | [![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/headlamp-intel-gpu-plugin)](https://artifacthub.io/packages/headlamp/headlamp-intel-gpu-plugin/headlamp-intel-gpu-plugin) |
| [headlamp-kube-vip-plugin](https://github.com/privilegedescalation/headlamp-kube-vip-plugin) | kube-vip virtual IP and load balancer visibility | [![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/headlamp-kube-vip)](https://artifacthub.io/packages/headlamp/headlamp-kube-vip/headlamp-kube-vip) |

## Why Headlamp?

Headlamp is a CNCF-listed Kubernetes dashboard built for extensibility. Our plugins slot in natively — no separate UIs, no context switching. If you run Headlamp, you can add any of our plugins with a single command.

## Get Started

Every plugin is installable via the Headlamp plugin system. See individual repos for install instructions.

## Contributing

We welcome contributions, bug reports, and feature requests. Open an issue on any repo or start a discussion. All projects are licensed under Apache 2.0.

## Sponsor

If these plugins save your team time, consider [sponsoring our work](https://github.com/sponsors/privilegedescalation). Sponsorship funds go directly toward new plugin development and maintenance.
