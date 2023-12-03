---
slug: linux-network-monitoring
aliases:
    - /2006/04/02/linux-network-monitoring/
    - /post/linux-network-monitoring/
    - /deploy-admin/linux-network-monitoring/
    - /linux-network-monitoring/
    - /docs/sysadmin-devops/self-host/linux-network-monitoring/
    - /sysadmin-devops/self-host/linux-network-monitoring/
    - /docs/deploy-admin/sysadmin-devops/linux-network-monitoring/
author: Daniel F. Dickinson
date: 2021-03-08T09:21:22+00:00
publishDate: 2006-04-03T02:25:00+00:00
summary: Linux network monitoring presentation using munin and nagios circa 2006
description: Linux network monitoring presentation using munin and nagios circa 2006
tags:
- archived
- linux
- self-host
- sysadmin-devops
title: "Linux network monitoring"
card: true
frontCard: true
---

{{< details-toc >}}

## ARCHIVED

This document is archived and may be out of date or inaccurate.

## Network monitoring

* Statistics gathering and presentation
* Usually continuous recording of system stats, but periodic update of presentation
* Real-time Status e.g. service availability or current CPU load
* Alerts on Critical Conditions e.g. Email and pager when disk almost full
* Log Analysis
* Usually after the fact (periodic reports), but real-time analyzers do exist

### Slide deck and source code archives

* [HTML presentation version separated into slides (tar.bz2)](/assets/files/linux-network-system-monitoring.tar.bz2)
* [Presentation Source Code (tar.bz2)](/assets/files/linux-network-system-monitoring.xml.tar.bz2)

### Real-time status: applets

![WindowMaker dockapps showing some system statistics](/assets/images/dockapps-1.png)

As you can see, it is possible to monitor a select number of machines
using dockapps. Basically you run the dockapp or gnome/kde applet on the
machine you want to monitor, but display it on the 'X' display of the
server.

By using ssh, you can initiate the applet/dockapp from the server. I use
a command line such as the following.

``ssh -aCXY remotehost "asmon"``

It is important to note that, at least for debian, one needs the package
xbase-clients installed on the machine running the applet in order to
run X applets

### A few log tools

* logwatch: Watches for regexps and creates a daily summary of the
syslog for those regexps
* logcheck: Reports everything except what is specifically excluded
(though the exclude lists are fairly comprehensive), on an hourly
basis (depending on the amount of logged information).
* ccze: Fairly comprehensive log colourizer
* lwatch: Small log colourizer

## Munin

### What is Munin

* Client which records statistics on
  * CPU usage & load
    * memory
    * network traffic
    * disk usage
    * I/O throughput
    * and more…
* Server which periodically retrieves statistics over network (or localhost) and graphs them

### Munin interface

