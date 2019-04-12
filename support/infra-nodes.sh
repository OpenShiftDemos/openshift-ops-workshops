#!/bin/bash
export REGION=us-east-1e
export NAME="infra-$REGION"
oc get machineset -n openshift-machine-api -o json\
| jq '.items[0]'\
| jq '.metadata.name=env["NAME"]'\
| jq '.spec.selector.matchLabels."machine.openshift.io/cluster-api-machineset"=env["NAME"]'\
| jq '.spec.template.metadata.labels."machine.openshift.io/cluster-api-machineset"=env["NAME"]'\
| jq '.spec.template.spec.metadata.labels."node-role.kubernetes.io/infra"=""'\
| jq 'del (.metadata.annotations)'\
| jq '.spec.replicas=3'\
| oc create -f -
