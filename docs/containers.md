
### Arguments

| Argument       | Default              | Description |
| -------------- | -------------------- | ----------- |
| **image**        | [Required]           | Docker image to run  |
| service | {base image name} | The name of the service (e.g systemd unit name or deployment name) |
| env     |                      | A map of environment variables to pass through |
| labels | | A map of labels to add to the container |
| docker_args |                      | Additional arguments to the docker client e.g. `-p 8080:8080` (<img src="../images/ansible_icon.png" style="vertical-align: bottom"/>only) |
| docker_opts | | Additional options to the docker client e.g. `-H unix:///tmp/var/run/docker.sock` (<img src="../images/ansible_icon.png" style="vertical-align: bottom"/> only) |
| args |                   | Additional arguments to the container |
| volumes |                | List of volume mappings |
| ports | | List of port mappings |
| commands | | List of commands to execute inside the container on startup (<img src="../images/k8s_icon.png" style="vertical-align: bottom"> only) |
| files | | Map of files to mount into the container (<img src="../images/k8s_icon.png" style="vertical-align: bottom"> only) |
| templates | | Map of templates to mount into the container (<img src="../images/k8s_icon.png" style="vertical-align: bottom">only) |
| network | user-bridge | <img src="../images/ansible_icon.png" style="vertical-align: bottom"/> only |
| cpu |  | CPU limit in cores (Defaults to 1 on <img src="../images/k8s_icon.png" style="vertical-align: bottom"> ) |
| mem |  | Memory Limit in MB. (Defaults to 1024 on <img src="../images/k8s_icon.png" style="vertical-align: bottom">) |
| replicas | 1 | Number of instances or containers to run |

!!! example "play.yml"
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
               ports:
                  - 8080:80
    ```

### Docker Compose
Docker compose can also be used as a source to deploy to any target. Only the attributes listed below are supported:

* ports
* environment
* image
* deploy/resources/limits
* deploy/replicas
* deploy/endpoint_mode
* networks (<img src="../images/ansible_icon.png" style="vertical-align: bottom"/> only)
* ui.labels (See [Load Balancing](load-balancing/))

!!! example "group_vars/group.yml"

    ```yaml
    docker_compose_v3:
      - files/docker-compose.yml
    ```

!!! example "files/docker-compose.yml"
    ```yaml
    version: "3"
    services:
      gateway:
        image: gateway:4.1.0-SNAPSHOT
        deploy:
          resources:
            limits:
              memory: 2G
        environment:
          - TZ=Africa/Harare
        ports:
          - "8166:8166"
        networks:
          - user
    networks:
      user:
        external:
          name: public

    ```

<img src="../images/ansible.png" height="24" width=24 /> Implemented as systemd services that controls container <br>
<img src="../images/ecs.png" height="24" width=24 /> Implemented as 1 ECS container per task per service using Weave overlay <br>
<img src="../images/kubernetes.png" height="24" width=24 /> Converted into a K8s Deployment and Service