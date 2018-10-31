import docker

def to_docker_image_sha(image):
    client = docker.from_env()
    return image + '@' + client.images.get_registry_data(image).id

class FilterModule(object):
     def filters(self):
         """ Returns a new map/dict with only entries matching a prefix, and withthe prefix removed """
         return {'to_docker_image_sha': to_docker_image_sha}