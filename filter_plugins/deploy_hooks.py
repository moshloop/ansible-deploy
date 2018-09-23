import os
import os.path

try:
    from __main__ import display
except ImportError:
    from ansible.utils.display import Display
    display = Display()


cwd = os.getcwd()

def hooks(hooks, type, run_once, groups):
  suffix = "once.yml" if run_once else "yml"
  hooks.append(cwd)
  groups.append('all')
  display.verbose('Listing for: %s -> %s' % (hooks, groups))

  files = []
  for hook in hooks:
    for group in groups:
      path = "%s/%s.%s.%s" % (hook, type, group, suffix)
      if os.path.isfile(path):
        files.append(path)
  return files

class FilterModule(object):
  def filters(self):
      return {
          'deploy_hooks' : hooks
      }