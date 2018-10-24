from ansible import errors
import os.path

def k8s_name(arg):
  return os.path.basename(arg).replace('/', '').replace('.','')

class FilterModule(object):
  '''Returns a k8s compatible name'''
  def filters(self):
      return {
          'k8s_name' : k8s_name
      }
