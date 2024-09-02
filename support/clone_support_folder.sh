#!/bin/bash

# make directory where original one was
sudo mkdir -p /opt/app-root/src/

# Move the 'support' directory outside of the repository
sudo mv /home/demo-user/openshift-ops-workshops/support /opt/app-root/src/

# Remove the cloned repository
rm -rf openshift-ops-workshops

echo "Moved the 'support' folder and removed the repository."

