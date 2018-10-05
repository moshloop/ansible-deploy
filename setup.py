
from subprocess import *
from setuptools import setup, find_packages
import os

setup(
    name = 'ansible-deploy', version = '0.1',
    install_requires=['ansible-run'],
    url = 'https://www/github.com/moshloop/ansible-deploy',
    author = 'Moshe Immerman', author_email = 'firstname.surname@gmail.com',
    scripts = ['ansible-deploy']
)