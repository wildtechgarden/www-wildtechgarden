---
slug: adding-templates-to-write-files-support
aliases:
    - /projects/experimental-learning/infrastructure-via-code/continuing-openstacksdk-with-templating/adding-templates-to-write-files-support/
    - /develop-design/infrastructure-via-code/continuing-openstacksdk-with-templating/adding-templates-to-write-files-support/
    - /docs/devel/infrastructure-via-code/continuing-openstacksdk-with-templating/adding-templates-to-write-files-support/
    - /devel/continuing-openstacksdk-with-templating/adding-templates-to-write-files-support/
title: "Combining templates with write_files support"
date: 2021-06-13T19:29:29-04:00
publishDate: 2021-06-15T19:17:10-04:00
author: Daniel F. Dickinson
series:
    - infrastructure-via-code-openstack
tags:
    - archived
    - deploy
    - python
description: "Adding basic support for templates to an OpenSDK-based instance deployment"
summary: "Adding basic support for templates to an OpenSDK-based instance deployment"
weight: 10650
---

{{< details-toc >}}

## Preface

It should be noted that these additions, combined with testing on a Windows workstation revealed a few errors in the previous version of script. These have been corrected as part of the enhancement process, in part because some new functionality requires the fixes.

### Notes and What's New

* We use the same ``userdata-default.yaml.jinja`` — it did not require updates
* Like ``verbatim_files_dirs``, we add ``template_files_dirs`` as a config key which holds a colon-separated list of directories to walk.
  * Each file in the directory tree is assumed to be a template for a file which belongs in the corresponding location on the target (e.g. if ``templates/pytest001`` is a directory given in ``template_files_dirs`` then ``templates/pytest001/etc/systemd/system/set-ip6-netplan-once.timer`` is rendered as a Jinja template, using the same ``-userdata-vars`` as the main ``userdata-default.yaml.jinja`` and the result is a treated as a file to be located at ``/etc/systemd/system/set-ip6-netplan-once.timer`` in the instance to be created).
  * As with verbatim files, compression is attempted and the result is base64 encoded.
* As mentioned the variables in the file templates are filled with values from the same ``-userdata-vars`` section as the main userdata template.
* userdata_vars dictionary is now created from a deep copy of the ``-userdata-vars`` section in the config file, instead of only a shallow copy. This was necessary so that earlier instances' data do not added to later instances' data.
* Fixes have been added for use of the script on Windows (improved cross-platform behaviour).

