---
slug: adding-basic-write-files-support
aliases:
    - /projects/experimental-learning/infrastructure-via-code/continuing-openstacksdk-with-templating/adding-basic-write-files-support/
    - /develop-design/infrastructure-via-code/continuing-openstacksdk-with-templating/adding-basic-write-files-support/
    - /docs/devel/infrastructure-via-code/continuing-openstacksdk-with-templating/adding-basic-write-files-support/
    - /devel/continuing-openstacksdk-with-templating/adding-basic-write-files-support/
    - /devel/infrastructure-via-code/continuing-openstacksdk-with-templating/adding-basic-write-files-support/
title: "Adding basic write_files support"
date: 2021-06-13T19:29:29-04:00
publishDate: 2021-06-15T19:17:10-04:00
author: Daniel F. Dickinson
series:
    - infrastructure-via-code-openstack
tags:
    - archived
    - deploy
    - python
description: "Adding basic support for cloud-init 'write_files' in an OpenSDK-based templated instance deployment"
summary: "Adding basic support for cloud-init 'write_files' in an OpenSDK-based templated instance deployment"
weight: 10630
---

{{< details-toc >}}

## Implementation

We now add an important piece: write_files support. In this implementation we:

1. Take a colon separated list of local directory names
2. For each directory we process every file in the directory (last directory wins in the case of duplicates)
3. Processing each file means:
   1. We determine the target path the for the file by stripping the passed in directory name (so ``passed/in/dir/etc/aliases`` becomes ``/etc/aliases``)
   2. We read the file
   3. If possible we 'gzip' (compress) it
   4. We base64 encode it (this avoids problems with characters in the file being interpreted by cloud-init as having meaning other than being just data; for example it avoids quoting and whitespace issues).
   5. We look in the config ``ini`` for optional variables in the current ``-userdata-vars`` section that match the following:
      1. Begins with the target path with the initial forward slash (``/``) stripped and all forward slashes ``/`` and periods ``.`` transformed into hyphens ``-``
      2. Each of the following endings:
         1. ``-permissions``: A string representing the octal mode for the file
         2. ``-owner``: A string representing the ``user:group`` for the file
         3. ``-append``: A boolean representing whether to append the supplied file to an existing file, if the file already exists in the instance.

Example output ``userdata``:

