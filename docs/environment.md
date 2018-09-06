
``` yaml
- hosts: localhost
  roles:
    - deploy
  vars:
    env_vars:
      httpProxy: 127.0.0.1
  tasks:
    - name: Testing
      shell: "cat /etc/environment | grep httpProxy"

```