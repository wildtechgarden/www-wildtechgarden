---
slug: just-a-template
aliases:
    - /projects/experimental-learning/infrastructure-via-code/continuing-openstacksdk-with-templating/just-a-template/
    - /develop-design/infrastructure-via-code/continuing-openstacksdk-with-templating/just-a-template/
    - /docs/devel/infrastructure-via-code/continuing-openstacksdk-with-templating/just-a-template/
    - /devel/continuing-openstacksdk-with-templating/just-a-template/
title: "First, just a template"
date: 2021-06-13T19:29:29-04:00
publishDate: 2021-06-15T19:17:10-04:00
author: Daniel F. Dickinson
series:
    - infrastructure-via-code-openstack
tags:
    - archived
    - devel
    - sysadmin-devops
    - experimentation
    - infrastructure-via-code
    - jinja
    - learning
    - openstack
    - projects
    - python
    - templating
description: "Adding more a complete template to an OpenSDK-based templated instance deployment"
summary: "Adding more a complete template to an OpenSDK-based templated instance deployment"
weight: 10620
---

{{< details summary="What is in this article" >}}
{{< toc >}}
{{< /details >}}

## A Basic Template

This first section on this page doesn't add new elements to the script code, but implements a more complex template. Since this is user-supplied data, this is more of template example than a code update.

First the template:

``userdata-default.yaml.jinja``

```yaml
#cloud-config
disable_root: true
preserve_hostname: false
manage_etc_hosts: true
ssh_pwauth: false
users:
  - name: {{ admin_username }}
    groups:
      - adm
      - staff
      - sudo
    homedir: /local-home/{{ admin_username }}
    lock_passwd: false
    hashed_passwd: {{ admin_user_password }}
    shell: /bin/bash
    ssh_authorized_keys:
    {%- for admin_user_ssh_pubkey in admin_user_ssh_pubkeys.split(":") %}
      - {{ admin_user_ssh_pubkey -}}
    {% endfor %}
timezone: {{ instance_timezone }}
hostname: {{ instance_hostname }}
fqdn: {{ instance_fqdn }}
{%- if ntp_client %}
ntp:
  {%- if ntp_client == "chrony" %}
  ntp_client: chrony
  enabled: true
  {%- else %}
  enabled: true
  {%- endif %}
  {%- if ntp_servers %}
  servers:
    {%- for ntp_server in ntp_servers.split() %}
    - {{ ntp_server -}}
    {% endfor %}
  {%- endif %}
{%- endif %}
package_update: true
package_upgrade: true
{%- if packages %}
packages:
  {%- for package in packages.split() %}
  - {{ package -}}
  {% endfor %}
{%- endif %}
package_reboot_if_required: true
{%- if mounts %}
mounts:
  {%- for mount in mounts.split("\n") %}
  - {{ mount -}}
  {%- endfor -%}
{%- endif -%}

```

Then the config file:

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
admin_username = anadmin
admin_user_password = $6$rounds=4096$Uai52ED7FnpSxVd1$iY6tuSJ2dpm1Owa41NUSvp/H1M39ZnVjiP9OWK3r9I/mm4lV.vaHlUodCWQOUGv9paOHZa8gh/9MX4.It6cAH/
admin_user_ssh_pubkeys = ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC43t3iUh8uqWzajviRlEtIrrVPyEHHNFG2/Ne57/CwLq2ptqCN/VEG9OAmlkMTYkZU5AMAtpe3HYl1YsCgNLdxZlmaHVffGMPwaUxEYOtqyOMhqjJr95S8cfnZ/uQ6to+HwEPpxA3GOEURXU5ti5mpecwI2YKA4mvHwYjkDKq+bnLtSTg/+iQcTC/kX0efU4VIZ5tSDHiL8DuTzpS+g7euqLSaABQjMGJ0819bPs8zc/NP1Vx3oql2QrUuTrWcneYSqn71VvCIpjeAJ0j9PHWmlcL3rdc9NF0sk7ZCixhKvvHRdmCWWUTJ0Aaw66T7By+a3wwlhcY2/tpQHJltGBWVTRQS0eMit18DCOr5oLgf7xAQkZrWXCIRbbgxBY+hOFITkXM4vXyVfzYZ0WiBATp0UtKor+SR3MPcXkX8t+ok4IWvlxmB81ENOFyKyw1ysDMwLPtOy2YiOdIWIWkPe6M2ih0BDPGxx5fSig7819Jo99gsrU6gc02zR8OUCuWy/M= demo@keygen:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPx1XkJr+YY1eiPq1kVSuqv7ufMppwd+9JN2NnyQWkn7 another_key@keygen
instance_timezone = America/Toronto

[pytest001]
server_name = pytest001
delete_if_exists = yes
secondary_network = private-ovh-net

[pytest001-userdata-vars]
instance_hostname = pytest001
instance_fqdn = pytest001.example.com
ntp_client = chrony
ntp_servers =
packages = apt-cacher-ng
 dnsmasq
 postfix
mounts = [ "/dev/avg1/vault", "/opt/vault", "ext4", "defaults,noexec,nodev", "0", "2" ]
 [ "/dev/avg1/configs", "/opt/configs", "ext4", "defaults,noexec,nodev", "0", "2" ]

[pytest002]
server_name = pytest002
delete_if_exists = yes

pytest002-userdata-vars]
instance_hostname = pytest002
instance_fqdn = pytest002.private.example.com
ntp_client = yes
ntp_servers = 192.168.35.2
packages = dovecot-core
 dovecot-imapd
 dovecot-lmtpd
 dovecot-managesieved
 dovecot-pgsql
 dovecot-submissiond
 mutt
 postfix
mounts = [ "/dev/dovevg1/vmail", "/var/vmail", "ext4", "defaults,nodev", "0", "2" ]
 [ "/dev/dovevg1/etcdata", "/etc/dovecot/etcdata", "ext4", "defaults,noexec,nodev", "0", "2" ]

[pytest003]
server_name = pytest003
delete_if_exists = yes

[pytest003-userdata-vars]
instance_hostname = pytest003
instance_fqdn = pytest003.example.com
ntp_client =
ntp_servers =
packages =
mounts =

```

and the template only script:

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

Next: [Adding basic write_files support](adding-basic-write-files-support.md)
