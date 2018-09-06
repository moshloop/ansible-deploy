
### Arguments

| Argument       | Default              | Description |
| -------------- | -------------------- | ----------- |
| **image**        | [Required]           | Docker image to run  |
| service | {base image name} | The name of the systemd service |
| env     |                      | A dictionary of environment variables to pass through |
| docker_args |                      | Additional arguments to the docker client e.g. `-p 8080:8080` |
| docker_opts | | Additional options to the docker client e.g. `-H unix:///tmp/var/run/docker.sock` |
| args |                   | Additional arguments to the container |
| volumes |                | List of volume mappings |
| ports | | List of port mappings |
| network | user-bridge | |

``` yaml
- hosts: localhost
  roles:
    - deploy
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

<img src="../images/ansible.png" height="24" width=24 /> Implemented as systemd services that control containers

