### Deploy AWS instance and then run packer 
The instructor public key should be in your home directory or the path should be provided at run time.

```
ansible-playbook -e "org_id=0000000 keypair=000000 act_key=000000" environment.yaml
```

An already existing subnet and VPC can be provided.

NOTE: Ensure that the subnet by default auto-assigns public IP addresses

````
ansible-playbook -e "vpc_id=vpc-000000 subnet_id=000000000 org_id=0000000 keypair=000000 act_key=000000" environment.yaml
````

### extra variables
The extra vars of ami, branch, repo, az, and region can be specified with the -e parameter. The defaults are defined in the vars.yaml.

### Teardown the instance
To delete the packer builder instance in the event the packer run is not clean.

```
ansible-playbook -i ec2.py terminate.yaml
```
