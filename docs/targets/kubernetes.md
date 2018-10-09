# <img src="../../images/kubernetes.png" height=24> Kubernetes

The kubernetes deployment target generates a kubernetes spec file (`build/k8s.yml`).

!!! example ""
    ```bash
    ansible-deploy -e target=k8s
    ```

### Supported Arguments
| Option         | Description                    | Support                             |
| -------------- | ------------------------------ | ----------------------------------- |
| files          | Map of files to copy           | Planned                             |
| templates      | Map of templates to render     | Planned                             |
| containers     | List of containers to exectute | Yes                                 |
| load_balancers | List of load balancers         | Use container based load balancers  |
| commands       | List of commands to execute.   | Planned                             |
| mounts         | Map of NFS mounts              | Planned                             |
| sysctls        | Sysctl variables to set        | Planned                             |
| env_vars       | Environment variables to set   | ✖ Use container environment instead |

### Extra Arguments ###

| Argument        | Default | Description |
| --------------- | ------- | ----------- |
| docker_registry |         |             |

