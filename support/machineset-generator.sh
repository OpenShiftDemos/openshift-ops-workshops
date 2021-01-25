#!/bin/bash
export AMI=$(oc get machineset -n openshift-machine-api -l 'machine.openshift.io/os-id!=Windows' -o jsonpath='{.items[0].spec.template.spec.providerSpec.value.ami.id}')
export CLUSTERID=$(oc get infrastructures.config.openshift.io cluster -o jsonpath='{.status.infrastructureName}')
export REGION=$(oc get infrastructures.config.openshift.io cluster -o jsonpath='{.status.platformStatus.aws.region}')
export COUNT=${1:-3}
export NAME=${2:-workerocs}
export SCALE=${3:-1}

$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/machineset-cli -scale $SCALE -name $NAME -count $COUNT -ami $AMI -clusterID $CLUSTERID -region $REGION
