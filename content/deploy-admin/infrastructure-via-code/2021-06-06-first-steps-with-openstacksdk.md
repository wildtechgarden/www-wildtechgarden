---
slug: first-steps-with-openstacksdk
aliases:
    - /projects/experimental-learning/infrastructure-via-code/first-steps-with-openstacksdk/
    - /develop-design/infrastructure-via-code/first-steps-with-openstacksdk/
    - /docs/devel/infrastructure-via-code/first-steps-with-openstacksdk/
    - /devel/first-steps-withopenstacksdk/
    - /devel/infrastructure-via-code/first-steps-with-openstacksdk/
title: "IvC: OpenStackSDK first steps"
date: 2021-06-06T15:29:14-04:00
publishDate: 2021-06-06T17:14:46-04:00
author: Daniel F. Dickinson
series:
    - infrastructure-via-code-openstack
tags:
    - archived
    - deploy
    - sysadmin-devops
    - python
description: "Since OpenStackSDK should theoretically make life easier for doing Infrastructure via Code, this is approach which which this learning effort has begun."
summary: "Since OpenStackSDK should theoretically make life easier for doing Infrastructure via Code, this is approach which which this learning effort has begun."
toc: true
weight: 10300
---

{{< details-toc >}}

## Preface

>[The OpenStack SDK](https://docs.openstack.org/openstacksdk/latest/) is a OpenStack project aimed at providing a complete software development kit for the programs which make up the OpenStack community. It is a Python library with corresponding documentation, examples, and tools released under the Apache 2 license.

— [OpenStackSDK Docs: About the Project](https://docs.openstack.org/openstacksdk/latest/contributor/index.html#about-the-project)

The OpenStack SDK aims to replace use of individual OpenStack client libraries (e.g. python-glanceclient, python-neutronclient, python-novaclient etc) for controlling OpenStack clouds via code, and as I understand it, is considered the preferred means of programmatically controlling OpenStack in new projects.

Since it should theoretically make life easier for doing [Infrastructure via Code](_index.md), this is approach which which this learning journey has begun.

The scripts described on this page are available in a Git repo @ <https://github.com/wildtechgarden/ivc-in-the-wtg-experiments>

## Prerequisite Config

Aside from [installing the OpenStack SDK](https://docs.openstack.org/openstacksdk/latest/install/index.html) itself, it is necessary to create a configuration. The chosen approach was to use ``clouds.yaml`` in the same directory as the scripts.

``clouds.yaml``

```yaml
clouds:
  ovh:
    profile: ovh
    auth:
      auth_url: https://auth.cloud.ovh.net/v3/
      username: 'user-XXXXXXXXXXXXXXXX'
      user_domain_id: default
      tenant_name: 'a_redacted_tenant_name'
      project_domain_id: default
      project_id: 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
    region_name: FAK1
    interface: public
    identity_api_version: 3
```

## One Step Backward, Two Steps Forward

A first attempt at using the OpenStackSDK ran into a bug, but two subsequent experiments went well.

### The OpenStack SDK Isn't Perfect

The first project attempted was to generate and use a token to list servers currently running on an OpenStack Project. This ran into [LP#1437976](https://bugs.launchpad.net/python-keystoneclient/+bug/1437976). As you can this isn't a problem with the sdk per se, rather the issue occurs in an underlying library.

The issue occurs with tokens created using ``openstack token issue`` as well as the following programmatic approach:

``get-os-compute-token.py``

```python
from getpass import getpass
import openstack

os_pass = getpass("Enter your password: ")

conn = openstack.connect(cloud='ovh', password=os_pass)
print("Your token is: ")
print(conn.authorize())
```

The failing code to list existing servers (virtual machines), with ``token: the_token`` instead of ``username: a_user_name`` in the ``clouds.yaml``:

``os-list-instances.py``

```python
import openstack

conn = openstack.connect(cloud='ovh')

servers = conn.list_servers()

for server in servers:
    print(server.name)
```

#### Using a Username and Password Worked

Removing the ``token: the_token`` and using the following code instead worked, as did using the above script with a username and password in ``clouds.yaml`` (It is better not to keep credentials lying around in plaintext, hence the following):

``os-list-instances.py``

```python
import openstack
from getpass import getpass

username = input("Enter your username: ")
password = getpass("Enter your password: ")

conn = openstack.connect(cloud='ovh', username=username, password=password)

servers = conn.list_servers()

for server in servers:
    print(server.name)
```

### Creating a Basic Instance

The next experiment was a very basic instance creation, with a preferred username and provisioning SSH key and password (and no passwordless sudo).

For that the following script was created, with relative ease:

``create-basic-instance.py``

```python
import sys
import openstack
from getpass import getpass

username = input("Enter your username: ")
password = getpass("Enter your password: ")
server_name = input("Enter a name for your server: ")

conn = openstack.connect(cloud='ovh', username=username, password=password)

image = conn.get_image("user-base-0.3.2")
flavor = conn.get_flavor("d2-2")
network = conn.get_network("Ext-Net")

server = conn.get_server(server_name, bare=True)

userdata = """
#cloud-config
disable_root: true
preserve_hostname: false
manage_etc_hosts: true
ssh_pwauth: false
users:
  - name: anadmin
    groups:
      - adm
      - staff
      - sudo
    homedir: /local-home/anadmin
    lock_passwd: false
    hashed_passwd: $6$rounds=4096$Uai52ED7FnpSxVd1$iY6tuSJ2dpm1Owa41NUSvp/H1M39ZnVjiP9OWK3r9I/mm4lV.vaHlUodCWQOUGv9paOHZa8gh/9MX4.It6cAH/
    shell: /bin/bash
    ssh_authorized_keys:
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC43t3iUh8uqWzajviRlEtIrrVPyEHHNFG2/Ne57/CwLq2ptqCN/VEG9OAmlkMTYkZU5AMAtpe3HYl1YsCgNLdxZlmaHVffGMPwaUxEYOtqyOMhqjJr95S8cfnZ/uQ6to+HwEPpxA3GOEURXU5ti5mpecwI2YKA4mvHwYjkDKq+bnLtSTg/+iQcTC/kX0efU4VIZ5tSDHiL8DuTzpS+g7euqLSaABQjMGJ0819bPs8zc/NP1Vx3oql2QrUuTrWcneYSqn71VvCIpjeAJ0j9PHWmlcL3rdc9NF0sk7ZCixhKvvHRdmCWWUTJ0Aaw66T7By+a3wwlhcY2/tpQHJltGBWVTRQS0eMit18DCOr5oLgf7xAQkZrWXCIRbbgxBY+hOFITkXM4vXyVfzYZ0WiBATp0UtKor+SR3MPcXkX8t+ok4IWvlxmB81E+NOFyKyw1ysDMwLPtOy2YiOdIWIWkPe6M2ih0BDPGxx5fSig7819Jo99gsrU6gc02zR8OUCuWy/M= demo@keygen
timezone: America/Toronto
write_files:
  - path: /etc/byobu/autolaunch
  - path: /etc/ssh/sshd_config.d/pubkey_only.conf
    content: |
      PasswordAuthentication no
      PubkeyAuthentication yes
  - path: /etc/ssh/sshd_config.d/alternate_port.conf
    content: |
      Port 27221
"""

if server is not None:
    yesno = input("Server already exists; delete it? (Must enter 'yes' in all caps, followed by ENTER key): ")
    if yesno != "YES":
        print("Bailing...")
        sys.exit(1)

    yesno = input("I know you hate this, but are you really sure? (Must enter 'YES' all lower case, followed by ENTER key): ")
    if yesno != 'yes':
        print("Bailing...")
        sys.exit(1)

    if conn.delete_server(server, True, 600):
        print("Server successfully deleted")
    else:
        print("Weird. Server doesn't exist. Bailing...")
        sys.exit(2)

server = conn.create_server(server_name, image=image, flavor=flavor, network=network, userdata=userdata, wait=True, timeout=600)

print("ip: {ip}".format(ip=server.accessIPv4))
```

### A More Complete Basic Instance Creation Script

This script introduces basic usage of the [configparser](https://docs.python.org/3/library/configparser.html) to configure the creation of a set of instances, as well as introducing logic to better handle missing or not found resources, missing configuration, etc.

The userdata was moved unchanged into a file called ``userdata-basic-instance.yaml``, and a config file called ``basic-instance.ini`` was created.

``basic-instance.ini``

```ini
[DEFAULT]
cloud = ovh
username = user-XXXXXXXXXXXX
image = user-base-0.3.2
flavor = d2-2
network = Ext-Net

[server1]
server_name = pytest001

[server2]
server_name = pytest002
delete_if_exists = yes
```

``create-basic-instances-from-config.py``

```python
import sys
import openstack
from getpass import getpass
import configparser

passwords = {}

config = configparser.ConfigParser(
    defaults={
        "delete_if_exists": "no",
        "remember_password": "yes",
        "userdata": "userdata-basic-instance.yaml",
    }
)

readfile = config.read("basic-instance.ini")

if len(readfile) < 1:
    print("Failed to read config file. Bailing...", file=sys.stderr)
    sys.exit(1)

print("Creating {num_servers} servers".format(num_servers=(len(config.sections()))))

for section in config.sections():
    sectmap = config[section]
    username = sectmap["username"]
    remember_password = sectmap.getboolean("remember_password")
    delete_if_exists = sectmap.getboolean("delete_if_exists")

    password = passwords.get(username)
    if password is None:
        password = getpass(
            "Enter your password for user {username}: ".format(username=username)
        )
        if remember_password:
            passwords[username] = password

    conn = openstack.connect(
        cloud=sectmap["cloud"], username=username, password=password
    )
    server = conn.get_server(sectmap["server_name"], bare=True)

    image = conn.get_image(sectmap["image"])
    if image is None:
        print(
            "Unable to find image {image}. Bailing...".format(image=sectmap["image"]),
            file=sys.stderr,
        )
        sys.exit(1)
    flavor = conn.get_flavor(sectmap["flavor"])
    if flavor is None:
        print(
            "Unable to find flavor {flavor}. Bailing...".format(
                flavor=sectmap["flavor"]
            ),
            file=sys.stderr,
        )
        sys.exit(1)
    network = conn.get_network(sectmap["network"])
    if network is None:
        print(
            "Unable to find network {network}. Bailing...".format(
                image=sectmap["network"]
            ),
            file=sys.stderr,
        )
        sys.exit(1)

    userdatafile = open(sectmap["userdata"], "r")
    userdata = userdatafile.read()
    userdatafile.close()

    if server is not None:
        if delete_if_exists:
            if conn.delete_server(server, True, 600):
                print("Server {server_name} successfully deleted".format(
                    server_name=sectmap["server_name"]
                ))
            else:
                print(
                    "Weird. Server {server_name} doesn't exist after all. Bailing...".format(
                        server_name=sectmap["server_name"]
                    ),
                    file=sys.stderr,
                )
                sys.exit(1)
        else:
            print(
                "Server {server_name} exists and delete_if_exists is False. Skipping to next server".format(
                    server_name=sectmap["server_name"]
            ))
            continue

    server = conn.create_server(
        sectmap['server_name'],
        image=image,
        flavor=flavor,
        network=network,
        userdata=userdata,
        wait=True,
        timeout=600,
    )

    if server is not None:
        print("Created server {server_name} with ip {ip}.".format(server_name=sectmap['server_name'], ip=server.accessIPv4))
```

## Conclusion

So far, aside from the token issue, using the OpenStack SDK and Python to create instances has been quite easy, and there has been sufficient (and correct) documentation of the ``Connection`` object which so far has been able to readily meet the requests that have been needed to be made.

There were of course the usual typos and bloopers, but those were easily solved.

Overall the OpenStack SDK looks like it will be able to provide all the functionality this 'Infrastructure via Code' project will require.

## Next Steps with OpenStack SDK

* Adding additional instance creation details like security groups, private networks (when needed), and attaching existing volumes
* Using Jinja to create 'userdata' base templates and user templates
* More complex userdata scenarios

In short creating a sufficiently complete scripting environment to manage the desired OpenStack infrastructure.
