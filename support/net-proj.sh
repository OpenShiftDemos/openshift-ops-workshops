#!/bin/bash

# create NetworkA, NetworkB projects
/usr/bin/oc new-project netproj-a
/usr/bin/oc new-project netproj-b

# deploy the DC definition into the projects
/usr/bin/oc create -f /opt/lab/code/support/ose.yaml -n netproj-a
/usr/bin/oc create -f /opt/lab/code/support/ose.yaml -n netproj-b