* Configuration is performed by editing text files in /etc/munin
* Statistic graphs are presented as static HTML pages which are automatically regenerated periodically (by default, every five minutes)
* To see what munin’s graphs look like, you may wish to view ~~a snapshot of munin on my network~~ [_AUTHOR'S NOTE: No longer available_]

### Installing Munin: client

* On a Debian system, execute the command: apt-get install munin-node
* On a RedHat Enterprise Linux system: Get munin-node-1.2.4-5rhel3.noarch.rpm, e.g. from the [Munin Sourceforge Project](https://sourceforge.net/projects/munin/files/) and execute the command:
 ``rpm -ivH munin-node-1.2.4-5rhel3.noarch.rpm``

### Configuring Munin: client

1. Edit the file /etc/munin/munin-node.conf
2. Add an ‘allow’ line with the ip of the server. It must be a perl regular expression because the Net::Server perl module which munin depends on doesn’t understand CIDR-style network notation. You must include an allow line for every munin server allowed to connect to this client. ``allow ^192\.168\.8\.204$``
3. Start the munin-node service (on debian, /etc/init.d/munin-node start)
4. You may wish to view ~~an example munin-node.conf~~ [_AUTHOR'S NOTE: No longer available_].

### Installing Munin: server

* On a Debian system, execute the command: apt-get install munin
* On a RedHat Enterprise Linux system: Get munin-1.2.4-5rhel3.noarch.rpm, e.g. from the [Munin Sourceforge Project](https://sourceforge.net/projects/munin/files/) and execute the command: ``rpm -ivH munin-1.2.4-5rhel3.noarch.rpm``

### Configuring Munin: server

1. Edit the file /etc/munin/munin.conf, adding records for each client -  Records are of the form:

   ```ini
   [descriptive_name]
   address clientname.your.domain
   use_node_name yes
   ```

* ‘descriptive_name’ is the name which will appear on the pages for the client
* ‘clientname.your.domain’ is the IP or domain name of the client
* ‘use_name_name yes’ tells the server to use all the available plugins (each type of statistic has a plugin) for the client

The client listing part of my munin.conf is shown below

```ini
[revor.fionavar.dd]
  address revor.fionavar.dd
  use_node_name yes
[mornir.fionavar.dd]
  address mornir.fionavar.dd
  use_node_name yes
[darien.fionavar.dd]
  address darien.fionavar.dd
  use_node_name yes
```

You may also be interested in ~~a full munin.conf example~~ [_AUTHOR'S NOTE: No longer available_]

## Nagios

### What is Nagios

* Host monitoring
  * Host status: up/down, cpu, load, swap, processes, disk usage, and other plugins…
* Network monitoring: nfs, ldap, ntp, httpd, dns, smtp, and more…
* Other Monitoring: Plugins may easily be written for host, network and other monitoring
* Alerts (email, pager, sms text messages, IM, audio)

You may wish to view ~~a snapshot of Nagios on my network~~ [_AUTHOR'S NOTE: No longer available_]

### Nagios interface: overviews

Enter through ~~Nagios’ Main Screen~~ [_AUTHOR'S NOTE: No longer available_]

* The ~~Tactical Overview~~ [_AUTHOR'S NOTE: No longer available_] attempts to summarize the state of nagios in one screen. It is less useful than the status summary and overview screens when it comes to seeing the state of hosts
* A ~~Status Overview~~ [_AUTHOR'S NOTE: No longer available_] displays the host status (up,down,unknown) as well as a summary of the status of services on the hosts. Quite useful when you have many hosts.
* Like the Status Overview ~~Status Summary~~ [_AUTHOR'S NOTE: No longer available_] is a status summary, but instead of individual hosts it summarizes hostgroups. This is useful if you have so many hosts that the Status Overview results in information overload.

### Nagios: Host & service status

* With a small number of hosts, the most useful screen is the ~~Service Details~~ [_AUTHOR'S NOTE: No longer available_] which lists the status of everything that is monitored by Nagios.
* The ~~Status Grid~~ [_AUTHOR'S NOTE: No longer available_] provides a less detailed summary, and is suited to a moderate number of hosts.
* The monitored hosts up/down/unknown status is summarized in the ~~Host Detail~~ [_AUTHOR'S NOTE: No longer available_] page.
* ~~Service Problems~~ [_AUTHOR'S NOTE: No longer available_] provides a list of services that are warning or critical.
* The ~~Host Problems~~ page lists all hosts that are down.
* There is also a Network Outages page.

### Nagios: reports & graphs

* Trends
* Availability: Indicates how often a host/service is up (available)
* Alert Histogram: How frequently alerts occurred
* Alert History: A log of alerts
* Alert Summary
* Notifications: A log of notifications
* Event Log

### Installing Nagios: overview

This portion of the presentation will assume debian package names and configuration

* On the server (collector):
  * Need a web server
  * Need nagios, nagios-plugins, a database backend (e.g.
 nagios-text), and, if using nagios-nrpe, nagios-nrpe-plugin
* For host monitoring the clients to be monitored need one or more of
nagios-nrpe-server, nagios-plugins, and nagios-statd-server

In the following configuration files, the following definitions apply:

* for services: w = warn, u = unreachable, c = critical, r = recovery
* for hosts: d = down, u = unknown, r = recovery
* Also note that for most plugins executing the plugin with the -h option will list the arguments the plugin accepts.

### Nagios config

#### Overview

* Define commands (using plugins)
* Define contacts for alerts and other notifications
* Define time periods (to alert different people at different times of day/week or to not monitor workstations at night because they're turned off, for example)
* Define hosts to monitor
* Define services and optional dependencies (don't report service 2 down if service 1 is down)

#### Templates

* Reduce the number of directives in configuration files* Basically a regular object definition, except that
* It has a name directive in the object definition
* It has a ‘register 0’ directive_Can include other templates_ To use it, one adds a ‘use template\_name’ to a regular object or another template (usually before the object-specific parameters as they can override the template)

##### Example of templates

```plain
define host{
  use generic-host ; Name of host template to use
  name fionavar-defaults
  check_command check-host-alive
  max_check_attempts 20
  notification_interval 60
  notification_period 24x7
  notification_options d,u,r
  register 0 ; TEMPLATE, NOT REAL HOST
}

define host {
  use fionavar-defaults
  host_name mornir
  alias Mornir
  address 192.168.8.2
}
```

#### Main

##### nagios.cfg

The primary configuration file is /etc/nagios/nagios.cfg

Debian uses include directives in this file to logically divide up the various configuration sections

```plain
cfg_file=/etc/nagios/checkcommands.cfg
cfg_dir=/etc/nagios-plugins/config/
cfg_file=/etc/nagios/misccommands.cfg
cfg_file=/etc/nagios/contactgroups.cfg
cfg_file=/etc/nagios/contacts.cfg
cfg_file=/etc/nagios/dependencies.cfg
cfg_file=/etc/nagios/escalations.cfg
cfg_file=/etc/nagios/hostgroups.cfg
cfg_file=/etc/nagios/hosts.cfg
cfg_file=/etc/nagios/services.cfg
cfg_file=/etc/nagios/timeperiods.cfg
```

##### Contacts

You will need to edit /etc/nagios/contacts.cfg

```plain
# 'efs' contact definition
define contact{
  contact_name efs
  alias Nagios Admin
  service_notification_period 24x7
  host_notification_period 24x7
  service_notification_options w,u,c,r
  host_notification_options d,u,r
  service_notification_commands notify-by-email
  host_notification_commands host-notify-by-email
  email efs@mail.fionavar.dd
}
```

notification_commands can include commands for pager calls, sms
messages, and so on while notification_options indicates what type of
events this contact accepts notifications for. In this case warning,
unknown, critical, and recovery for services, and down, unknown, and
recovery for hosts.

##### Contact groups

You will need to edit /etc/nagios/contactgroups.cfg

```plain
# 'nagios-admins' contact group definition
define contactgroup{
  contactgroup_name nagios-admins
  alias Nagios Admins
  members efs
}
```

##### Hosts

/etc/nagios/hosts.cfg

```plain
define host {
  use generic-host ; Name of host template to use

  name fionavar-defaults
  check_command check-host-alive
  max_check_attempts 20
  notification_interval 60
  notification_period 24x7
  notification_options d,u,r
  register 0 ; TEMPLATE, NOT REAL HOST
}

define host {
  use fionavar-defaults
  host_name mornir
  alias Mornir
  address 192.168.8.2
}
```

##### Host groups

/etc/nagios/hostgroup.cfg

```plain
define hostgroup {
  hostgroup_name fionavar
  alias Daniel's Computers
  contact_groups nagios-admins
  members mornir,darien,revor
}
```

Note that you need a host definition for every host to monitor, and
every host needs to be part of some hostgroup.

#### Nagios service definitions

The heart of Nagios is the service definitions file

* For host status monitoring
  * Using nagios-statd-server/client is easier
  * Using nagios-nrpe remote plugin execution is a bit more work,
 but can do things nagios-statd-server can’t, especially for
 network monitoring
* For network status monitoring
  * network services are tested from the host/server, unless you use nagios-nrpe

See the files in /etc/nagios-plugins for available commands

##### Nagios service template

```plain
# Generic service definition template
define service {
  ; The 'name' of this service template, referenced in other service definitions
  name generic-service
  active_checks_enabled 1 ; Checked by a nagios command
  passive_checks_enabled 0 ; External prog gives us status in a file
  parallelize_check 1 ; Active checks in parallel
  obsess_over_service 0 ; For distributed monitoring (advanced topic)
  check_freshness 0 ; Has it been too long (esp. passive)?
  notifications_enabled 0 ; Service notifications are disabled
  event_handler_enabled 0 ; Service event handler is disabled
  flap_detection_enabled 0 ; Detect flip-flopping service state
  process_perf_data 1 ; Process performance data
  retain_status_information 1 ; Retain status information across program restarts
  retain_nonstatus_information 1 ; Retain non-status infoacross program restarts

  register 0 ; DONT REGISTER, ITS NOT A REAL SERVICE, JUST A TEMPLATE!
}
```

##### Nagios base template

```plain
# Base options for most services
define service{
  use generic-service ; Name of service template to use
  name fionavar-service
  is_volatile 0 ; For services to report every time non-OK
  check_period 24x7
  max_check_attempts 3
  normal_check_interval 5
  retry_check_interval 1
  contact_groups nagios-admins
  notification_interval 240
  notification_period 24x7
  notification_options w,c,r
  register 0 ; TEMPLATE ONLY
}
```

##### Service examples

###### Example 1

This service checks that the hosts specified are up (in this case all hosts in hostgroup fionavar)

```plain
define service{
  use fionavar-service
  hostgroup_name fionavar
  service_description net-local-ping
  check_command check_ping!100.0,20%!500.0,60%
}
```

Note the use of hostgroup; one could also specify a single host, or a
comma-separated lists of hosts. Specifying multiple hostnames or a
hostgroup results in a line for each host+service in the service details
screen.

###### Example 2

The following service checks that ssh on the local machine (mornir) is working

```plain
define service{
  use fionavar-service
  host_name mornir
  service_description net-local-ssh
  check_command check_ssh
}
```

###### Example 3

The following service checks that ssh to darien and revor are available
from mornir (the nagios server)

```plain
define service{
  use fionavar-service
  host_name darien,revor
  service_description net-intra-ssh
  check_command check_ssh
}
```

##### Adding new service commands

etc/nagios/checkcommands.cfg is used to define local service commands,
for example:

```plain
define command{
  command_name check_privoxy
  command_line /usr/lib/nagios/plugins/check_http -I $ARG1$ -p $ARG2$ -
u $ARG3$
} ; $ARG1$ and $ARG2$ are replaced by the arguments you
; specify in the service definition with `!' (bang)

define command{
  command_name check_ifstatus_router
  command_line /usr/lib/nagios/plugins/check_ifstatus -H $HOSTADDRESS$
-x $ARG1$
} ; $HOSTADDRESS$ is always a single ip address, derived from
; the service definition and hostgroup.cfg and host.cfg files
```

#### Activating notifications

Once you have configured your services, you may want to be alerted, e.g.
by email, when warning or critical conditions are reached

1. Load ``http://nagiosserver.example.com/nagios``
2. Choose ‘Status Overview’ or ‘Status Summary’ from the sidebar
3. Click on hostgroup name (fionavar in this case)
4. Click ‘Enable notifications for all hosts in this hostgroup’
5. Click ‘Commit’- Now the notifications defined in contacts.cfg and services.cfg will be active (e.g. email, pager on reaching critical status)

#### Monitoring

##### Local (server) monitoring

You can monitor disk, swap, etc on the server. For example, to monitor
the load averages on the Nagios server

```plain
define service{
  use fionavar-service
  host_name mornir
  service_description stats-load
  check_command check_load!1.5!2!2!2!2.5!2.5
}
```

The first three numbers are the levels at which a warning is issued (for
load average over 1 minute, 5 minutes, and 15 minutes), and the second
set are the level at which a critical alert is issued.

##### Disk space

If you have installed nagios-statd-server on the clients (hosts) and
nagios-statd on the server, you can monitor the hosts’ cpu, load, disk,
etc.
nagios-statd requires the use of a real device not a symlink.

For all commands ! is the separator for arguments to the command.

```plain
define service{
  use fionavar-service
  host_name darien
  service_description disk-root
  check_command check_disk_statd_level!/dev/ide/host0/bus0/target0/lun0/part1!85!90
}
```

##### Swap, # of processes

```plain
define service{
  use fionavar-service
  hostgroup_name fionavar
  service_description stats-swap
  check_command check_swap_statd
}

# Notice the notification_options override below
define service{
   use fionavar-service
   host_name darien,revor
   service_description stats-num-proc
   check_command check_procs_statd
  notification_options c,r
}
```

##### Nagios-NRPE overview

* Execute a plugin on a client and have the results returned as if the plugin where executed on the server.
  * Con: There are no pre-configured commands
  * Con: There is no secure way to specify arguments to the commands in a service definition, so it is recommended that you define the commands on a per-client basis.
  * Pro: You can test the availability of network services to the client instead of the server
    * To debug a firewall
    * To check the status of hosts and services visible the (nagios) client, but not the server
* nagios-statd uses the same port as nrpe you will want to use the equivalent local plugins on the server instead.

##### Nagios-NRPE config

###### On the server

The default nrpe.cfg can be boiled down to:

```plain
server_port=5666
# SERVER ADDRESS
# Address that nrpe should bind to in case there are more than one interface
# and you do not want nrpe to bind on all interfaces.
# NOTE: This option is ignored if NRPE is running under either inetd or xinetd

#server_address=192.168.1.1

allowed_hosts=127.0.0.1 # Hosts allowed to talk to nrpe
nrpe_user=nagios
nrpe_group=nagios
dont_blame_nrpe=0 # If this is 1 (true), allow passing of
 # arguments to commands
command_timeout=60 # kill command after this many seconds
include=/etc/nagios/nrpe_local.cfg
# So we make our changes in nrpe_local.cfg not nrpe.cfg
```

###### Client nrpe.cfg

On the client you need to specify that the server is allowed to connect
(in this case the server is 192.168.8.2)

```plain
server_port=5666
# SERVER ADDRESS
# Address that nrpe should bind to in case there are more than one interface
# and you do not want nrpe to bind on all interfaces.
# NOTE: This option is ignored if NRPE is running under either inetd or xinetd

server_address=192.168.8.1

allowed_hosts=127.0.0.1,192.168.8.2 # Hosts allowed to talk to nrpe
nrpe_user=nagios
nrpe_group=nagios
dont_blame_nrpe=0 # If this is 1 (true), allow passing of
 # arguments to commands
command_timeout=60 # kill command after this many seconds
include=/etc/nagios/nrpe_local.cfg
# So we make our changes in nrpe_local.cfg not nrpe.cfg
```

###### Client nrpe_local.cfg

(command definitions)

```plain
command[check_load2]=/usr/lib/nagios/plugins/check_load --warning=5,4.5,4 --critical=7,6.5,5.5
command[check_ping_mornir]=/usr/lib/nagios/plugins/check_ping -H mornir.fionavar.dd -w 100.0,20% -c 500.0,60%
command[check_disk_mornir]=/usr/lib/nagios/plugins/check_disk -w 10% -c 5% -p /dev/ide/host0/bus0/target0/lun0/part1
command[check_swap]=/usr/lib/nagios/plugins/check_swap -w 20% -c 10%
command[check_privoxy_local]=/usr/lib/nagios/plugins/check_http -I darien.fionavar.dd -p 8118 -u http://mornir.fionavar.dd
command[check_httpd_mornir]=/usr/lib/nagios/plugins/check_http -H mornir.fionavar.dd -u http://mornir.fionavar.dd/
```

As you can see, the parameters are hard-coded. This is because there is
no secure way to pass parameters over the network (with nagios).
