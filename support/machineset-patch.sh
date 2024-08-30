#!/bin/bash

export MACHINESET=$(oc get machineset.machine.openshift.io -n openshift-machine-api -l machine.openshift.io/cluster-api-machine-role=infra -o jsonpath='{.items[0].metadata.name}')
oc patch machineset.machine.openshift.io $MACHINESET -n openshift-machine-api --type='json' -p='[{"op": "add", "path": "/spec/template/spec/metadata/labels", "value":{"node-role.kubernetes.io/worker":"", "node-role.kubernetes.io/infra":""} }]'

export WORKER_NAME=$(oc get machineset.machine.openshift.io -n openshift-machine-api | awk '/worker/{print $1}' | head -n 1)
export SECURITY_GROUP=$(oc get machineset.machine.openshift.io -n openshift-machine-api -o jsonpath='{.items[?(@.metadata.name=="'$WORKER_NAME'")].spec.template.spec.providerSpec.value.securityGroups[0].filters[0].values[0]}')
oc patch machineset.machine.openshift.io $MACHINESET -n openshift-machine-api --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/providerSpec/value/securityGroups/0/filters/0/values/0", "value": "'"$SECURITY_GROUP"'"}]'

export SUBNET=$(oc get machineset.machine.openshift.io -n openshift-machine-api -o jsonpath='{.items[?(@.metadata.name=="'$WORKER_NAME'")].spec.template.spec.providerSpec.value.subnet.filters[0].values[0]}')
oc patch machineset.machine.openshift.io $MACHINESET -n openshift-machine-api --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/providerSpec/value/subnet/filters/0/values/0", "value": "'"$SUBNET"'"}]'

export API_VERSION=$(oc get machineset.machine.openshift.io -n openshift-machine-api -o jsonpath='{.items[?(@.metadata.name=="'$WORKER_NAME'")].spec.template.spec.providerSpec.value.apiVersion}')
oc patch machineset.machine.openshift.io $MACHINESET -n openshift-machine-api --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/providerSpec/value/apiVersion", "value": "'"$API_VERSION"'"}]'
