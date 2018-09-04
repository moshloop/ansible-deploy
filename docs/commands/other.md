### whilp/ssh-agent
```bash
docker run -u 1001 --rm -d -v ssh:/ssh --name=ssh-agent whilp/ssh-agent:latest
docker run -u 1001 --rm -v ssh:/ssh -v $HOME:$HOME -it whilp/ssh-agent:latest ssh-add $HOME/.ssh/id_rsa
```

### ansible-role
```bash
ansible-role moshloop.java # cross-platform install of java
```
### ansible-vault-run

`ansible-vault-run` will decrypt a vault and run a script with the variables exported as environment variables
    echo "Decrypts an ansible-vault and runs script with the contents as environment variables"
```bash
ansible-vault-run vault "echo \$password"
```