#cloud-config
preserve_hostname: true
package_update: false
hostname: {{inventory_hostname | lower}}
{% if users is defined and users | length > 0 %}
users:
{% for user in users %}
    - name: {{user.name}}
      ssh-authorized-keys:
{% for key in user.ssh_keys | reject('equalto', '') %}
        - {{key}}
{% endfor %}
{% endfor %}
{% endif %}

write_files:
{% for file in files %}
    - path: {{file}}
      encoding: b64
      content: {{ lookup('file', files[file]) | b64encode }}
{% endfor %}
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
{% if volumes is defined %}
{% for vol in volumes %}
{% if vol.format is defined %}
    - [ cloud-init-per, always, bootstrap-volume-{{vol.id}}, /usr/bin/bootstrap_volume, "{{vol.dev}}","{{vol.mount}}","{{vol.format}}","{{vol.owner | default('')}}","{{vol.size | default('')}}"]
{% endif %}
{% endfor %}
{% endif %}
{% if instance_volumes is defined %}
{% for vol in instance_volumes %}
{% if vol.format is defined %}
    - [ cloud-init-per, always, bootstrap-volume-{{vol.mount | regex_replace("/", "_")}}, /usr/bin/bootstrap_volume,  "{{vol.dev}}","{{vol.mount}}","{{vol.format}}","{{vol.owner | default('')}}","{{vol.size | default('')}}"]
{% endif %}
{% endfor %}
{% endif %}
    - [ cloud-init-per, instance, bootstrap, "/usr/bin/cloudinit.sh" ]