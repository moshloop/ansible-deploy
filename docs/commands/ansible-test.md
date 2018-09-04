# ansible-test

`ansible-test` will test a playbook using a docker container:

```bash
ansible-test playbook.yml # defaults to centos7
image=ubuntu1804 ansible-test playbook.yml
```

The playbook will be tested for idempotency by running it a 2nd time and ensuring nothing is marked as changed, disable it with:
```bash
idempotency=false ansible-test playbook.yml
```

Once the playbook is run any [InSpec](https://www.inspec.io) (.rb) or [bats](https://github.com/sstephenson/bats) (.bats) tests found with the same name (e.g. `playbook.rb`) will be executed.

See it in action [here](https://github.com/moshloop/ansible-java/tree/master/tests)
