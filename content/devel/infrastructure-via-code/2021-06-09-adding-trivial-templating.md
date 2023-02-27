---
slug: adding-trivial-templating
aliases:
    - /projects/experimental-learning/infrastructure-via-code/adding-trivial-templating/
    - /develop-design/infrastructure-via-code/adding-trivial-templating/
    - /docs/devel/infrastructure-via-code/adding-trivial-templating/
    - /devel/adding-trivial-templating/
title: "ARCHIVED: IvC: Adding trivial templating"
date: 2021-06-09T13:32:13-04:00
publishDate: 2021-06-11T18:29:35-04:00
author: Daniel F. Dickinson
series:
    - infrastructure-via-code-openstack
tags:
    - archived
    - devel
    - experimentation
    - infrastructure-via-code
    - jinja
    - learning
    - openstack
    - projects
    - python
    - sysadmin-devops
    - templating
description: "We start with a separate script that only generates userdata (no instance creation)."
summary: "We start with a separate script that only generates userdata (no instance creation)."
weight: 10400
---

{{< details summary="What is in this article" >}}
{{< toc >}}
{{< /details >}}

## Preface

### Code

The scripts described on this page are available in a Git repo @ <https://github.com/danielfdickinson/ivc-in-the-wtg-experiments>.

## First, Just a Template

We start with a separate script that only generates userdata (no instance creation).

### Configuration File

Note that we take advantage of the [DEFAULT] section to avoid writing ``admin_user_password`` and ``admin_user_ssh_pubkeys`` for every instance. Also note, that if those are the only two variables the ``instance_name-userdata-vars`` sections are optional.

``create-instances.ini``

```ini
[DEFAULT]
cloud = ovh
username = user-XXXXXXXXXXXX
image = user-base-0.3.2
flavor = d2-2
network = Ext-Net
#delete_if_exists = no
#remember_password = yes
#userdata = userdata-default.yaml.jinja
#security_groups = default
#config_drive = no
#volumes =
#secondary_network =
admin_user_password = $6$rounds=4096$Uai52ED7FnpSxVd1$iY6tuSJ2dpm1Owa41NUSvp/H1M39ZnVjiP9OWK3r9I/mm4lV.vaHlUodCWQOUGv9paOHZa8gh/9MX4.It6cAH/
admin_user_ssh_pubkeys = ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC43t3iUh8uqWzajviRlEtIrrVPyEHHNFG2/Ne57/CwLq2ptqCN/VEG9OAmlkMTYkZU5AMAtpe3HYl1YsCgNLdxZlmaHVffGMPwaUxEYOtqyOMhqjJr95S8cfnZ/uQ6to+HwEPpxA3GOEURXU5ti5mpecwI2YKA4mvHwYjkDKq+bnLtSTg/+iQcTC/kX0efU4VIZ5tSDHiL8DuTzpS+g7euqLSaABQjMGJ0819bPs8zc/NP1Vx3oql2QrUuTrWcneYSqn71VvCIpjeAJ0j9PHWmlcL3rdc9NF0sk7ZCixhKvvHRdmCWWUTJ0Aaw66T7By+a3wwlhcY2/tpQHJltGBWVTRQS0eMit18DCOr5oLgf7xAQkZrWXCIRbbgxBY+hOFITkXM4vXyVfzYZ0WiBATp0UtKor+SR3MPcXkX8t+ok4IWvlxmB81ENOFyKyw1ysDMwLPtOy2YiOdIWIWkPe6M2ih0BDPGxx5fSig7819Jo99gsrU6gc02zR8OUCuWy/M= demo@keygen:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPx1XkJr+YY1eiPq1kVSuqv7ufMppwd+9JN2NnyQWkn7 another_key@keygen

[pytest001]
server_name = pytest001
delete_if_exists = yes
volumes = testvol1-data

[pytest002]
server_name = pytest002
security_groups = default:public_webapps_in
delete_if_exists = yes
secondary_network = private-ovh-net

[pytest002-userdata-vars]

```

### The Template

The ``.jinja`` extension is not required by the script, but makes it easier for some editors and IDE to properly handle the jinja template.

Note the use of ``{%-``, ``-}}`` to trim unwanted whitespace.

