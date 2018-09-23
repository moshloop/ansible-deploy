
### Arguments

| Argument       | Default              | Description |
| -------------- | -------------------- | ----------- |
| **image**        | [Required]           | Docker image to run  |
| service | {base image name} | The name of the systemd service |
| env     |                      | A dictionary of environment variables to pass through |
| labels | | A dictionary of labels to add to the container |
| docker_args |                      | Additional arguments to the docker client e.g. `-p 8080:8080` |
| docker_opts | | Additional options to the docker client e.g. `-H unix:///tmp/var/run/docker.sock` |
| args |                   | Additional arguments to the container |
| volumes |                | List of volume mappings |
| ports | | List of port mappings |
| network | user-bridge | |
| cpu |  | |
| mem |  | |
| replicas | 1 | |

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
               docker_args: -p 8080:80
    ```

### Docker Compose
Docker compose can also be used as a source to deploy to any target. Only the attributes listed below are supported:

* ports
* environment
* image
* deploy/limits
* deploy/replicas
* networks (Not supported on ECS)
* ui.labels (See [Load Balancing](../../load-balancing/))

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
<img src="../images/ecs.png" height="24" width=24 /> Implemented as 1 ECS container per task per service using Weave overlay

