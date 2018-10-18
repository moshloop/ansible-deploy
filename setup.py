from subprocess import *
from setuptools import setup, find_packages
from setuptools.command.install import install
from ansible_deploy import __version__
import os
from os.path import isfile
import pathspec
__name__ = 'ansible-deploy'
cwd = os.getcwd()
base = '/etc/ansible/roles/%s' % __name__.split('-')[1]
data_files = []
spec = pathspec.PathSpec.from_lines('gitwildmatch',open('.gitignore').read().splitlines())
for dir in ['library', 'meta', 'filter_plugins', 'templates', 'defaults', 'tasks']:
  _files = []
  for root, dirs, files in os.walk(dir, topdown=False):
   for name in files:
      if spec.match_file(os.path.join(root, name)) or name.startswith('.') or root.startswith('./.'):
        continue
      print name
      _files.append("%s/%s" % (root,name))
  data_files.append(("%s/%s" % (base, dir), _files))

print data_files

setup(
    name = __name__,
    version = __version__,
    packages = [__name__.replace("-", "_")],
    data_files = data_files,
    url = 'https://www/github.com/moshloop/ansible-deploy',
    author = 'Moshe Immerman', author_email = 'moshe.immerman@gmail.com'
)