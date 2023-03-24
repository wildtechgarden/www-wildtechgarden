---
slug: converting-emails-merge-purge
aliases:
    - /2021/01/13/converting-emails-merge-purge/
    - /converting-emails-merge-purge/
    - /post/converting-emails-merge-purge/
    - /posts/converting-emails-merge-purge/
    - /blog/converting-emails-merge-purge/
    - /docs/deploy-admin/sysadmin-devops/converting-emails-merge-purge/
author: Daniel F. Dickinson
categories:
date: 2021-01-13T20:34:34+00:00
publishDate: 2021-01-13T20:34:34+00:00
summary: "About the effort to unify, eliminate duplication, delete those older than my 'data retention policy', and organize the rest into yearly archives."
description: "About the effort to unify, eliminate duplication, delete those older than my 'data retention policy', and organize the rest into yearly archives."
tags:
- linux
- sysadmin-devops
title: 'Converting emails: Merge & purge'
---

Over far too many years I had amassed a collection of mail archives with much overlap (but also enough unique emails to keep the different archives) in different formats. This article is about the effort to unify them (merge), and eliminate (most) duplication, delete emails older than my new 'personal data retention policy' (purge), and organize what was left into yearly archives so that it is easy to annually remove no longer relevant emails.

All the tools I've used to do this are free, but do require Linux (sorry Windows users) although they might also be available for Mac OS X command line. That is because a) I'm broke and b) figuring what is actually worth paying for in the world of proprietary data conversion is non-trivial (with the SEO games some companies play, it is not enough that a tool shows up high in search rankings, or even in reviews). In any event I had free tools available and the skills to use them, so I did.

