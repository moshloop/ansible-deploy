`ansible-deploy` is a tool that simplifies deploying applications to different target environments.

**Supported targets**

<img src="images/ansible_icon.png"  align=top> [Ansible](./targets/ansible.md) <br>
<img src="images/ecs.png"> [AWS ECS](./targets/ecs.md)<br>
<img src="images/cloudinit.png"  align=top> [cloudinit](./targets/cloudinit.md) <br>
<img src="images/k8s_icon.png"   align=top> [kubernetes](./targets/kubernetes.md) <br>

## Installing

### Using via PIP/CLI

Using ansible-deploy via pip simplifies the installation and versioning of the primary role. The CLI also handles versioning of the role and running the role without a playbook transparently.

**Install**
```bash
pip install ansible-deploy
# optionally pre-download the playbook for use in Docker images etc..
ansible-deploy install
```
**Run**
```bash
# run the deployment using the inventory defined in the $PWD/inventory directory
ansible-deploy
# run the deployment using a custom inventory
ansible-deploy -i inventory/test
```

!!! tip
    Any of the arguments of `ansible-playbook` can be used with `ansible-deploy` e.g. --limit, --check

**Freezing the version**

The CLI  will automatically checkout and use the tag specified in the `ansible_deploy_version` variable supplied in the inventory. Freezing the version is useful when working with multiple versions of `ansible-deploy` across different projects.

### Using the native playbook

ansible-deploy can also be used as a normal ansible role and imported into an existing playbook

**Install**
```bash
ansible-galaxy install moshloop.deploy
```

**Import**
```yaml
---
- hosts: all
  gather_facts: false
  roles:
    - moshloop.deploy
```

## Design Principles/Goals

* **Multi-targeting** - The ability to take the same manifest and deploy it to different target environments
* **Convention over configuration** - Only require the most minimal set of information to deploy.
* **Batteries included** - Implement best practises by default, switch to vanilla ansible when the default isn't suitable.
* **Composable** - Multiple and complex environments are assumed. e.g. It should be easy to share manifest between staging and production while at the same time allowing central IT to inject dependencies into multiple deployment manifests to enforce standards.
