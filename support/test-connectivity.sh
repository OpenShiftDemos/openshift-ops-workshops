#!/bin/bash

normal_color=$(echo -e "\e[0m")
red_color=$(echo -e "\e[31m")
green_color=$(echo -e "\e[32m")
max_tries=10
sleep_between_tries=1


echo -n "Getting Pod B's IP... "
pod_b_ip=$(oc get pod -n netproj-b $(oc get pod -n netproj-b | grep -v deploy | awk '/ose-/ {print $1}') -o jsonpath='{.status.podIP}{"\n"}')
echo $pod_b_ip


echo -n "Getting Pod A's Name... "
pod_a_name=$(oc get pod -n netproj-a | grep -v deploy | awk '/ose-/ {print $1}')
echo $pod_a_name


echo -n "Checking connectivity between Pod A and Pod B..."


i=1
while [ $i -le ${max_tries} ]; do
  if [ $i -gt 1 ]; then
    # Don't sleep on first loop
    echo -n "."
    sleep ${sleep_between_tries}
  fi

  if oc exec -n netproj-a $pod_a_name -- timeout 2 bash -c "</dev/tcp/$pod_b_ip/5000" 2>/dev/null ; then
    break
  fi

  i=$((i + 1))
done

if [ $i -ge ${max_tries} ] ; then
  # Failed the maximum amount of times.
  echo " ${red_color}FAILED!${normal_color}"
  exit 1
else
  echo " ${green_color}worked${normal_color}"
fi

