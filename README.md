## Server-Baseline

Sometimes you just want a quick method of configuring instances which may not belong in your existing inventory nor your normal processes. This repo contains a shell script and ansible playbook which provide a quick method of configuring one or more Ubuntu 16.04 hosts into a desired default state, optionally with Docker installed. Given the IP address, ssh user, and ssh key of one or more hosts, it will call the following roles (also available under this GitHub account):

[Ansible-Ubuntu-Common](https://github.com/gege56015/Ansible-Ubuntu-Common) <br>
[Ansible-Docker-Common](https://github.com/gege56015/Ansible-Docker-Common)

You can read more about what these roles do by clicking the links above.


## How To Use:

**Cloning**

This repo incorporates the above roles via git submodules. As such, when cloning, you will need to specify the '--recursive' option to git. Alternately, you can still use the ansible-galaxy cli to pull the roles into your local roles directory.

**Run Against A Single Pre-Existing Host**

For a quick run against a single host, a shell script (run-manual.sh) has been included which will ask some questions, setup an ad-hoc inventory file, and then run the configure_server.yml playbook against the host you specified. 

**Run Against A Larger Inventory**

Of course, you can always incorporate the playbook to run against the inventory of your choosing. By default, the playbook is looking for a host group called "target-hosts". You can either create such a group or you can modify the playbook to point to the group you desire. The playbook can be run as follows (with or without the optional inventory location and private key options):

```
ansible-playbook -i <inventory location>  configure_server.yml --private-key <ssh key location>
```
