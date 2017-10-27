#!/bin/bash
set -x

export USER_ID=$(id -u)
export GROUP_ID=$(id -g)
cp /etc/passwd $HOME/passwd
echo "me:x:${USER_ID}:${GROUP_ID}:ssh user:${HOME}:/bin/bash" >> "$HOME/passwd"
export LD_PRELOAD=libnss_wrapper.so
export NSS_WRAPPER_PASSWD=${HOME}/passwd
export NSS_WRAPPER_GROUP=/etc/group
export QWIKLAB_API_ENDPOINT='https://redhat.qwiklab.com/api/v1'

# start lab instance and store its details into a json file
echo "starting lab instance"
http POST $QWIKLAB_API_ENDPOINT/focuses/run_lab auth_token=$QWIKLAB_API_TOKEN focus:='{"id":"70"}' > /tmp/lab_details.json

# qwiklab api returns 200 sometimes even if there's an error
# the error means we didn't provision, so we can exit without issue
grep -iq 'access denied' /tmp/lab_details.json

if [ $? == 0 ]
then
  echo "found access denied error"
  exit 255
fi

# store lab instance id
export LAB_ID=`cat /tmp/lab_details.json  | jq .response.id`
export ACCOUNT_NUMBER=`cat /tmp/lab_details.json | jq -r .response.aws_account_number`
export MASTER_URL="master.$ACCOUNT_NUMBER.aws.testdrive.openshift.com"

COUNTER=1
while [ $COUNTER -lt 8 ]
do
  sleep 60
  let COUNTER=COUNTER+1 
done

COUNTER=1
SUCCESS=0
while [ $COUNTER -lt 5 ]
do
  export CREATE_STATUS=`http POST $QWIKLAB_API_ENDPOINT/lab_instances/get_lab_instance/ \
  auth_token=$QWIKLAB_API_TOKEN lab_instance:='{"id": "'$LAB_ID'"}' | jq -r .response.aws_cf_state`
             
  if [ $CREATE_STATUS == "CREATE_COMPLETE" ]
  then
    SUCCESS=1
    break
  fi

  sleep 60
  let COUNTER=COUNTER+1 
done

if [ $SUCCESS != 1 ]
then
  # didn't get a completed deployment, so ask for teardown and abort
  http POST $QWIKLAB_API_TOKEN/lab_instances/end_lab_instance \
  auth_token=$QWIKLAB_API_TOKEN lab_instance:='{"id":"'$LAB_ID'"}'
  exit 255
fi

jq -r .response.key_pair.keyMaterial /tmp/lab_details.json > /tmp/sshkey.pub
chmod 600 /tmp/sshkey.pub

SUCCESS=1
# if this fails we don't want to exit on error - we need to save the error and then delete the environment first
ssh -i /tmp/sshkey.pub -o StrictHostKeyChecking=No cloud-user@$MASTER_URL "ansible-playbook /opt/lab/code/tests/ci.yaml"
if [ $? != 0 ]
then
  SUCCESS=0  
fi


http POST $QWIKLAB_API_TOKEN/lab_instances/end_lab_instance \
auth_token=$QWIKLAB_API_TOKEN lab_instance:='{"id":"'$LAB_ID'"}'

if [ $SUCCESS == 1 ]
then
  exit 0
else
  exit 255
fi
