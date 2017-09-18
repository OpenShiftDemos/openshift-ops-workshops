#!/bin/bash
/usr/bin/oc get pod -n netproj-b $(oc get pod -n netproj-b | awk '/ose-/ {print $1}') -o jsonpath='{.status.podIP}{"\n"}'
