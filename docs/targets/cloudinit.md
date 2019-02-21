
# <img src="../../images/cloudinit.png" height=24> Cloud init

The cloudinit target will generate a config file (`build/{{inventory_hostname}}.txt`) suitable for use in tools like AWS User Data etc. [ansible-provision](https://www.moshloop.com/ansible-provision) uses this target to trigger mount and format volumes on start and to trigger deployment scripts.

### Supported Arguments
| Option         | Description                    | Support                             |
| -------------- | ------------------------------ | ----------------------------------- |
| files          | Map of files to copy           | Yes                                  |
| templates      | Map of templates to render     | Yes                                   |
| containers     | List of containers to exectute | Yes            |
| load_balancers | List of load balancers         | ✖     |
| commands       | List of commands to execute.   | Yes                                  |
| mounts         | Map of NFS mounts              | Yes                                   |
| sysctls        | Sysctl variables to set        | Yes                                   |
| env_vars       | Environment variables to set   | Yes |