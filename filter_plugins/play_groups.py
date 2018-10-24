from ansible import errors

def play_groups(play_hosts, groups, hostvars, exclude=[]):
    _list = []

    for host in play_hosts:
        for group in groups:
            if group in exclude:
                continue
            if host in groups[group]:
                _list.append(group)
    return list(set(_list))

class FilterModule(object):
    ''' Returns a list of play groups that are active within a play '''
    def filters(self):
        return {
            'play_groups' : play_groups
        }