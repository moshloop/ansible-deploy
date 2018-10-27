# <img src="../../images/kubernetes.png" height=24> Kubernetes

The kubernetes deployment target generates a kubernetes spec file (`build/k8s.yml`) and applies it using `kubectl`

!!! example ""
    ```bash
    ansible-deploy -e target=k8s
    ```

### Supported Arguments

Arguments can either be applied at the group level or the individual container level. If an argument is specified at the container level, it is *not* merged with the group level argument.

| Option         | Description                    | Support                             |
| -------------- | ------------------------------ | ----------------------------------- |
| files          | Map of files to copy           | Using ConfigMaps                             |
| templates      | Map of templates to render     | Using ConfigMaps                                |
| [containers](../../containers)     | List of containers to exectute | Using Deployment's and Service's                              |
| load_balancers | List of load balancers         | ✖ Use service_type instead  |
| commands       | List of commands to execute.   | Using Lifecycle/PostStart Hook                             |
| mounts         | Map of NFS mounts              | ✖ Planned                             |
| volumes        | Map of host volume mounts      |           |
| sysctls        | Sysctl variables to set        | ✖ Planned                             |
| env_vars\|env       | Environment variables to set   | Supported |

#### Extra Arguments

| Argument        | Default | Description |
| --------------- | ------- | ----------- |
| docker_registry |         |             |
| docker_registry_host |         |             |



### Kustomize

The spec can be customized using the [kustomize](https://github.com/kubernetes-sigs/kustomize) tool. To use place a `kustomization.yml` file in the `k8s` directory.


### Check Mode

Check mode is supported, it will use `kubectl --dry-run=true` under the hood.

!!! example ""
    ```bash
    ansible-deploy --check
    ```

