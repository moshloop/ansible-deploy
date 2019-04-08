#cloud-config
preserve_hostname: true
package_update: false
hostname: {{inventory_hostname | lower}}
{{ cloud_init | default('')}}
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
{% if sysctls is defined %}
    - path: /etc/sysctl.d/100-cloud-init.conf
      content:
{% for sysctl in sysctls %}
        {{sysctl}}={{sysctls[sysctl]}}
{% endfor %}
{% endif %}
{% for file in files %}
    - path: {{file}}
      encoding: b64
      content: {{ lookup('file', files[file]) | b64encode }}
{% endfor %}
{% for template in templates | default({}) %}
    - path: {{template}}
      encoding: b64
      content: {{ lookup('template', templates[template]) | b64encode }}
{% endfor %}
    - path: /usr/bin/bootstrap_volumes.sh
      permissions: '0755'
      content: |
        #!/bin/bash
        if cat /etc/os-release | grep rhel; then
          if ! which bootstrap_volume 2&>1 > /dev/null; then
              echo "Systools not detected, installing..."
              rpm -i https://github.com/moshloop/systools/releases/download/3.1/systools-3.1-1.x86_64.rpm
          fi

          if [[ -e /sbin/mkfs.xfs ]]; then
            echo "xfs not installed, installing..."
            yum install -y xfsprogs xfsdump
          fi
        else
          echo "Non RHEL based OS, skipping bootstrap"
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
        echo {{inventory_hostname | lower}}.{{internal_domain}} > /etc/hostname
        hostnamectl set-hostname --static --transient {{inventory_hostname | lower}}.{{internal_domain}}
        sed -i "s|127.0.1.1.*|127.0.1.1 $(hostname)|" /etc/hosts
        sed -i "s|127.0.0.1.*|127.0.0.1 $(hostname)|" /etc/hosts
{% for cmd in pre_commands | default([]) | flatten %}
        {{cmd | indent(8) }}
{% endfor %}
{% for container in containers | default([]) %}
{{ container | debug_obj }}
{% set service = container.service | default(container.image | basename) | split(':') | first %}
        systemctl enable {{service }}
        systemctl start {{service }}
{% endfor %}
{% for cmd in commands | default([]) | flatten %}
        {{cmd | indent(8) }}
{% endfor %}
{% for cmd in phone_home | default([]) %}
        {{cmd}}
{% endfor %}
runcmd:
{% for pkg in packages | default([]) %}
    - [ cloud-init-per, instance, install-{{pkg | basename | splitext | first}}, sh, "-c", "/usr/bin/rpm -U {{pkg}}"]
{% endfor %}

    - [ cloud-init-per, instance, cloudinit, "/usr/bin/cloudinit.sh" ]
    - [ cloud-init-per, instance, bootstrap, "/usr/bin/bootstrap_volumes.sh" ]