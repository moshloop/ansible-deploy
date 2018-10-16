#cloud-config
preserve_hostname: true
package_update: false
hostname: {{inventory_hostname | lower}}
{% if users is defined and users | length > 0 %}
users:
{% for user in users %}
    - name: {{user.name}}
      ssh-authorized-keys:
{% for _key in user.ssh_keys | reject('equalto', '') | list %}
{% for key in _key | split("\n") %}
        - {{key}}
{% endfor %}
{% endfor %}
{% endfor %}
{% endif %}

write_files:
{% for file in files %}
    - path: {{file}}
      encoding: b64
      content: {{ lookup('file', files[file]) | b64encode }}
{% endfor %}
    - path: /usr/bin/bootstrap_volumes.sh
      permissions: '0755'
      content: |
        #!/bin/bash

        if ! which bootstrap_volume 2&>1 > /dev/null; then
            echo "Systools not detected, installing..."
            rpm -i https://github.com/moshloop/systools/releases/download/3.2/systools-3.2-1.x86_64.rpm
        fi

        if [[ -e /sbin/mkfs.xfs ]]; then
          echo "xfs not installed, installing..."
          yum install -y xfsprogs xfsdump
        fi
{% if volumes is defined %}
{% for vol in volumes %}
{% if vol.format is defined %}
        bootstrap_volume {{vol.dev}} {{vol.mount}} {{vol.format}} {{vol.owner | default('""')}} {{vol.size | default('')}}
{% endif %}
{% endfor %}
{% endif %}
{% if instance_volumes is defined %}
{% for vol in instance_volumes %}
{% if vol.format is defined %}
        bootstrap_volume {{vol.dev}} {{vol.mount}} {{vol.format}} {{vol.owner | default('""')}} {{vol.size | default('')}}
{% endif %}
{% endfor %}
{% endif %}
    - path: /usr/bin/cloudinit.sh
      permissions: '0755'
      content: |
        #!/bin/bash

{% for key in env_vars %}
{% if env_vars[key] != "" %}
        echo {{key}}={{env_vars[key]}} >> /etc/environment
{% endif %}
{% endfor %}
{% if aws_bootstrap is defined %}
        /usr/bin/aws_environment_updater
        . /etc/environment
        aws configure set region $AWS_REGION
{% endif %}
        echo {{inventory_hostname | lower}}.{{internal_domain}} > /etc/hostname
        hostnamectl set-hostname --static {{inventory_hostname | lower}}.{{internal_domain}}

{% for cmd in commands | default([]) %}
        {{cmd}}
{% endfor %}
{% for cmd in phone_home | default([]) %}
        {{cmd}}
{% endfor %}

runcmd:
{% for pkg in packages %}
    - [ cloud-init-per, instance, install-{{pkg | basename | splitext | first}}, sh, "-c", "/usr/bin/rpm -U {{pkg}}"]
{% endfor %}

    - [ cloud-init-per, instance, cloudinit, "/usr/bin/cloudinit.sh" ]
    - [ cloud-init-per, instance, bootstrap, "/usr/bin/bootstrap_volumes.sh" ]