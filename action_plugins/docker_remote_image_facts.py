from ansible.plugins.action import ActionBase
import json
from requests.auth import HTTPBasicAuth
import requests

def case_insensitive_dict(_dict):
  _map = {}
  for k in _dict:
    _map[k.lower()] = _dict[k]
  return _map

def trim_quotes(string):
  if string.startswith('"') or string.startswith("'"):
    string = string[1:]

  if string.endswith('"') or string.endswith("'"):
    string = string[:-1]
  return string

def get_oauth_token(response, auth):
  headers = case_insensitive_dict(response.headers)
  if 'www-authenticate' in headers:
      bearer = headers['www-authenticate']
      bearer = bearer[len("Bearer "):]
      realm = {}
      for entry in bearer.split(","):
        k = entry.split("=")[0]
        v = trim_quotes(entry.split("=")[1])
        realm[k] = v

      res = requests.get(realm['realm'], auth=auth, params={
          "client_id": "docker",
          "offline_token": "true",
          "service": realm['service'],
          "scope": realm['scope']
      })
      return res.json()['token']

class ActionModule(ActionBase):
    def run(self, tmp=None, task_vars=None):

      if task_vars is None:
        task_vars = dict()
      results = super(ActionModule, self).run(tmp, task_vars)

      auth = HTTPBasicAuth(self._task.args.get('username', ''), self._task.args.get('password', ''))
      image = self._task.args['image']
      registry = self._task.args.get('registry', None)

      if registry is None or registry is "":
        registry = "https://" + image.split('/')[0]

        image = "/".join(image.split('/')[1:])

      name = image.split(":")[0]
      if ':' in image:
        ref = image.split(':')[1]
      else:
        ref = 'latest'
      manifests = "%s/v2/%s/manifests/%s" % (registry,name,ref)
      res = requests.get(manifests, auth=auth)
      if res.status_code == 401:
        res = requests.get(manifests, headers={
            "Authorization": "Bearer %s" % get_oauth_token(res, auth)
        })

      return {
        "registry": registry,
        "image": name,
        "ref": ref,
        "digest": res.headers['Docker-Content-Digest'],
        "manifest": res.json()
      }
