import re

def semver(args):
  ver = 0
  sem = 10000000
  args = re.sub('[^0-9.]', '',args)
  for arg in args.split("."):
    if arg == "":
      continue
    ver += int(arg) * sem
    sem = sem / 100
  return ver

class FilterModule(object):
  '''Returns a semver based number suitable for sorting '''
  def filters(self):
      return {
          'semver' : semver
      }


if __name__ == "__main__":
  assert semver('1.0.8') < semver('1.0.9')
  assert semver('1.0.9') < semver('1.0.19')
  assert semver('1.0.8.GA') < semver('1.0.9.GA')
  assert semver('1.0.9') < semver('1.0.19')