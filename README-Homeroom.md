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

## Deploying the Lab Guide to Homeroom
Deploying the lab guide will take two steps. First, you will need to get
information about your cluster. Second, you will deploy the lab guide using
the information you found so that proper URLs and references are
automatically displayed in the guide.

### Required Information
Most of the information can be found in the output of the installer.

1. Export the API URL endpoint to an environment variable:

    ```bash
    export API_URL=https://api......:6443
    ```

2. Export the master/console URL to an environment variable:

    ```bash
    export MASTER_URL=https://console-openshift-console.....
    ```

3. Export the `kubeadmin` password as an environment variable:

    ```bash
    export KUBEADMIN_PASSWORD=xxx
    ```

4. Export the routing subdomain as an environment variable. When you installed your cluster you specified a domain to use, and OpenShift built a routing subdomain that looks like `apps.clusterID.domain`. For example, `apps.mycluster.company.com`. Export this:

    ```bash
    export ROUTE_SUBDOMAIN=apps.mycluster.company.com
    ```
5. This lab guide was built for an internal Red Hat system, so there are two
   additional things you will need to export. Please export them exactly as
   follows:

    ```bash
    export GUID=xxxx
    export BASTION_FQDN=foo.bar.com
    ```

### Deploy the Lab Guide
Now that you have exported the various required variables, you can deploy the
lab guide into your cluster. The following assumes you are logged in already
as `kubeadmin` and on a system with the `oc` client installed:

```bash
oc new-app https://raw.githubusercontent.com/openshift-labs/workshop-dashboard/master/templates/production.json
oc set env dc/dashboard --all \
WORKSHOPS_URLS='https://raw.githubusercontent.com/openshift/openshift-cns-testdrive/ocp4-prod/labguide/_ocp_admin_testdrive.yaml' \
CONTENT_URL_PREFIX='https://raw.githubusercontent.com/openshift/openshift-cns-testdrive/ocp4-prod/labguide/' \
API_URL=$API_URL \
MASTER_URL=$MASTER_URL \
KUBEADMIN_PASSWORD=$KUBEADMIN_PASSWORD \
BASTION_FQDN=$BASTION_FQDN \
GUID=$GUID \
ROUTE_SUBDOMAIN=$ROUTE_SUBDOMAIN
 
```

## Doing the Labs
Your lab guide should deploy in a few moments. To find its url, execute:

```bash
oc get route dashboard
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
