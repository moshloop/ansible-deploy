from subprocess import *
from setuptools import setup, find_packages
from setuptools.command.install import install
from ansible_deploy import __version__
import os
import shutil
from os.path import isfile


__name__ = 'ansible-deploy'
role_name = __name__.split('-')[1]
base = '/etc/ansible/roles/%s' % role_name
cwd = os.getcwd()
data_files = []

for dir in ['library', 'meta', 'filter_plugins', 'templates', 'defaults', 'tasks']:
  _files = []
  for root, dirs, files in os.walk(dir, topdown=False):
   for name in files:
      if name.startswith('.') or root.startswith('./.'):
        continue
      _files.append("%s/%s" % (root,name))
  data_files.append(("%s/%s" % (role_name, dir), _files))

class link_role(install):
    def run(self):
        install.run(self)
        dist = self.install_data + "/" + role_name
        if not dist.startswith('/'):
          dist = "%s/%s" % (os.getcwd(), dist)
        role = "/etc/ansible/roles/%s" % role_name
        if os.path.isdir(dist):
          print ("Renaming %s to %s" % (dist, role))
          if os.path.isdir(role):
            print ("cleaning %s" % role)
            import shutil
            shutil.rmtree(role)
          check_output("mkdir -p /etc/ansible/roles", shell=True)
          os.renames(dist, role)

setup(
    name = __name__,
    version = __version__,
    install_requires = ['ansible-extras'],
    scripts = ['ansible-deploy'],
    packages = [__name__.replace("-", "_")],
    data_files = data_files,
    cmdclass = {'install': link_role},
    url = 'https://www/github.com/moshloop/ansible-deploy',
    author = 'Moshe Immerman', author_email = 'moshe.immerman@gmail.com'
)