So the first thing to do is to figure out the email format required by the tools one is going to use to do a merge and purge. In my case, I used Thunderbird, because I knew it supported what I wanted and comes preinstalled on the (Linux) distro (distribution) I use. It may also have been possible to use Evolution (which I have added to the system and use for accessing Microsoft Exchange email servers, but I have found it's de-duplication not as helpful as the addon I used in Thunderbird).

Since the intermediate tool for the emails was Thunderbird the first trick was to get all the email into Thunderbird's 'mbox and subfolder' format. That's typically not directly possible, so I chose 'Maildir with subdirectories' as the intermediate format.

The first set of conversions was easy; I had a number of PST format files from Outlook backups. To convert them I used the 'pst-utils' package, specifically the 'readpst' program and ended up with Maildir's with the contents of the PST files.

The next set wasn't much more difficult; I had different styles of 'Maildir' I needed to convert to my chosen Maildir format. To do that I used a tool called 'mbsync'. It lives in the package 'isync' on Debian and Ubuntu (and derivatives). The biggest trick was identifying the need for different 'Subfolders' format options in the '.mbsyncrc' file, then it was a matter of letting the mbsync convert the mails.

Converting the Maildirs to Thunderbird's mbox-based format turned out to be a bit of a pain (it turns out that Maildir with subdirectories is not actually a proper standards-compliant format), so I wrote a couple of Bash scripts to do the folder hierarchy conversion, along with the help of a [Perl script from the Dovecot Wiki](https://wiki.dovecot.org/Migration/MailFormat) under the section titled 'Converting Maildir to mbox'.

For reference, here are the two Bash scripts I hacked together (obviously you will need to edit the path to suite your own situation, should you chose to use them for your own conversion).

``md2mb-top.sh``

```bash
#!/bin/bash

SOFAR="$1"
MAILTREE="$2"

if [ -z "$SOFAR" ]; then
 exit 1
fi

if [ -z "$MAILTREE" ]; then
 MAILTREE=""
fi

export SOFAR MAILTREE

RET=0
cd /path/to/ArchivedMail && \
if [ "$(find "Maildir/${MAILTREE:+$MAILTREE/}cur" -mindepth 0 -maxdepth 0 -type d -a ! -empty 2>/dev/null)" = "Maildir/${MAILTREE:+$MAILTREE/}cur" ]; then
 /home/daniel/bin/dw-maildirtombox.pl "${MAILTREE:-.}" "$SOFAR"
 RET="$?"
else
 touch "$SOFAR"
 RET="$?"
fi
if [ "$RET" != "0" ]; then
 echo "Error converting '${MAILTREE}'"
 exit 1
fi

exit 0
```

``md2mb-depth1.sh``

```bash
#!/bin/bash

set -e

SOFAR="$1"
MAILTREE="$2"

if [ -z "$SOFAR" ]; then
 SOFAR=""
fi

if [ -z "$MAILTREE" ]; then
 MAILTREE=""
fi

export SOFAR MAILTREE

if [ "$MAILTREE" = "" ]; then
 MAILBASE="/path/to/ArchivedMail/Maildir"
else
 MAILBASE="/path/to/ArchivedMail/Maildir/${MAILTREE}"
fi

# Only once; convert topmost directory to mbox (if maildir)
# Create mbox subdirs for all subdirs in root dir that have subdirs
# Process all maildirs in current root dir
# Process all subdirs in root dir (recursive)

(
 cd "${MAILBASE}" && \
 if [ -n "$SOFAR" ] && ls -A . 2>/dev/null | grep -qvE '^(cur|tmp|new|\.uidvalidity)$'; then mkdir -p "${SOFAR}"; fi && \
 if [ -z "$MAILTREE" ]; then /home/daniel/bin/md2mb-top.sh "${SOFAR:-/path/to/ArchivedMail/mbox/INBOX}" "$MAILTREE"; fi && \
 find * -mindepth 1 -maxdepth 1 -type d -a ! -empty -a ! -name 'cur' -a ! -name 'tmp' -a ! -name 'new' -execdir sh -c "mkdir -p '${SOFAR:-/path/to/ArchivedMail/mbox}'/'$(dirname '{}')'.sbd" \; && \
 find * -mindepth 0 -maxdepth 0 -type d -a ! -empty -a ! -name 'cur' -a ! -name 'tmp' -a ! -name 'new' -execdir sh -c "/home/daniel/bin/md2mb-top.sh '${SOFAR:-/path/to/ArchivedMail/mbox}'/'{}' '${MAILTREE:+$MAILTREE/}''{}'" \; && \
 find * -mindepth 0 -maxdepth 0 -type d -a ! -empty -a ! -name 'cur' -a ! -name 'tmp' -a ! -name 'new' -execdir sh -c "if ls -A '{}' 2>/dev/null | grep -qvE '^(cur|tmp|new|\.uidvalidity)$'; then /home/daniel/bin/md2mb-depth1.sh '${SOFAR:-/path/to/ArchivedMail/mbox}'/'{}'.sbd '${MAILTREE:+$MAILTREE/}''{}'; fi" \;

 exit 0
)

exit 0
```

Now, one creates a 'fake' email account (neither used for sending or receiving actual mail) in Thunderbird (which is trickier than it needs to be in my opinion) and then modifies the Account 'Properties' to point to the '/path/to/ArchivedMail/mbox' folder created by the above script.

Next, comes a fair bit of 'manual' work. Because of the lack of organization of the email collection I started with, I had to copy mail from a mess of of folders into a coherent hierarchy. There is nothing remarkable about that, it's basically tedious housekeeping stuff (one of the reasons for which it was put off for so long).

The next step was to eliminate duplicates. For that I used the first addon that came up in a search of Thunderbird addons / extensions. It's fairly widely used and works well. I did turn off the 'Message-ID' as a matching criteria because I knew I had quite a mess of duplicate mails with different ID strings. I tweaked a few other setting so that I am fairly confident that mails would only be marked duplicate if actually duplicate, without missing (many) actual duplicates. Again, not terribly exciting.

I then created a special folder for emails I wanted to keep regardless of age. After that I did a search for all emails in all folders (except the keep folder) that were older than 2555 days (7 years). Finally, I selected all the emails that came up and deleted them (actually 'move to trash').

Next in the process was to, for each of the seven years of mail, create a search folder with a search that picked up the mail for that year. I modified the 'Archive' preferences in Thunderbird to use a year-based folders and to keep the folder hierarchy (so I wouldn't end up with an entire year in one mailbox folder). I then selected all the messages in the search and pressed 'A' (which is the keyboard shortcut for 'Archive' in Thunderbird).

Once all the folders were organized into years, and all the original folders were empty, I removed the original folders. I made sure I emptied the 'Trash', expunged all folders, and compacted everything. I then exited Thunderbird.

Next, I changed to '/path/to/ArchivedMail/mbox/Archive' which is the folder Thunderbird created containing the yearly archives of my emails.

I used the package 'mb2md' to convert each year's folder (recursively, using the -R option) to a Maildir. As the third to last step, I tarred and compressed all years and moved them to my personal archives.

The most recent year I uploaded to my email server using 'mbsync', as various hosting changes had mangled what emails were on the server (I don't think I need more than a year 'active', since I have archives if I need them).

And finally I removed the various working folders and originals.

I've now got a reasonably organized historical archive of emails, a year's worth of email 'active', and saved a lot of hard drive space.

I guess Covid is good for something...