You might want to check the [complete documentation of Jinja2](https://jinja.palletsprojects.com/en/3.0.x/) to write better templates.

``userdata.yaml.jinja``

```yaml
#cloud-config
disable_root: true
preserve_hostname: false
manage_etc_hosts: true
ssh_pwauth: false
users:
  - name: aideraan
    groups:
      - adm
      - staff
      - sudo
    homedir: /local-home/aideraan
    lock_passwd: false
    hashed_passwd: {{ admin_user_password }}
    shell: /bin/bash
    ssh_authorized_keys:
    {%- for admin_user_ssh_pubkey in admin_user_ssh_pubkeys.split(":") %}
      - {{ admin_user_ssh_pubkey -}}
    {% endfor %}
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

```

### The Script

Note the use of ``StrictUndefined`` so that any variable in the in the template for which a value is not defined in the configuration file results in an ``UndefinedError`` exception. We do this because forgetting to define a variable is a very easy mistake to make.  With this, if you want to allow a varible to have no value, you will need to explicitly handle that in your templates.

``generate-userdata.py``

```python
import os
import sys

import configparser
from jinja2 import Environment, FileSystemLoader, select_autoescape, StrictUndefined
from jinja2.exceptions import UndefinedError


def read_config(
    defaults={
        "delete_if_exists": "no",
        "remember_password": "yes",
        "userdata": "userdata-default.yaml.jinja",  # This can be overridden in the INI file, globally or per-instance
        "security_groups": "default",
        "config_drive": "no",
    },
    configfile="create-instances.ini",
):

    config = configparser.ConfigParser(defaults=defaults, interpolation=None)

    readfile = config.read(configfile)

    if len(readfile) < 1:
        print("Failed to read config file. Bailing...", file=sys.stderr)
        sys.exit(1)

    return config


def apply_userdata_template(userdatafile, userdata_vars, server_name):
    jinja_env = Environment(
        loader=FileSystemLoader(os.getcwd()),
        autoescape=select_autoescape(),
        undefined=StrictUndefined,
    )
    jinja_template = jinja_env.get_template(userdatafile)

    userdata_vars["server_name"] = server_name

    return jinja_template.render(userdata_vars)


def main():
    print("Generating userdata")
    config = read_config()
    for section in config.sections():
        if not section.endswith("-userdata-vars"):
            server_name = section
            userdata_vars = {}
            if (section + "-userdata-vars") in config:
                userdata_vars = config[section + "-userdata-vars"]
            else:
                userdata_vars = config[config.default_section]
            userdatafile = config[section]["userdata"]

            print(
                "    Userdata for server {server_name}:".format(server_name=server_name)
            )
            try:
                userdata = apply_userdata_template(
                    userdatafile, userdata_vars, server_name
                )

                print(userdata)
            except UndefinedError as ue:
                print("    Error: {msg}".format(msg=ue.message))
                continue
        else:
            continue


if __name__ == "__main__":
    main()

```

### The Generated User Data for pytest001

```yaml
#cloud-config
disable_root: true
preserve_hostname: false
manage_etc_hosts: true
ssh_pwauth: false
users:
  - name: aideraan
    groups:
      - adm
      - staff
      - sudo
    homedir: /local-home/aideraan
    lock_passwd: false
    hashed_passwd: $6$rounds=4096$Uai52ED7FnpSxVd1$iY6tuSJ2dpm1Owa41NUSvp/H1M39ZnVjiP9OWK3r9I/mm4lV.vaHlUodCWQOUGv9paOHZa8gh/9MX4.It6cAH/
    shell: /bin/bash
    ssh_authorized_keys:
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC43t3iUh8uqWzajviRlEtIrrVPyEHHNFG2/Ne57/CwLq2ptqCN/VEG9OAmlkMTYkZU5AMAtpe3HYl1YsCgNLdxZlmaHVffGMPwaUxEYOtqyOMhqjJr95S8cfnZ/uQ6to+HwEPpxA3GOEURXU5ti5mpecwI2YKA4mvHwYjkDKq+bnLtSTg/+iQcTC/kX0efU4VIZ5tSDHiL8DuTzpS+g7euqLSaABQjMGJ0819bPs8zc/NP1Vx3oql2QrUuTrWcneYSqn71VvCIpjeAJ0j9PHWmlcL3rdc9NF0sk7ZCixhKvvHRdmCWWUTJ0Aaw66T7By+a3wwlhcY2/tpQHJltGBWVTRQS0eMit18DCOr5oLgf7xAQkZrWXCIRbbgxBY+hOFITkXM4vXyVfzYZ0WiBATp0UtKor+SR3MPcXkX8t+ok4IWvlxmB81ENOFyKyw1ysDMwLPtOy2YiOdIWIWkPe6M2ih0BDPGxx5fSig7819Jo99gsrU6gc02zR8OUCuWy/M= demo@keygen
      - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPx1XkJr+YY1eiPq1kVSuqv7ufMppwd+9JN2NnyQWkn7 another_key@keygen
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
```

## Combine Template With Instance Creation

While we're at it, improve the underlying script. We using the same data and config files as above.

* Use reasonable functions to perform most of the action rather than one big code block
* Make the main function a function instead of just a code block, in case we decide to import action functions into other scripts
* Require that server section names match the ``server_name``

``create-instances.py``

```python
#!/usr/bin/env python3
# -*- encoding: utf-8 -*-

import os
import sys
from typing import Collection, Mapping
import collections

import openstack
from getpass import getpass
import configparser
import munch
from jinja2 import Environment, FileSystemLoader, select_autoescape, StrictUndefined
from jinja2.exceptions import UndefinedError


def get_named_resource(method, res_type_name, name):
    print(
        "    Getting {res_type} named {res_name}".format(
            res_type=res_type_name, res_name=name
        )
    )
    value = method(name)
    if value is None:
        print(
            "    ** Failed to find {res_type} named {res_name}.".format(
                res_type=res_type_name, res_name=name
            ),
            file=sys.stderr,
        )
    return value


def get_named_resource_list(
    method, res_type_name, name_list_str, sep=":", error_if_not_found=True
):
    result_names = []
    result_objects = []
    name_list = name_list_str.split(sep)
    if "" in name_list:
        print(
            "    ** Empty {res_type_name}. Invalid config.".format(
                res_type_name=res_type_name
            ),
            file=sys.stderr,
        )
        result_names = None
        result_objects = None
    else:
        for named_item in name_list:
            item_munch = get_named_resource(method, res_type_name, named_item)
            if item_munch is not None:
                result_names.append(named_item)
                result_objects.append(item_munch)
            else:
                if error_if_not_found:
                    result_names = None
                    result_objects = None
                    break
                # else we just ignore the missing resource
    return result_names, result_objects


def map_or_list_contains_None(maplist):
    if maplist is None:
        return True
    elif isinstance(maplist, munch.Munch):
        return False
    elif isinstance(maplist, collections.abc.Mapping):
        for key, value in maplist.items():
            if map_or_list_contains_None(value):
                return True
    elif isinstance(maplist, list):
        for value in maplist:
            if map_or_list_contains_None(value):
                return True
    else:
        return False


def read_config(
    defaults={
        "delete_if_exists": "no",
        "remember_password": "yes",
        "userdata": "userdata-default.yaml.jinja",  # This can be overridden in the INI file, globally or per-instance
        "security_groups": "default",
        "config_drive": "no",
    },
    configfile="create-instances.ini",
):

    config = configparser.ConfigParser(defaults=defaults, interpolation=None)

    readfile = config.read(configfile)

    if len(readfile) < 1:
        print("Failed to read config file. Bailing...", file=sys.stderr)
        sys.exit(1)

    return config


def get_connection(passwords, sectmap):
    username = sectmap["username"]
    remember_password = sectmap.getboolean("remember_password")

    password = passwords.get(username)
    if password is None:
        password = getpass(
            "Enter password for user {username}: ".format(username=username)
        )
        if remember_password:
            passwords[username] = password

    conn = openstack.connect(
        cloud=sectmap["cloud"], username=username, password=password
    )

    return conn


def get_resources(conn, sectmap):
    resources = {}

    resources["image"] = get_named_resource(
        conn.get_image, "boot image", sectmap["image"]
    )

    resources["flavor"] = get_named_resource(
        conn.get_flavor, "instance flavor", sectmap["flavor"]
    )

    resources["network"] = get_named_resource(
        conn.get_network, "primary network", sectmap["network"]
    )

    resources["security_groups"], __ = get_named_resource_list(
        conn.get_security_group, "security group", sectmap["security_groups"]
    )

    if (sectmap.get("volumes") is not None) and (sectmap.get("volumes") != ""):
        __, resources["volumes"] = get_named_resource_list(
            conn.get_volume, "volume", sectmap["volumes"]
        )

    if (sectmap.get("secondary_network") is not None) and (
        sectmap.get("secondary_network") != ""
    ):
        secondary_network = get_named_resource(
            conn.get_network, "secondary network", sectmap["secondary_network"]
        )
        if secondary_network is None:
            print(
                "  ** Skipping to next server due to missing resource",
                file=sys.stderr,
            )
            return None

        resources["network"] = [resources["network"], secondary_network]

    if map_or_list_contains_None(resources):
        print(
            "  ** Skipping to next server due to missing resource",
            file=sys.stderr,
        )
        return None

    return resources


def delete_existing_server(conn, sectmap, servers_deleted):
    delete_if_exists = sectmap.getboolean("delete_if_exists")
    existing_server = conn.get_server(sectmap["server_name"], bare=True)

    if existing_server is not None:
        if delete_if_exists:
            print(
                "  Deleting existing server {server_name}, per delete_if_exists".format(
                    server_name=sectmap["server_name"]
                )
            )

            if conn.delete_server(existing_server, True, 600):
                print(
                    "  Server {server_name} successfully deleted".format(
                        server_name=sectmap["server_name"]
                    )
                )
                servers_deleted.append(sectmap["server_name"])
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
                "  Server {server_name} exists and delete_if_exists is False. Skipping to next server".format(
                    server_name=sectmap["server_name"]
                )
            )
            return False

    return True


def apply_userdata_template(userdatafile, userdata_vars, server_name):
    jinja_env = Environment(
        loader=FileSystemLoader(os.getcwd()),
        autoescape=select_autoescape(),
        undefined=StrictUndefined,
    )
    jinja_template = jinja_env.get_template(userdatafile)

    userdata_vars["server_name"] = server_name

    return jinja_template.render(userdata_vars)


def get_userdata(config, section):
    userdata = None

    userdata_vars = {}
    if (section + "-userdata-vars") in config:
        userdata_vars = config[section + "-userdata-vars"]
    else:
        userdata_vars = config[config.default_section]

    userdatafile = config[section]["userdata"]

    print(
        "    Generating userdata for server {server_name}".format(server_name=section)
    )
    try:
        userdata = apply_userdata_template(userdatafile, userdata_vars, section)
    except UndefinedError as ue:
        print("    Error: {msg}".format(msg=ue.message))

    return userdata


def main():
    passwords = {}
    servers_created = {}
    servers_deleted = []
    num_servers = 0

    config = read_config()

    for section in config.sections():
        if ("server_name" in config[section]) and (
            section == config[section]["server_name"]
        ):
            num_servers = num_servers + 1

    print("Creating {num_servers} servers".format(num_servers=num_servers))

    for section in config.sections():
        resources = {}
        sectmap = config[section]

        # Only process server sections (section name is server_name)
        if section != sectmap["server_name"]:
            continue

        print("Processing server {server_name}".format(server_name=section))

        conn = get_connection(passwords, sectmap)
        resources = get_resources(conn, sectmap)

        if resources is None:
            continue

        userdata = get_userdata(config, section)

        if userdata is None:
            continue

        if not delete_existing_server(conn, sectmap, servers_deleted):
            continue

        print(
            "    Creating server {server_name}".format(
                server_name=sectmap["server_name"]
            )
        )

        config_drive = sectmap.getboolean("config_drive")

        server = conn.create_server(
            sectmap["server_name"],
            image=resources["image"],
            flavor=resources["flavor"],
            network=resources["network"],
            security_groups=resources["security_groups"],
            volumes=resources.get("volumes"),
            config_drive=config_drive,
            userdata=userdata,
            wait=True,
            timeout=600,
        )

        if server is not None:
            assigned_ip = server.accessIPv4
            if (server.accessIPv4 is None) or (server.accessIPv4 == ""):
                if server.addresses.get(sectmap["network"]) is not None:
                    assigned_ip = server.addresses.get(sectmap["network"])[0]["addr"]
            print(
                "Created server {server_name} with ip '{ip}'.".format(
                    server_name=server.name, ip=assigned_ip
                )
            )
            servers_created[server.name] = assigned_ip

    if len(servers_deleted) < 1:
        print("No servers deleted")
    else:
        print("Successfully deleted the following servers:")
        for server_name in servers_deleted:
            print(server_name)
    print("Successfully created the following servers:")
    for server_name, assigned_ip in servers_created.items():
        print(
            "{server_name}: {assigned_ip}".format(
                server_name=server_name, assigned_ip=assigned_ip
            )
        )


if __name__ == "__main__":
    main()

```

## Next Steps

* Use more complete/complex userdata
* We will need to read/include files to include in the userdata gzipped and base64 encoded.
* We will handle orchestration via files / scripts included in the userdata rather than external orchestrations
  * This avoids the need for passwordless admin access or keeping plaintext admin passwords on any system (even local).
  * In part this depends on working DNS
  * We also stand up a HashiCorp 'Vault' instance for the required secrets.