```yaml
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
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC43t3iUh8uqWzajviRlEtIrrVPyEHHNFG2/Ne57/CwLq2ptqCN/VEG9OAmlkMTYkZU5AMAtpe3HYl1YsCgNLdxZlmaHVffGMPwaUxEYOtqyOMhqjJr95S8cfnZ/uQ6to+HwEPpxA3GOEURXU5ti5mpecwI2YKA4mvHwYjkDKq+bnLtSTg/+iQcTC/kX0efU4VIZ5tSDHiL8DuTzpS+g7euqLSaABQjMGJ0819bPs8zc/NP1Vx3oql2QrUuTrWcneYSqn71VvCIpjeAJ0j9PHWmlcL3rdc9NF0sk7ZCixhKvvHRdmCWWUTJ0Aaw66T7By+a3wwlhcY2/tpQHJltGBWVTRQS0eMit18DCOr5oLgf7xAQkZrWXCIRbbgxBY+hOFITkXM4vXyVfzYZ0WiBATp0UtKor+SR3MPcXkX8t+ok4IWvlxmB81ENOFyKyw1ysDMwLPtOy2YiOdIWIWkPe6M2ih0BDPGxx5fSig7819Jo99gsrU6gc02zR8OUCuWy/M= demo@keygen
      - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPx1XkJr+YY1eiPq1kVSuqv7ufMppwd+9JN2NnyQWkn7 another_key@keygen
timezone: America/Toronto
hostname: pytest001
fqdn: pytest001.example.com
ntp:
  ntp_client: chrony
  enabled: true
package_update: true
package_upgrade: true
packages:
  - apt-cacher-ng
  - dnsmasq
  - postfix
package_reboot_if_required: true
mounts:
  - [ "/dev/avg1/vault", "/opt/vault", "ext4", "defaults,noexec,nodev", "0", "2" ]
  - [ "/dev/avg1/configs", "/opt/configs", "ext4", "defaults,noexec,nodev", "0", "2" ]
  - path: /etc/sysctl.conf
    append: true
    encoding: b64
    content: |
      bmV0LmlwdjQuaXBfZm9yd2FyZD0xCg==
  - path: /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
    encoding: b64
    content: |
      bmV0d29yazoge2NvbmZpZzogZGlzYWJsZWR9
  - path: /etc/systemd/system/set-ipv6-netplan-once.service
    encoding: b64
    content: |
      W1VuaXRdCkRlc2NyaXB0aW9uPVNldCBOZXRwbGFuIGZvciBJUHY2IE9uY2UKCltTZXJ2aWNlXQpUeXBlPW9uZXNob3QKRXhlY1N0YXJ0PS91c3IvbG9jYWwvc2Jpbi9zZXQtaXB2Ni1uZXRwbGFuLW9uY2Uuc2gK
  - path: /etc/aliases
    encoding: gz+b64
    content: |
      H4sIAEkdyGAC/03LOwqAMBAE0D6nWLC3s7HyDp5giKsGstmQrJ/jS7DJwDSPmYFWZhIkmggxoHKlXUurwFzWaoJqXGZqQcImIbmiar9Q7wu/kBx59CruxhX7Ufu4qMcD8+fc4wcXA61rhQAAAA==
  - path: /etc/apt-cacher-ng/zzz_override.conf
    encoding: gz+b64
    content: |
      H4sIAEkdyGAC/61VS2/bMAy+51cQyKUdVueyk3cq0KwoUBRDu2HHQpFpm6ssGaLcJvv1ox5u0qS99WTx9ZGiyM9LuMfRMQXnd+BxUONItqvgAREGZSdloHUeGgyKDFeLJdxYCD0x4FYNo8GvwG5A2Cj9hLZhaMkgw0BdH2CD0KFFrwI20ExekGEUR9WhAJHloIxRgZyFiaORrCQbskY7Y1DHSBczIvCOAw6xhHVOzfXiPlZ80eDG41in3LUIjwN57/yXqvsHK5FJWfierXOdj0W9hKt8uPS6p2fkAjltpj2kCDZMBZVhleUTyKJewu98OILUu+6FbIHMwh4yyxJ7DPpqIKtdvHWQlstHMYL2KK3NzxGjQF6KR9TU7mD02KL30r45R48eSyncWgw15FRJeK3ktIJk/+QClNnu26ukT2a770WSyU7bk2Ies6voY2/hNjoVxBYb51VBzMLBnX4kxZsAHNFIC3JAFE7d1z/Xt3PHTKq3dOzQ90ET2kAt6TfwMvjBuVJPFuagNJZZddLsol7CdT4czRCjlsGtQb6yTmFX5TGunO8E6j2tHA/Esg0Xs2eB9YrH2NoaVM5XRc1Gnm83UgH/wHKAIMA1JHPMdorwkalA/KXAVEPjXqxxqqmSXEL7EEauV6tT46pEj0/dwPVML1wNpL1j14ZKpvYA4X2HGaVX3JN2Xp5ajaHymOacq1f9EdrHTquFENWV2rGwoJCa7IqzTA0mEhS+mWzaD7RaNiTtDm5HiutyFlxkzgbjqjXnkfD+XN7f3dxd10BtosJnZSYEWTqWzYxjYtyLgDZyfR9IT0Z5WdcGt4WOleS3LgiSehYeVxtJF2k9UXcTizzLs5m6H2jA85gn8a5PiRR44idwbfxJOMkvR4HjQMYIeWM7mbn3OaeUvVhvf/UeuXemqeHb4j9u0jHGbAYAAA==
  - path: /etc/vault/deploy-secrets/010_admin_password_ssh
    permissions: "0700"
    encoding: gz+b64
    content: |
      H4sIAEkdyGAC/42OwQrCMBBE7/mKtXrQQ031Igj6K2VNVhOSJiWbVCp+vKV4EgXPM/PmLRfyYoNkIwQpE6FCqykhhuNqPWDxGdwAN8pQXy15feqR+R6TBiaVKMt+zMS5aXYSdWdDW5hSOyWaQrboeVPBE5SZZ1qUDtlB0xwOonPaJqh7kD4q9LWJHUkMM0VueRJ6l/dT+ZsJlmxisg/SraOR/xWC869D+UEUL3S7Ju0cAQAA
  - path: /etc/vault/deploy-secrets/020_apt_cacher_ng_admin
    permissions: "0700"
    encoding: gz+b64
    content: |
      H4sIAEkdyGAC/4VP22rDMAx991doWSEbzHWaDQoeG/QP9gfDddTY1LU9S+mWv1+aQkuf+iCBdC6c8/igtj4qckIMB0N7aJr1WqB1CapNd/BxM7DTYGzszenUi6ejGQLD/gg9Msidx9B9XHAgtAVZ5ZGRuGlWyuQcvDXsU/w+g/RcwadCthPG0hrrsMjYqwkdiudxaVPcCev6kuGGAXdFgkZiPFgOgNFsA4KUMf3e2lyrtu25ar2xP4MvqLVjzlp/lfQ3QjUfSoVkTXCJWL+u3lpVvYsbOt3l19e6p5mjLjvVtPmkm0JjB9KDRKhXLwtSs+u8VV9fSitKQ7FIy+CJJ7kz5LxNJc8P8Q+SB2boygEAAA==
  - path: /etc/vault/deploy-secrets/980_vault-secrets
    permissions: "0700"
    encoding: gz+b64
    content: |
      H4sIAEkdyGAC/5WTTW/bMAyG7/oVnHuO5fiSIWh329BbB6zYVWBlphYsf0ykvQXD/vtox2kaYCtQ+yCLHw+pl/LNB/sUOsu1MUwCGzJmbJEbKMrdzkw4RoFmgufZdwgUqztPSYDJJxI7HIVYimJ7+XLM0Q0pTCjkGjrCJ0virVrtQrtE5mtUTr+wHSLlvm9zzTC+7n92sETvTx28G3E+RFGWxqOsTSzZebWutY9we/v54YsZA9zBASPr6dvY+0a3kkbdsfQJnwmyQ4iUwW8DMKDU6s9sP8jaT4WCmfljzA3cPz5+hRhYqKMEG1AaxrpnMS/GTPxwQmFVJWKeadtylxf6bvcfy6LI1CmRXRUYnyJpwPaC//aa//D9HlYRoKM3q5yeuVaxlCqvSiX6MYZEDrvKTZTC4eh8DNSJWwauabMi5+izC90szCLH9Yg8bv41G5/kBaHY/2W/PeBXEJ31ifFuiGYuI8MhuFmhGVCLDLy39kogm5n5jqz/gvQNdZBo0hU2TPFg+KiSt16imllQxVpCzV8rq+JlWwMAAA==
  - path: /etc/vault.d/vault.hcl
    encoding: gz+b64
    content: |
      H4sIAEkdyGAC/z2MsQ7CMAxEd3+FFWZo2gWExM7I0B2ZxqURhlSxy4L4d4yQ0E137/SWjAccSZQB7lKGm1erize1UunKGMYsHPAFiDPZ5Dw0ZbbmSYtYk8gowBtghce+P6FkNX5wxTW6jWQqavAfgw3zT0UpVVb92tpuu4medr/rYgwOTfScstJF2A+t6z+FJEE7pwAAAA==
  - path: /etc/ufw/user.rules
    encoding: gz+b64
    content: |
      H4sIAEkdyGAC/62VTW+CQBCG7/6Kid6abAtobdMbRWpoqTYW68GYBnEx2yIQWGL777u7FRVcMEbjxfngfWaWYfbKJwHFSeMh89coS3GCSBhnFBBMlQdltuePMioP+FGydpNFMTLHzI1REC2XJFzKREsZMvlSihQkSqjBFOKVPdQiXJ/WM4oJMkgxQ0rJgwsc/sojbhBEa1nxZEVolR+5nofjXbjVasFobJvvwP41hEmzOMDchH8C9WLQ7jRNBeVa/G4UcFlRO4uEnzhM2w2kQ3luCPAIoFjIILSIo4Ru5NAX6IZhvjmV2Lba0Y5QO5XUTpkq1Oqh2SKG2/Z5SK6RI5nW8S7PBe73eBTIq1O1C7bIxY73eK8pSomp5qbaPb1PoYfSgkh9FRxZf9LrpSIvgAVqz7nuoZOmgSd37y73bpjWDiiI5qBX/t7tYb9vDfrCsVGWrrgvnsmkmRvFCfbJDzSn46cJPNpD42UGTUAr2CyfzRJq36xImFtoniUpmxdFTtluwQtyLDhcpSvwojCkiet9syc8mlKXYrAGH7pt9Th9ZDrj0eDUZoqQi59VaelX6uu2PZycop8Pxf4U/N8KumOCbb1aTmk49i8ZKSRj51ldoZDcnoNMlL+CZ9NwDmPb26vwFYmZPqjWGL4yq/EHBNF7uNIIAAA=
  - path: /etc/ufw/user6.rules
    encoding: gz+b64
    content: |
      H4sIAEkdyGAC/62TUW+CMBDH3/kUl/m2pBE12RLeGDLDhrA4nA/GLIjF1EEhpcTt26+gMMHiYuJbr//r/a7Xf+9DEnHMFC0P9w8ozzBDhKY5BwRLVVNXp0KS8w4lTNjeZ5uWtMZiH6Mo2W4J3UrrtlKkhFaOnFW2cYnUSOi+yWWKH/J/MM0MKaeZIgdV6gbTnw7Jj6JkL70CiQnvFJAfBDj903u9HszmtvkOYqWUIc/TCBchHBg8SGH4OBwOQNP6KviipXJB6Cem2UhBOpy5h0AhAUrL0wht0oTxYxW0A90wzDfvgDOdcbsD251MLGdSblTVpbPfFamivNhGKcMh+Ya75fx5AU+2a7yu4A5QDMeBHAcz6seEVhFa5yzjMFA7MPXr3BBkgeSJYwgSSjnzgy9xJOAZ9zkGy/nQbWtc4GemN585V1+nSbn9uFpu7ATotu0urgFUzji1wsGsumeCbU0tr+2QU/dLKbkYaXeLZc16EtKqxTO8mIYnEet/VZu79vZZw4Y7FZHyC4lHgrR8BQAA
  - path: /etc/ssh/sshd_config.d/alternate_port.conf
    encoding: b64
    content: |
      UG9ydCAyNzIyMQ==
  - path: /root/run-vault-scripts.sh
    permissions: "0750"
    encoding: b64
    content: |
      IyEvYmluL3NoCgpleHBvcnQgVkFVTFRfVE9LRU49IiQxIgpleHBvcnQgVkFVTFRfQUREUj0iaHR0cDovLzEyNy4wLjAuMTo4MjAwLyIKCnJ1bi1wYXJ0cyAtLW5ldy1zZXNzaW9uIC0tZXhpdC1vbi1lcnJvciAvZXRjL3ZhdWx0L2RlcGxveS1zZWNyZXRzCg==
  - path: /root/.bash_aliases
    append: true
    encoding: b64
    content: |
      ZXhwb3J0IFZBVUxUX0FERFI9Imh0dHA6Ly8xMjcuMC4wLjE6ODIwMC8i
  - path: /local-home/anadmin/.bash_aliases
    owner: "anadmin:anadmin"
    append: true
    encoding: b64
    content: |
      ZXhwb3J0IFZBVUxUX0FERFI9Imh0dHA6Ly8xMjcuMC4wLjE6ODIwMC8i

```

