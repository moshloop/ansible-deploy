# <img src="../../images/ansible.png" height=24>  Ansible
| Option           | Description                                  | Support |
| ---------------- | -------------------------------------------- | -------- |
| files            | Map of files to copy                         | [native copy](https://docs.ansible.com/ansible/latest/modules/copy_module.html) module |
| templates | Map of templates to render | [native template](https://docs.ansible.com/ansible/latest/modules/template_module.html) module |
| containers       | List of containers to exectute               | [docker_systemd_service](https://github.com/moshloop/docker-systemd-service) role |
| commands        | List of commands to execute.                 | native [shell](https://docs.ansible.com/ansible/latest/modules/shell_module.html) module |
| mounts | Map of NFS mounts | native [fstab](https://docs.ansible.com/ansible/latest/modules/fstab_module.html) module |
| sysctls | Sysctl variables to set | native [sysctl](https://docs.ansible.com/ansible/latest/modules/sysctl_module.html) module |
| env_vars | Environment variables to set | `/etc/environment`|