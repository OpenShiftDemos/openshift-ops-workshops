import json


def oo_verify_node_list(node_list):
    nodes = json.loads(node_list)
    return False

class FilterModule(object):

    def filters(self):
        return {
            "oo_verify_node_list": oo_verify_node_list
        }