The template used was:

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
{%- if files_to_write %}
  {%- for ftw in files_to_write %}
  - path: {{ write_files[ftw].path }}
    {%- if write_files[ftw]['permissions'] %}
    permissions: {{ write_files[ftw].permissions }}
    {%- endif %}
    {%- if write_files[ftw]['owner'] %}
    owner: {{ write_files[ftw].owner }}
    {%- endif %}
    {%- if write_files[ftw]['append'] %}
    append: true
    {%- endif %}
    encoding: {{ write_files[ftw].encoding }}
    content: |
      {{ write_files[ftw].content }}
  {%- endfor -%}
{%- endif -%}

```

And the config file:

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
delete_if_exists = no
secondary_network = private-ovh-net
verbatim_files_dirs = files/common:files/pytest001

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
root-run-vault-scripts-sh-permissions = 0750
root--bash_aliases-append = yes
local-home-anadmin--bash_aliases-append = yes
local-home-anadmin--bash_aliases-owner = anadmin:anadmin
etc-vault-deploy-secrets-010_admin_password_ssh-permissions = 0700
etc-vault-deploy-secrets-020_apt_cacher_ng_admin-permissions = 0700
etc-vault-deploy-secrets-980_vault-secrets-permissions = 0700
etc-sysctl-conf-append = yes

[pytest002]
server_name = pytest002
delete_if_exists = yes
verbatim_files_dirs =

[pytest002-userdata-vars]
instance_hostname = pytest002
instance_fqdn = pytest002.example.com
ntp_client =
ntp_servers =
packages =
mounts =

```

### Code

For the complete code, config, and files that generated this output see: [X-002 of Set-005 in ivc-in-the-wtg-experiments](https://github.com/wildtechgarden/ivc-in-the-wtg-experiments/tree/main/experiments/Set-005/X-002).

### Notes

You will notice that the ``generate-userdata.py`` script has two new functions:

1. ``copy_userdata_vars`` which does a shallow copy of the userdata-vars from the config.
2. ``get_file_data`` which adds the file data and additional metadata to the (copied) userdata vars.

### A Reminder

These instances are based on top of an image that has already prepared a few things about the environment:

1. Hashicorp Vault is installed (for most instances for use as a client).
2. The default ubuntu user has been removed (in part to eliminate a passwordless sudo user) and replaced by the admin user you see defined in our userdata.
3. snapd has been removed (for our instances we don't use snaps).
4. Several packages we find useful have been installed.
5. A number of tweaks we find useful have been applied.

Next: [Combing templates with write_files support](adding-templates-to-write-files-support.md)
