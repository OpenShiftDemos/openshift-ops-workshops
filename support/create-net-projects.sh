#!/bin/bash

# We want to bail if an error occurs.
set -e

cd $(dirname $0)

# deploy into the projects
oc process -f netproj-template.yaml NAMESPACE=netproj-a | oc apply -n netproj-a -f -
oc process -f netproj-template.yaml NAMESPACE=netproj-b | oc apply -n netproj-b -f -
