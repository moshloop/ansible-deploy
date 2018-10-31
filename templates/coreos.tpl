#cloud-config
hostname: {{inventory_hostname | lower}}
ssh_authorized_keys:
{% for user in users %}
{% for _key in user.ssh_keys | reject('equalto', '') | list %}
{% for key in _key | split("\n") %}
      - "{{key}}"
{% endfor %}
{% endfor %}
{% endfor %}

write_files:
  - path: /etc/systemd/network/00-ens192.network
    content: |
      [Match]
      Name=e*

      [Network]
      DHCP=ipv4
      [DHCP]
      ClientIdentifier=mac