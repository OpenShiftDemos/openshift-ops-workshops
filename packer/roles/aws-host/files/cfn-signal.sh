#!/bin/bash
#
# This script will signal the provided Cloud Formation URL with success or failue.
# Result is expected to be the return code of a configuration management script.
# Success will only be signaled if the script returns 0

export result=$1
export url=$2

function help {
  echo "Command Usage: $0 RESULT URL"
  exit 1
}

if [ -z $result ] || [ -z $url ]; then
  help
fi

if [ $result -eq 0 ]; then
  export status='SUCCESS'
  export reason='Command Signaled Success'
else
  export status='FAILURE'
  export reason='Command Signaled Failure'
fi

unique_id=`curl --connect-timeout 10 -s http://169.254.169.254/latest/meta-data/instance-id`
if [ -z $unique_id ]; then
  echo "Could not determine Instance ID."
  exit 1
fi

data="Return code: $result"
response="{ \"Status\" : \"$status\", \"Reason\" : \"$reason\", \"UniqueId\" : \"$unique_id\", \"Data\" : \"$data\" }"

echo "Signaling $status"

curl --connect-timeout 10 -X PUT -H "Content-Type:" --data-binary "$response" "$url"

if [ $? -ne 0 ]; then
  echo "Signaling failed."
  exit 1
fi

echo "Signaling completed successfully."
