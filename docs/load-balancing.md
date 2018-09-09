
### Loadbalancers

### Docker Compose
Load balancers can be specified using annotations in docker-compose files:

!!! example "files/docker-compose.yml"
    ```yaml
    version: "3"
    services:
      ui:
        labels:
          elb.ports: "443:8166"
          elb.type: "https:http"
          elb.scheme: internet-facing
          elb.subnet: Public
          elb.healthcheck-path: "/health"

    ```

### Arguments
| Name                 | Default       | Description     |
| -------------------- | ------------- | --------------- |
| port                 |               |                 |
| type                 | http          | http,https,tcp  |
| scheme               | internal      | internet-facing |
| subnet               | `{{subnet_name}}` |                 |
| healthcheck-path     | /             |                 |
| healthcheck-port     | `{{port}}`        |                 |
| healthcheck-protocol | `{{type}}`        |                 |
| certificate-arn      |               |                 |
| security-groups      |               |                 |