### Sample Generated Userdata

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
  - path: /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
    encoding: b64
    content: |
      bmV0d29yazoge2NvbmZpZzogZGlzYWJsZWR9
  - path: /etc/aliases
    encoding: gz+b64
    content: |
      H4sIALYtyWAC/03LOwqAMBAE0D6nWLC3s7HyDp5giKsGstmQrJ/jS7DJwDSPmYFWZhIkmggxoHKlXUurwFzWaoJqXGZqQcImIbmiar9Q7wu/kBx59CruxhX7Ufu4qMcD8+fc4wcXA61rhQAAAA==
  - path: /etc/sysctl.conf
    encoding: b64
    content: |
      bmV0LmlwdjQuaXBfZm9yd2FyZD0xCg==
  - path: /etc/apt-cacher-ng/zzz_override.conf
    encoding: gz+b64
    content: |
      H4sIALYtyWAC/61VS2/bMAy+51cQyKUdVueyk3cq0KwoUBRDu2HHQpFpm6ssGaLcJvv1ox5u0qS99WTx9ZGiyM9LuMfRMQXnd+BxUONItqvgAREGZSdloHUeGgyKDFeLJdxYCD0x4FYNo8GvwG5A2Cj9hLZhaMkgw0BdH2CD0KFFrwI20ExekGEUR9WhAJHloIxRgZyFiaORrCQbskY7Y1DHSBczIvCOAw6xhHVOzfXiPlZ80eDG41in3LUIjwN57/yXqvsHK5FJWfierXOdj0W9hKt8uPS6p2fkAjltpj2kCDZMBZVhleUTyKJewu98OILUu+6FbIHMwh4yyxJ7DPpqIKtdvHWQlstHMYL2KK3NzxGjQF6KR9TU7mD02KL30r45R48eSyncWgw15FRJeK3ktIJk/+QClNnu26ukT2a770WSyU7bk2Ies6voY2/hNjoVxBYb51VBzMLBnX4kxZsAHNFIC3JAFE7d1z/Xt3PHTKq3dOzQ90ET2kAt6TfwMvjBuVJPFuagNJZZddLsol7CdT4czRCjlsGtQb6yTmFX5TGunO8E6j2tHA/Esg0Xs2eB9YrH2NoaVM5XRc1Gnm83UgH/wHKAIMA1JHPMdorwkalA/KXAVEPjXqxxqqmSXEL7EEauV6tT46pEj0/dwPVML1wNpL1j14ZKpvYA4X2HGaVX3JN2Xp5ajaHymOacq1f9EdrHTquFENWV2rGwoJCa7IqzTA0mEhS+mWzaD7RaNiTtDm5HiutyFlxkzgbjqjXnkfD+XN7f3dxd10BtosJnZSYEWTqWzYxjYtyLgDZyfR9IT0Z5WdcGt4WOleS3LgiSehYeVxtJF2k9UXcTizzLs5m6H2jA85gn8a5PiRR44idwbfxJOMkvR4HjQMYIeWM7mbn3OaeUvVhvf/UeuXemqeHb4j9u0jHGbAYAAA==
  - path: /etc/ssh/sshd_config.d/alternate_port.conf
    encoding: b64
    content: |
      UG9ydCAyNzIyMQ==
  - path: /etc/systemd/system/set-ipv6-netplan-once.service
    encoding: b64
    content: |
      W1VuaXRdCkRlc2NyaXB0aW9uPVNldCBOZXRwbGFuIGZvciBJUHY2IE9uY2UKCltTZXJ2aWNlXQpUeXBlPW9uZXNob3QKRXhlY1N0YXJ0PS91c3IvbG9jYWwvc2Jpbi9zZXQtaXB2Ni1uZXRwbGFuLW9uY2Uuc2g=
  - path: /etc/ufw/user.rules
    encoding: gz+b64
    content: |
      H4sIALYtyWAC/62VTW+CQBCG7/6Kid6abAtobdMbRWpoqTYW68GYBnEx2yIQWGL777u7FRVcMEbjxfngfWaWYfbKJwHFSeMh89coS3GCSBhnFBBMlQdltuePMioP+FGydpNFMTLHzI1REC2XJFzKREsZMvlSihQkSqjBFOKVPdQiXJ/WM4oJMkgxQ0rJgwsc/sojbhBEa1nxZEVolR+5nofjXbjVasFobJvvwP41hEmzOMDchH8C9WLQ7jRNBeVa/G4UcFlRO4uEnzhM2w2kQ3luCPAIoFjIILSIo4Ru5NAX6IZhvjmV2Lba0Y5QO5XUTpkq1Oqh2SKG2/Z5SK6RI5nW8S7PBe73eBTIq1O1C7bIxY73eK8pSomp5qbaPb1PoYfSgkh9FRxZf9LrpSIvgAVqz7nuoZOmgSd37y73bpjWDiiI5qBX/t7tYb9vDfrCsVGWrrgvnsmkmRvFCfbJDzSn46cJPNpD42UGTUAr2CyfzRJq36xImFtoniUpmxdFTtluwQtyLDhcpSvwojCkiet9syc8mlKXYrAGH7pt9Th9ZDrj0eDUZoqQi59VaelX6uu2PZycop8Pxf4U/N8KumOCbb1aTmk49i8ZKSRj51ldoZDcnoNMlL+CZ9NwDmPb26vwFYmZPqjWGL4yq/EHBNF7uNIIAAA=
  - path: /etc/ufw/user6.rules
    encoding: gz+b64
    content: |
      H4sIALYtyWAC/62TUW+CMBDH3/kUl/m2pBE12RLeGDLDhrA4nA/GLIjF1EEhpcTt26+gMMHiYuJbr//r/a7Xf+9DEnHMFC0P9w8ozzBDhKY5BwRLVVNXp0KS8w4lTNjeZ5uWtMZiH6Mo2W4J3UrrtlKkhFaOnFW2cYnUSOi+yWWKH/J/MM0MKaeZIgdV6gbTnw7Jj6JkL70CiQnvFJAfBDj903u9HszmtvkOYqWUIc/TCBchHBg8SGH4OBwOQNP6KviipXJB6Cem2UhBOpy5h0AhAUrL0wht0oTxYxW0A90wzDfvgDOdcbsD251MLGdSblTVpbPfFamivNhGKcMh+Ya75fx5AU+2a7yu4A5QDMeBHAcz6seEVhFa5yzjMFA7MPXr3BBkgeSJYwgSSjnzgy9xJOAZ9zkGy/nQbWtc4GemN585V1+nSbn9uFpu7ATotu0urgFUzji1wsGsumeCbU0tr+2QU/dLKbkYaXeLZc16EtKqxTO8mIYnEet/VZu79vZZw4Y7FZHyC4lHgrR8BQAA
  - path: /etc/vault/deploy-secrets/010_admin_password_ssh
    encoding: gz+b64
    content: |
      H4sIALYtyWAC/42OwQrCMBBE7/mKtXrQQ031Igj6K2VNVhOSJiWbVCp+vKV4EgXPM/PmLRfyYoNkIwQpE6FCqykhhuNqPWDxGdwAN8pQXy15feqR+R6TBiaVKMt+zMS5aXYSdWdDW5hSOyWaQrboeVPBE5SZZ1qUDtlB0xwOonPaJqh7kD4q9LWJHUkMM0VueRJ6l/dT+ZsJlmxisg/SraOR/xWC869D+UEUL3S7Ju0cAQAA
  - path: /etc/vault/deploy-secrets/020_apt_cacher_ng_admin
    encoding: gz+b64
    content: |
      H4sIALYtyWAC/4VP22rDMAx991doWSEbzHWaDQoeG/QP9gfDddTY1LU9S+mWv1+aQkuf+iCBdC6c8/igtj4qckIMB0N7aJr1WqB1CapNd/BxM7DTYGzszenUi6ejGQLD/gg9Msidx9B9XHAgtAVZ5ZGRuGlWyuQcvDXsU/w+g/RcwadCthPG0hrrsMjYqwkdiudxaVPcCev6kuGGAXdFgkZiPFgOgNFsA4KUMf3e2lyrtu25ar2xP4MvqLVjzlp/lfQ3QjUfSoVkTXCJWL+u3lpVvYsbOt3l19e6p5mjLjvVtPmkm0JjB9KDRKhXLwtSs+u8VV9fSitKQ7FIy+CJJ7kz5LxNJc8P8Q+SB2boygEAAA==
  - path: /etc/vault/deploy-secrets/980_vault-secrets
    encoding: gz+b64
    content: |
      H4sIALYtyWAC/5WTTW/bMAyG7/oVnHuO5fiSIWh329BbB6zYVWBlphYsf0ykvQXD/vtox2kaYCtQ+yCLHw+pl/LNB/sUOsu1MUwCGzJmbJEbKMrdzkw4RoFmgufZdwgUqztPSYDJJxI7HIVYimJ7+XLM0Q0pTCjkGjrCJ0virVrtQrtE5mtUTr+wHSLlvm9zzTC+7n92sETvTx28G3E+RFGWxqOsTSzZebWutY9we/v54YsZA9zBASPr6dvY+0a3kkbdsfQJnwmyQ4iUwW8DMKDU6s9sP8jaT4WCmfljzA3cPz5+hRhYqKMEG1AaxrpnMS/GTPxwQmFVJWKeadtylxf6bvcfy6LI1CmRXRUYnyJpwPaC//aa//D9HlYRoKM3q5yeuVaxlCqvSiX6MYZEDrvKTZTC4eh8DNSJWwauabMi5+izC90szCLH9Yg8bv41G5/kBaHY/2W/PeBXEJ31ifFuiGYuI8MhuFmhGVCLDLy39kogm5n5jqz/gvQNdZBo0hU2TPFg+KiSt16imllQxVpCzV8rq+JlWwMAAA==
  - path: /etc/vault.d/vault.hcl
    encoding: gz+b64
    content: |
      H4sIALYtyWAC/z2MsQ7CMAxEd3+FFWZo2gWExM7I0B2ZxqURhlSxy4L4d4yQ0E137/SWjAccSZQB7lKGm1erize1UunKGMYsHPAFiDPZ5Dw0ZbbmSYtYk8gowBtghce+P6FkNX5wxTW6jWQqavAfgw3zT0UpVVb92tpuu4medr/rYgwOTfScstJF2A+t6z+FJEE7pwAAAA==
  - path: /local-home/anadmin/.bash_aliases
    encoding: b64
    content: |
      ZXhwb3J0IFZBVUxUX0FERFI9Imh0dHA6Ly8xMjcuMC4wLjE6ODIwMC8i
  - path: /root/.bash_aliases
    encoding: b64
    content: |
      ZXhwb3J0IFZBVUxUX0FERFI9Imh0dHA6Ly8xMjcuMC4wLjE6ODIwMC8i
  - path: /root/run-vault-scripts.sh
    encoding: b64
    content: |
      IyEvYmluL3NoCgpleHBvcnQgVkFVTFRfVE9LRU49IiQxIgpleHBvcnQgVkFVTFRfQUREUj0iaHR0cDovLzEyNy4wLjAuMTo4MjAwLyIKCnJ1bi1wYXJ0cyAtLW5ldy1zZXNzaW9uIC0tZXhpdC1vbi1lcnJvciAvZXRjL3ZhdWx0L2RlcGxveS1zZWNyZXRzCg==
  - path: /etc/netplan/52-cloud-init.yaml
    encoding: gz+b64
    content: |
      H4sIALYtyWAC/22O4Q6CMAyE//sUfQFmGMQob9OwMyyysbQL8viygBKN//r1rr2LyM9JHt2JaIaon2JHdgXkARKRtSgrRm23icgNfWo7uvOo2FfsnEAV+vYQVVTfrKkvV9NYY8+23ZXIAQopYYdZwdIPB5fzJH7mDIOFQxph+il86c32vaT4WJUGhiXxx/On02+rF3FbR5/9AAAA
  - path: /etc/systemd/system/set-ipv6-netplan-once.service
    encoding: b64
    content: |
      W1VuaXRdCkRlc2NyaXB0aW9uPVNldCBOZXRwbGFuIGZvciBJUHY2IE9uY2UKCltTZXJ2aWNlXQpUeXBlPW9uZXNob3QKRXhlY1N0YXJ0PS91c3IvbG9jYWwvc2Jpbi9zZXQtaXB2Ni1uZXRwbGFuLW9uY2Uuc2g=
  - path: /etc/systemd/system/set-ipv6-netplan-once.timer
    encoding: b64
    content: |
      W1VuaXRdCkRlc2NyaXB0aW9uPUxvb2sgZm9yIElQdjYgZXZlcnkgNjBzIGFmdGVyIGd1YXJhbnRlZWQgZXhwaXJ5IChUVEwpCgpbVGltZXJdCk9uQm9vdFNlYz0xMjAKT25Vbml0QWN0aXZlU2VjPTYwCgpbSW5zdGFsbF0KV2FudGVkQnk9dGltZXJzLnRhcmdldA==
  - path: /usr/local/bin/set-ipv6-netplan-once.sh
    encoding: gz+b64
    content: |
      H4sIALYtyWAC/11SXW/aMBR99684C5FKJ7kJgaHJtNNettf9gKqq3PhCLIIdbAfEGv77nBQKLC+O773nwz4efcnetMl8xZhu5q9SKfeUJEwZ/+rJ7Sju0rEjb+sdlaFGbICMn3ZlG8CXBbgSXXBxwR3u7hPG9pWuCc/gf5GkZ84ELwsoy4CLSjqurI8kATJ+SN+3LbnD0DwivTjogtQ1uJlE9ohfgsrK3nB3WDlqwLdIjA1Y2taoZIFQkYmIa82egWpP/5XT9P28GY2+4tiPLTVT1hBjpQz4kVEoM0OhqaXJvk14WdtWcW104LrZzR8OclPj8fHXn98sTu2tW4vIEd17bY1A0etGPy42vcAg31+jGP4AVZXNXGApz96A3gx5T/48A3BcGT1mk+L7qeVsG24HgxUQIss/S9GMllFBTUgU0yIX01k+E7M8F2Iyy+lqzhpea7MWCK4l1p+I+YMPtBny116+xXw5N3YPTx/H56eb4daU9BD0htwVxgfbYL/i21aX65/7VY6u+yD3NcXcCnaCQzZNffisxqifY87jC5P2nEyvr2747hM8ITl1hqfWR49rB9KFG8hieAaDi0WM+h/u+p9NBwMAAA==

```

### Code

For the complete code, config, and files that generated this output see: [X-003 of Set-005 in ivc-in-the-wtg-experiments](https://github.com/danielfdickinson/ivc-in-the-wtg-experiments/tree/main/experiments/Set-005/X-003).
