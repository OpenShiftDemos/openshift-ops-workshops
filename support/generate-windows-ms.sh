#!/bin/bash
awscli=/usr/local/bin/aws
jqcli=/usr/bin/jq
windowsmsfile=${HOME}/windows-ms.yaml

#
## Give information to user
echo -n "Generating Windows Machineset YAML"

#
## Check to see if you're sysadmin. Kind of crude check but works for our usecase
if ! oc get ns default  -o name >/dev/null 2>&1 ; then
	echo -e "\nERROR: Please make sure you're kubeadmin"
	exit 13
fi

#
## Give status information to user
echo -n "."

#
## Check if various things are available
for thing in ${awscli}
do
	if [[ ! -e ${thing} ]] ; then
		echo -e "\nFATAL: $(basename ${thing}) not found!"
		exit 13
	fi
done

#
## Give status information to user
echo -n "."


#
## Export needed information
export AWS_ACCESS_KEY_ID=$(oc get secret aws-creds -n kube-system -o jsonpath='{.data.aws_access_key_id}' | base64 -d)
export AWS_SECRET_ACCESS_KEY=$(oc get secret aws-creds -n kube-system -o jsonpath='{.data.aws_secret_access_key}' | base64 -d)
export AWS_DEFAULT_REGION=$(oc get machineset -n openshift-machine-api -o jsonpath='{.items[0].spec.template.spec.providerSpec.value.placement.region}')
export WAMI=$(aws ec2 describe-images \
  --region $AWS_DEFAULT_REGION \
  --owners amazon \
  --filters "Name=name,Values=Windows_Server-2019*English*Full*ECS_Optimized-*" \
  --query 'sort_by(Images, &CreationDate)[-1].ImageId' \
  --output text)
#
## Give status information to user
echo -n "."


#
## Generate Windows machineset
cat <<EOF > ${windowsmsfile}
apiVersion: machine.openshift.io/v1beta1
kind: MachineSet
metadata:
  labels:
    machine.openshift.io/cluster-api-cluster: $(oc get -o jsonpath='{.status.infrastructureName}' infrastructure cluster)
    machine.openshift.io/os-id: Windows
  name: $(oc get -o jsonpath='{.status.infrastructureName}' infrastructure cluster)-windows-worker-$(oc get machineset -n openshift-machine-api -o jsonpath='{.items[0].spec.template.spec.providerSpec.value.placement.availabilityZone}')
  namespace: openshift-machine-api
spec:
  replicas: 1
  selector:
    matchLabels:
      machine.openshift.io/cluster-api-cluster: $(oc get -o jsonpath='{.status.infrastructureName}' infrastructure cluster)
      machine.openshift.io/cluster-api-machineset: $(oc get -o jsonpath='{.status.infrastructureName}' infrastructure cluster)-windows-worker-$(oc get machineset -n openshift-machine-api -o jsonpath='{.items[0].spec.template.spec.providerSpec.value.placement.availabilityZone}')
  template:
    metadata:
      labels:
        machine.openshift.io/cluster-api-cluster: $(oc get -o jsonpath='{.status.infrastructureName}' infrastructure cluster)
        machine.openshift.io/cluster-api-machine-role: worker
        machine.openshift.io/cluster-api-machine-type: worker
        machine.openshift.io/cluster-api-machineset: $(oc get -o jsonpath='{.status.infrastructureName}' infrastructure cluster)-windows-worker-$(oc get machineset -n openshift-machine-api -o jsonpath='{.items[0].spec.template.spec.providerSpec.value.placement.availabilityZone}')
        machine.openshift.io/os-id: Windows
    spec:
      metadata:
        labels:
          node-role.kubernetes.io/worker: ""
      providerSpec:
        value:
          ami:
            id: ${WAMI}
          apiVersion: awsproviderconfig.openshift.io/v1beta1
          blockDevices:
            - ebs:
                iops: 0
                volumeSize: 120
                volumeType: gp2
          credentialsSecret:
            name: aws-cloud-credentials
          deviceIndex: 0
          iamInstanceProfile:
            id: $(oc get -o jsonpath='{.status.infrastructureName}' infrastructure cluster)-worker-profile
          instanceType: m5a.2xlarge
          kind: AWSMachineProviderConfig
          placement:
            availabilityZone: $(oc get machineset -n openshift-machine-api -o jsonpath='{.items[0].spec.template.spec.providerSpec.value.placement.availabilityZone}')
            region: $(oc get machineset -n openshift-machine-api -o jsonpath='{.items[0].spec.template.spec.providerSpec.value.placement.region}')
          securityGroups:
            - filters:
                - name: tag:Name
                  values:
                    - $(oc get -o jsonpath='{.status.infrastructureName}' infrastructure cluster)-worker-sg
          subnet:
            filters:
              - name: tag:Name
                values:
                  - $(oc get -o jsonpath='{.status.infrastructureName}' infrastructure cluster)-private-$(oc get machineset -n openshift-machine-api -o jsonpath='{.items[0].spec.template.spec.providerSpec.value.placement.availabilityZone}')
          tags:
            - name: kubernetes.io/cluster/$(oc get -o jsonpath='{.status.infrastructureName}' infrastructure cluster)
              value: owned
          userDataSecret:
            name: windows-user-data
            namespace: openshift-machine-api
EOF

#
## Tell the user where the file is
echo "Machineset ${windowsmsfile} created!"

##
##
