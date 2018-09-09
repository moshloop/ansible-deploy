## Filters

| name                                          | description                                                  |
| --------------------------------------------- | ------------------------------------------------------------ |
| **dir_exists**(path)                          |                                                              |
| **file_exists**(path)                         |                                                              |
| **from_si_unit**(number, base_unit)            | Converts a SI unit e.g. 1GB into a number with an optional base
| **is_empty**(val)                             |                                                              |
| **jsonpath**(data)                            | transforms data using `jsonpath_rw`                           |
| **map_to_entries**(dict, key, value)          | Convert a dict into a list of entries                        |
| **nestedelement**(path)                       | Returns an nested element from an object tree by path (seperated by / or .) |
| **play_groups**(play_hosts, groups, hostvars) | Returns a list of groups that are active within a play       |
| **split**(string, separator=' ')              |                                                              |
| **sub_map**(dict, prefix)                     | Filter a map by key prefix and remove prefix from keys       |
| **to_map**(map, key, value)                   |                                                              |
| **walk_up**(object, path)                     | Walks up an object tree from the lowest level collecting all attributes not available at lower levels |


### dir_exists
```python
when: "'/path/to/dir' | dir_exists"
```
### file_exists
```python
when: "'/path/to/file' | file_exists"
```

### from_si_unit
```python
'1GB' | from_si_unit('MB') == 1024
```
### is_empty
```python
' ' | is_empty == true
```
### jsonpath
### map_to_entries
### nestedelement
### play_groups
### split
```python
'one two' | split == ['one', 'two']
```
### to_map
### walk_up
### sub_map

```python
sub_map({
        "elb.check": "/health",
        "elb.port": "100",
        "don.t": "match"
      }, "elb.") == {"check": "/health", "port": "100"}
```

## Modules

#### cloudinit_iso

!!! example
    ```yaml
    - cloudinit_iso:
        dest: "{{playbook_dir}}/cloudinit.iso"
        user: |
          #cloud-config
          preserve_hostname: true
          hostname: ansible-hostname
          users:
              - name: hostname
    ```

!!! info "Depdenencies"
    `genisoimage`

#### systemd_service

| Option      | Default           | Required | Description                                               |
| ----------- | ----------------- | -------- | --------------------------------------------------------- |
| ExecStart   |                   | Yes      |                                                           |
| Name        |                   | Yes      |                                                           |
| Description |                   |          |                                                           |
| Restart     | on-failure        |          |                                                           |
| RunAs       | root              |          |                                                           |
| ServiceArgs |                   |          | A dict of key values to add under the `[service]` section |
| UnitArgs    |                   |          | A dict of key values to add under the `[unit]` section    |
| WantedBy    | multi-user.target |          |                                                           |
| state       | present           |          |                                                           |

!!! example
    ```yaml
    - hosts: all
      roles:
        - moshloop.systemd
      tasks:
          - systemd_service:
              Name: test
              ExecStart: "/usr/bin/nc -l 200"
          - systemd_service:
              Name: test
              ExecStart: "/usr/bin/nc -l 200"
              UnitArgs:
                  After: networking.service
    ```
