Opionated role for creating shortcuts for various ansible tasks

### files

```yaml
files:
  /etc/some/file: file
  /etc/some/file2: file2
```

Shorthand for copying files using [copy](https://docs.ansible.com/ansible/latest/modules/copy_module.html)

### templates
```yaml
templates:
  /etc/some/file: file
  /etc/some/file2: file2
```

Shorthand for templating files using [template](https://docs.ansible.com/ansible/latest/modules/template_module.html)

### containers
```yaml
containers:
 - image: nginx
   env:
     DOMAIN: localhost.com
 - image: nginx
   docker_args: -p 8080:80
```
### Arguments

| Argument       | Default              | Description |
| -------------- | -------------------- | ----------- |
| **image**        | [Required]           | Docker image to run  |
| **service** | base image name       | The name of the systemd service |
| env     |                      | A dictionary of environment variables to pass through |
| docker_args |                      | Additional arguments to the docker client e.g. `-p 8080:8080` |
| docker_opts | | Additional options to the docker client e.g. `-H unix:///tmp/var/run/docker.sock` |
| args |                   | Additional arguments to the container |
| volumes |                |                                       |
| ports |                |                                       |


### Example

```yaml
---
- hosts: localhost
  roles:
    - moshloop.deploy
  vars:
    containers:
     - image: nginx
       service: nginx
       env:
         DOMAIN: localhost.com
     - image: nginx
       service: nginx2
       docker_args: -p 8080:80

```

### mounts
```yaml
mounts:
    "/mnt/point": "nfserver:/volume"
```

Shorthand for mounting volumes using [fstab](https://docs.ansible.com/ansible/latest/modules/fstab_module.html)

### commands
```yaml
commands:
    - echo 123
```

Shorthand for executing shell commands

### sysctl

```yaml
sysctls:
  "vm.max_map_count": 262144
```

Shorthand for applying sysctl settings [sysctl](https://docs.ansible.com/ansible/latest/modules/sysctl_module.html)

### group vars / tasks
Automatically imports vault and variables files

### group tasks
Checks for and runs custom tasks for each group, by dynamically include a task list based on group names.

e.g. group_names == 'web,prod' will look for and run `web.yml` and `prod.yml` in the same directory as the playbook