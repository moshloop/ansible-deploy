
Opionated role for creating shortcuts for various ansible tasks

## Design Principles/Goals

* **Multi-targeting** - The ability to take the same manifest and deploy it to different target environments
* **Convention over configuration** - Only require the most minimal set of information to deploy.
* **Batteries included** - Implement best practises by default, switch to vanilla ansible when the default isn't suitable.
* **Composable** - Multiple and complex environments are assumed. e.g. It should be easy to share manifest between staging and production while at the same time allowing central IT to inject dependencies into multiple deployment manifests to enforce standards.

## Multi-Targeting

#### Supported targets

<img src="images/ansible.png" height=24 align=top> [Ansible](./targets/ansible.md) <br>
<img src="images/ecs.png" height=24 align=top> [AWS ECS](./targets/ecs.md)<br>
<img src="images/cloudinit.png" height=24 width="24" align=top> [cloudinit](./targets/cloudinit.md) <br>
<img src="images/kubernetes.png"  height=24 width="24" align=top> [kubernetes](./targets/kubernetes.md) <br>