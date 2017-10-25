#!/bin/bash
#set -x
set -e

# start lab instance and store its details into a json file
echo "starting lab instance"
curl -s -X POST -H "Content-Type: application/json" \
-d '{ "auth_token": "'$QWIKLAB_API_TOKEN'", "focus": { "id": "70"} }' \
https://redhat.qwiklab.com/api/v1/focuses/run_lab/ > lab_details.json

# store lab instance id
export LAB_ID=`cat lab_details.json  | jq .response.id`
export ACCOUNT_NUMBER=`cat lab_details.json | jq -r .response.aws_account_number`
export MASTER_URL="master.$ACCOUNT_NUMBER.aws.testdrive.openshift.com"

echo "Lab ID: $LAB_ID"
echo "Master URL: $MASTER_URL"

echo "wait 8 minutes always before starting to check"
COUNTER=1
while [ $COUNTER -lt 8 ]
do
  sleep 60
  echo "minute $COUNTER..."
  let COUNTER=COUNTER+1 
done

echo "wait up to 5 more minutes for lab instance to provision"
COUNTER=1
SUCCESS=0
while [ $COUNTER -lt 5 ]
do
  export CREATE_STATUS=`curl -s -X POST -H "Content-Type: application/json" \
  -d '{ "auth_token": "'$QWIKLAB_API_TOKEN'", "lab_instance": { "id": "'$LAB_ID'"} \
  }' https://redhat.qwiklab.com/api/v1/lab_instances/get_lab_instance/ \
  | jq -r .response.aws_cf_state`
             
  if [ $CREATE_STATUS == "CREATE_COMPLETE" ]
  then
    SUCCESS=1
    break
  fi

  sleep 60
  let COUNTER=COUNTER+1 
  echo "waiting..."
done

if [ $SUCCESS != 1 ]
then
  echo "No successful creation."
  exit 255
fi

echo "fetch SSH key for lab instance"
jq -r .response.key_pair.keyMaterial ./lab_details.json > sshkey.pub
chmod 600 ./sshkey.pub

echo "SSH into remote server and execute ansible"
ssh -i ./sshkey.pub -o StrictHostKeyChecking=No cloud-user@$MASTER_URL "ansible-playbook /opt/lab/code/tests/ci.yaml"

echo "tear down lab instance"
curl -X POST -H "Content-type: application/json" \
-d '{ "auth_token": "'$QWIKLAB_API_TOKEN'", "lab_instance": { "id": "'$LAB_ID'"} }' \
https://redhat.qwiklab.com/api/v1/lab_instances/end_lab_instance > /dev/null