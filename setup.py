from subprocess import *
from setuptools import setup, find_packages
from setuptools.command.install import install
from ansible_deploy import __version__
import os

__name__ = "ansible-deploy"

setup(
    name = __name__,
    version = __version__,
    scripts = ['ansible-deploy'],
    packages = [__name__.replace("-", "_")],
    url = 'https://www/github.com/moshloop/ansible-deploy',
    author = 'Moshe Immerman', author_email = 'moshe.immerman@gmail.com'
)