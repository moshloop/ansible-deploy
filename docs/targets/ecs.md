# <img src="../../images/ecs.png" height=24> AWS ECS

The ECS deployment target generates a cloudformation template (`build/ecs.yml`) with all the components needed to create and deploy to an ECS cluster. It will then upload and execute the cloudformation script used the provided arguments.

!!! example ""

​    

### Supported Arguments

| Option         | Description                    | Support                             |
| -------------- | ------------------------------ | ----------------------------------- |
| files          | Map of files to copy           | ✖                                   |
| templates      | Map of templates to render     | ✖                                   |
| containers     | List of containers to exectute | Uses ECS Services/Tasks             |
| load_balancers | List of load balancers         | Uses Application Load Balancers     |
| commands       | List of commands to execute.   | ✖                                   |
| mounts         | Map of NFS mounts              | ✖                                   |
| sysctls        | Sysctl variables to set        | ✖                                   |
| env_vars       | Environment variables to set   | ✖ Use container environment instead |

### Extra Arguments ###

| Argument            | Default                                           | Description                               |
| ------------------- | ------------------------------------------------- | ----------------------------------------- |
| **cluster_name**    | {{envFull}}                                       |                                           |
| **account_id**      |                                                   | AWS Account ID                            |
| **domain_id**       |                                                   | Route53 Domain ID                         |
| **domain**          |                                                   |                                           |
| **region**          |                                                   | AWS Region                                |
| **cluster_size**    | 3                                                 | Initial size of Auto Scaling Group        |
| **docker_registry** | `{{account_id}}.dkr.ecr.{{region}}.amazonaws.com` |                                           |
| log_retention       | 7                                                 | Number of days to retain CloudWatch logs  |
| ssh_key_name        |                                                   |                                           |
| default_ssl_arn     |                                                   |                                           |
| ecs_instance_type   | c4.xlarge                                         |                                           |
| ecs_image_id        | ami-0254e5972ebcd132c                             | ECS AMI Image ID                          |
| subnet_name         | APP                                               | Subnet prefix to place ECS instances into |
