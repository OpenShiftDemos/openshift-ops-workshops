#!/bin/bash

echo ""
echo "============================================"
echo " Support Folder Recovery Script"
echo "============================================"
echo ""

# Auto-detect bastion
if [[ "$HOSTNAME" == *"bastion"* ]] || [[ "$(whoami)" == "lab-user" ]]; then
    echo "!! WARNING !!"
    echo "We detected you are running this as lab-user on bastion."
    echo ""
    echo "The bastion does NOT have the support directory."
    echo "Type 'exit' to return to the dashboard terminal."
    echo ""
    echo "If you proceed anyway, workshop instructions may break."
    echo ""
    echo "--------------------------------------------"
    echo ""
fi

echo "Before continuing, check your terminal prompt:"
echo ""
echo "  [~] $"
echo "    -> Dashboard terminal (has support directory)"
echo "    -> Run 'ls' - if you see 'support', you are done!"
echo "    -> Workshop will work as intended."
echo ""
echo "  [lab-user@bastion ~]$"
echo "    -> Bastion host (does NOT have support directory)"
echo "    -> Type 'exit' to get back to [~] $"
echo "    -> Then run 'ls' to check for support"
echo ""
echo "  WARNING: If you run this script from [lab-user@bastion ~]$"
echo "  the support files will be in the wrong location and"
echo "  workshop commands may not work later!"
echo ""
read -p "Press ENTER to continue or Ctrl+C to cancel..."

echo ""

# Target directory (matches workshop instructions)
TARGET_DIR="/opt/app-root/src"

# Check if support folder already exists
if [ -d "${TARGET_DIR}/support" ]; then
    echo "Support folder already exists at ${TARGET_DIR}/support"
    ls ${TARGET_DIR}/support | head -5
    echo "..."
    echo ""
    echo "To re-download, delete it first: rm -rf ${TARGET_DIR}/support"
    exit 0
fi

echo "Support folder not found. Downloading..."
echo ""

# Create target directory if needed (may need sudo on bastion)
if [ ! -d "${TARGET_DIR}" ]; then
    echo "Creating ${TARGET_DIR}..."
    mkdir -p ${TARGET_DIR} 2>/dev/null || {
        sudo mkdir -p ${TARGET_DIR}
        sudo chown $(whoami) ${TARGET_DIR}
    }
    if [ $? -ne 0 ]; then
        echo "ERROR: Could not create ${TARGET_DIR}"
        echo "You may not have permissions. Try running from the dashboard terminal."
        exit 1
    fi
fi

# Ensure we can write to the target directory
if [ ! -w "${TARGET_DIR}" ]; then
    echo "Fixing permissions on ${TARGET_DIR}..."
    sudo chown $(whoami) ${TARGET_DIR}
fi

# Clone the repo
cd ${TARGET_DIR}
git clone -b ocp4-prod https://github.com/OpenShiftDemos/openshift-ops-workshops.git

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to clone repository"
    exit 1
fi

# Move support folder to target
mv ./openshift-ops-workshops/support ${TARGET_DIR}/support

# Move dns_update if it exists
if [ -d "./openshift-ops-workshops/dns_update" ]; then
    mv ./openshift-ops-workshops/dns_update ${TARGET_DIR}/dns_update
fi

# Cleanup cloned repo
rm -rf ./openshift-ops-workshops

echo ""
echo "============================================"
echo " Done! Files installed to ${TARGET_DIR}/support"
echo "============================================"
echo ""
ls ${TARGET_DIR}/support | head -10
echo ""
echo "Next steps:"
echo "  cd ${TARGET_DIR}"
echo "  ls"
echo ""
echo "You should now see the 'support' directory."
echo ""
echo "NOTE: If your prompt still shows [lab-user@bastion ~]$ you are"
echo "on the bastion host. Type 'exit' to return to the dashboard"
echo "terminal where the support directory should already exist"
echo "(unless your provisioned cluster is having issues)."
