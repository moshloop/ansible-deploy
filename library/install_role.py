import os

from distutils.spawn import find_executable
from subprocess import check_call
from ansible.module_utils.basic import AnsibleModule

def install_role(name, url):
    getter = find_executable('go-getter2')
    git = find_executable('git')
    dir = "roles/%s" % name
    if not os.path.isdir("roles"):
        os.mkdir("roles")
    if getter is not None:
        if url.startswith("http") and ".git" in url:
            url = "git::" + url
        return check_call([getter,url, "roles/%s/" % name])
    elif git is not None:
        ref = None
        if "?ref=" in url:
            ref = url.split("?ref=")[1]
            url = url.split("?ref=")[0]

        if not os.path.isdir(dir + "/.git"):
            response = check_call([git, "clone", url, "roles/%s/" % name])
        if ref is not None:
            check_call([git, "fetch"], cwd="roles/%s/" % name)
            check_call([git, "reset", ref], cwd="roles/%s/" % name)
    else:
        module.fail_json("Must install either git or go-getter")

def main():
    arg_spec = dict(
        name=dict(required=True),
        url=dict(required=True)
    )

    module = AnsibleModule(argument_spec=arg_spec, supports_check_mode=False)

    install_role(module.params.get('name'), module.params.get('url'))


    module.exit_json(changed=False)


if __name__ == '__main__':
    install_role("test", "https://github.com/moshloop/ansible-extras.git?ref=758c5255864a43aa252456c5a0c8b14162fc77bd")