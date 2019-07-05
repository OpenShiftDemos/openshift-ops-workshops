# OpenShift and Container Storage for Administrators
This repository contains lab instructions and related supporting content for
an administrative-focused workshop that deals with OpenShift and OpenShift
Container Storage.

## Requirements / Prerequisites
Doing these labs on your own requires a few things.

### AWS
These labs are designed to run on top of an OpenShift 4 cluster that has been
installed completely by the new installer. You will need access to AWS with
sufficient permissions and limits to deploy the 3 masters, 4-6 regular nodes,
and NVME-equipped nodes for storage.

Check out the
[documentation](https://docs.openshift.com/container-platform/4.1/welcome/index.html)
for _Installing on AWS_.

### OpenShift 4
At this time an OpenShift 4 cluster can be obtained by visiting
https://try.openshift.com -- a free "subscription" to / membership in the
developer program is required.

## Deploying the Lab Guide
Deploying the lab guide will take two steps. First, you will need to get
information about your cluster. Second, you will deploy the lab guide using
the information you found so that proper URLs and references are
automatically displayed in the guide.

### Required Environment Variables
Most of the information can be found in the output of the installer.

#### Explaination and examples
- `API_URL` - URL to access API of the cluster
    - `https://api.cluster-gu1d.sandbox101.opentlc.com:6443`
- `MASTER_URL` - Master Console URL
    - `http://console-openshift-console.apps.cluster-gu1d.sandbox101.opentlc.com`
- `KUBEADMIN_PASSWORD` - Password for `kubeadmin`
- `SSH_PASSWORD` - password for ssh into bastion
- `ROUTE_SUBDOMAIN` - Subdomain that apps will reside on
    - `apps.cluster-gu1d.sandbox101.opentlc.com:6443`
    - `apps.mycluster.company.com`

Specific to Red Hat internal systems
- `GUID` - GUID
    - `gu1d`
- `BASTION_FQDN` - Bastion Domain Name
    - `bastion.gu1d.sandbox101.opentlc.com`

Edit the following to your values and run.

:warning: For `export` ensure [special characters](http://mywiki.wooledge.org/BashGuide/SpecialCharacters) are escaped (ie. use `\!` in place of `!`).
```bash
export API_URL=https://api......:6443
export MASTER_URL=https://console-openshift-console.....
export KUBEADMIN_PASSWORD=xxx
export SSH_USERNAME=lab-user
export SSH_PASSWORD=xxxx
export ROUTE_SUBDOMAIN=apps.mycluster.company.com
export GUID=xxxx
export BASTION_FQDN=foo.bar.com
export HOME_PATH=/opt/app-root/src
```
### Deploy the Lab Guide
Now that you have exported the various required variables, you can deploy the
lab guide into your cluster. The following will log you in
as `kubeadmin` on systems with `oc` client installed:
```bash
oc login -u kubeadmin -p $KUBEADMIN_PASSWORD

oc new-project labguide

# Create deployment.
oc new-app https://raw.githubusercontent.com/openshift-labs/workshop-dashboard/3.1.0/templates/production-cluster-admin.json -n labguide \
   --param APPLICATION_NAME=admin \
   --param WORKSHOPPER_URLS=https://raw.githubusercontent.com/kaovilai/openshift-cns-testdrive/ocp4-prod/labguide/_ocp_admin_testdrive.yaml \
   --param PROJECT_NAME=labguide \
   --param WORKSHOP_ENVVARS="
API_URL=$API_URL \
MASTER_URL=$MASTER_URL \
KUBEADMIN_PASSWORD=$KUBEADMIN_PASSWORD \
SSH_USERNAME=$SSH_USERNAME \
SSH_PASSWORD=$SSH_PASSWORD \
BASTION_FQDN=$BASTION_FQDN \
GUID=$GUID \
ROUTE_SUBDOMAIN=$ROUTE_SUBDOMAIN \
HOME_PATH=$HOME_PATH"

# Wait for deployment to finish.

oc rollout status dc/admin -n labguide
```

## Doing the Labs
Your lab guide should deploy in a few moments. To find its url, execute:

```bash
oc get route admin -n labguide
```

You should be able to visit that URL and see the lab guide. From here you can
follow the instructions in the lab guide.

## Notes and Warnings
Remember, this experience is designed for a provisioning system internal to
Red Hat. Your lab guide will be mostly accurate, but slightly off.

* You aren't likely using `lab-user`
* You will probably not need to actively use your `GUID`
* You will see lots of output that references your `GUID` or other slightly off
  things
* Your `MachineSets` are different depending on the EC2 region you chose

But, generally, everything should work. Just don't be alarmed if something
looks mostly different than the lab guide.

Also note that the first lab where you SSH into the bastion host is not
relevant to you -- you are likely already doing the exercises on the host
where you installed OpenShift from.

## Troubleshooting
Make sure you are logged-in as kubeadmin when creating the project

If you are getting _too many redirects_ error then clearing cookies and re-login as kubeadmin

## Cleaning up
To delete deployment run
```
oc delete all,serviceaccount,rolebinding,configmap -l app=admin -n labguide
```
