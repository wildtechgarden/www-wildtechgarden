---
slug: debian-custom-media
aliases:
- /2008/11/30/debian-custom-media/
- /post/debian-custom-media/
- /deploy-admin/debian-custom-media/
- /debian-custom-media/
- /debian-custom-cd/
- /post/debian-custom-cd/
- /2008/11/30/debian-custom-cd/
- /docs/archived/debian-custom-media/
- /sysadmin-devops/debian-custom-media/
- /docs/deploy-admin/sysadmin-devops/debian-custom-media/
author: Daniel F. Dickinson
date: '2008-11-30T19:35:00+00:00'
publishDate: '2008-11-30T19:35:00+00:00'
tags:
- archived
- debian
- devel
- linux
- sysadmin-devops
title: "ARCHIVED: Debian custom CD"
description: "This page will describe the steps used to create a custom debian install cd using a partial mirror mostly gathered from a prototype system's apt cache."
summary: "This page will describe the steps used to create a custom debian install cd using a partial mirror mostly gathered from a prototype system's apt cache."
---

{{< details-toc >}}

## ARCHIVED

This document is archived and may be out of date or inaccurate.

## Check the Debian Wiki first

Before reading this page you should try looking at the [DebianCustomCD Page](https://wiki.debian.org/DebianCustomCD) on the [Debian Wiki](https://wiki.debian.org) because it is updated more frequently, and by more contributors.

## Possibly easier alternatives

One possible "alternative" to this procedure is to use the package simple-cdd. It is basically a wrapper around debian-cd and debpartial-mirror to easily create a simple custom cd. Currently only available on Sid.

## Introduction

This page will describe the steps used to create a custom debian install cd using a partial mirror mostly gathered from a prototype system's apt cache. The instructions here assume i386 but should work for any architecture simply by replacing i386 in the instructions with the architecture of your choice.

This article was begun when it was realized that no information on how to create a Debian partial mirror without first having a full mirror appeared to be available. deb-mirror and friends all required that one start with a full mirror *DD 2005-05-27 : I misread the man pages there - deb-mirror doesn't require a full mirror, but it still doesn't let you mirror only a specified set of packages.*

## Quick start

1. Download a DebianInstaller network install cd (netinst.iso)
2. Install Debian on a prototype system (*optional*)
3. apt-get packages (or aptitude if you prefer, as I do) *hint: you don't have to install, just download to the apt cache, as long apt-move works*
4. apt-move to a directory of your choice
5. create a pool directory on the filesystem where you will build your new cd
6. copy the pool directory from network install cd to the directory you just created
7. copy from the directory you apt-move'd to to the pool directory
8. get installer-i386 from a debian mirror which is from the same release of [DebianInstaller](https://wiki.debian.org/DebianInstaller) as your network install cd (unless you also build the installer and associated packages)
9. get overrides.\<dist>.\* files from ``http://<mirror>/debian/indices``
10. place in your debian-dir (i.e. the same directory as the pool directory you created above)
11. gunzip the overrides in the indices directory (you should probably keep the original gzipped versions too)
12. generate packages files
    1. generate [DebianInstaller](https://wiki.debian.org/DebianInstaller) packages files:
       1. [DebianInstaller](https://wiki.debian.org/DebianInstaller) lives in=\<debian-dir>/dists/\<dist>/main/debian-installer/binary-i386 so create the appropriate subdirectories (e.g. mkdir -p /debian/dists/sarge/main/debian-installer/binary-i386
       2. in a directory for your scripts and config files for this project place the following apt.conf:

          ```conf
          APT {
             FTPArchive {
                 Release {
                     Origin "debian-cd";
                     Label "yousarge";
                     Suite "testing";
                     Version "0.1";
                     Codename "sarge";
                     Architectures "i386";
                     Components "main contrib";
                     Description "Your Sarge CD Set";
                 };
              };
           };
           ```

       3. And the following yourcdname-di.conf (creating the directories described therein, as necessary):

          ```conf
          Dir {
             ArchiveDir "/debian";
             OverrideDir "indices";
             CacheDir "/tmp";
          };

          TreeDefault {
              Directory "pool/";
          };

          BinDirectory "pool/main" {
             Packages "dists/sarge/main/debian-installer/binary-i386/Packages";
             BinOverride "override.sarge.main";
             ExtraOverride "override.sarge.extra.main";
          };

          Default {
             Packages {
             Extensions ".udeb";
             Compress ". gzip";
          };

          Contents {
                 Compress "gzip";
             };
          };
          ```

       4. execute the command ``apt-ftparchive -c apt.conf generate yourcdname-di.conf``
    2. repeat for binary-i386:
       * using the following yourcdname.conf instead of yourcdname-di.conf:

         ```conf
         Dir {
            ArchiveDir "/debian";
            OverrideDir "indices";
            CacheDir "/tmp";
         };

         TreeDefault {
             Directory "pool/";
         };

         BinDirectory "pool/main" {
            Packages "dists/sarge/main/binary-i386/Packages";
            BinOverride "override.sarge.main";
            ExtraOverride "override.sarge.extra.main";
         };

         BinDirectory "pool/contrib" {
            Packages "dists/sarge/contrib/binary-i386/Packages";
            BinOverride "override.sarge.contrib";
            ExtraOverride "override.sarge.extra.contrib";
         };

         BinDirectory "pool/non-free" {
            Packages "dists/sarge/non-free/binary-i386/Packages";
            BinOverride "override.sarge.non-free";
            ExtraOverride "override.sarge.extra.non-free";
         };

         Default {
            Packages {
                Extensions ".deb";
                Compress ". gzip";
             };

            Contents {
                Compress "gzip";
            };
         };
         ```

13. create a list of packages you want on the cd (probably just a list of files in your pool dir)
14. Assuming you have debian-cd installed, follow the directions in /usr/share/debian-cd
15. In the mirrorcheck step, if any missing Depends: are listed, download the packages into your pool dir to correct that, regenerate your packages files, and start the debian-cd instructions over again (you may need to exit the shell you started the procedure in because debian-cd alters the environment while it builds the cd [set]).
16. In the make list step watch for debconf\_required errors, and as above download the needed packages, regenerate package lists, and restart the debian-cd procedure.
17. assuming successful completion of the debian-cd cd-building procedure burn your cd and test.

## Detailed instructions

### 1. Getting your packages

#### The hard way

1. Figure out what packages you'll need (this is the hard part because of dependencies).
2. Download them individually (if you make a list and use wget on the list, it wouldn't be as painful, but keeping up with changing versions would rapidly become painful) into the pool directory in the filesystem where you'll be doing your work (e.g. /home/debian/pool])
3. Don't forget any dependencies (by hand! ugh!)

#### The easy way, part I: get your base system

1. Download a [DebianInstaller](https://wiki.debian.org/DebianInstaller)network install cd.
2. Use the install cd and install your base system on some computer
3. Copy the network install cd to the filesystem where you'll be doing your work (e.g. /home/debian)

#### The easy way, part II: getting additional packages

1. Use aptitude or apt-get to download the packages you want on the system and cd
2. Get apt-move (e.g. apt-get install apt-move)
3. Modify apt-move.conf. to use your pool directory as its local mirror (LOCALDIR)
4. apt-move your other packages to your pool directory (e.g. /home/debian/pool) by typing: apt-move update
*NB: I haven't actually tried using apt-move directly onto the partial mirror because of the way in which I learned what I needed to do, but it should work.*

#### Notes on the use of AptMove

You will need to change apt-move.conf to point to your mirror. See [AptMove](https://wiki.debian.org/AptMove) for details (or man apt-move).

#### The slightly harder way, part II: getting additional packages

1. Use aptitude or apt-get to download the packages you want on the system and cd.
2. Get apt-move (e.g. apt-get install apt-move)
3. Modify apt-move.conf to use a temporary directory as its local mirror (LOCALDIR)
4. apt-move your other packages to a temporary directory (e.g. /home/debian/tmp) by typing: apt-move update
5. Use the following script to copy packages from the temporary directory to your pool directory (e.g. /home/debian/pool. *This is my preferred mode of operation because I have more control over what happens to what apt-move calls the 'mirror' (the pool directory), especially when building cd's for testing or unstable, which change quickly.*

   ```sh
   #!/bin/bash

   function print_usage {
       echo
       echo "copy-new-debs-to-pool [--move] [--keep-old] dir-to-copy add-to-dir"
       echo
       echo "paths must be absolute"
       echo "and must point to the directory in which the pool subdirectory besides"
       echo "The pool directory must have main contrib and non-free subdirectories"
       echo
   }

   if [ "$1" = "--move" ] ; then
       MOVE=1
       if [ "$2" = "--keep-old" ] ; then
           KEEP=1
       else
           KEEP=0
       fi
   else
       MOVE=0
       if [ "$1" = "--keep-old" ] ; then
           KEEP=1
       else
           KEEP=0
       fi
   fi

   if [ -z "$1" ]; then
       print_usage
       exit
   fi

   if [ -z "$2" ]; then
       print_usage
       exit
   fi

   if [ $MOVE -eq 1 -a -z "$3" ]; then
       print_usage
       exit
   else
       if [ $KEEP -eq 1 -a -z "$3" ]; then
           print_usage
           exit
       fi
   fi

   if [ $MOVE -eq 1 -a $KEEP -eq 1 -a -z "$4" ]; then
       print_usage
       exit
   fi

   if [ $MOVE -eq 0 -a $KEEP -eq 0 ]; then
       RC1DIR=$1
       RC2DIR=$2
   else
       if [ $MOVE -eq 1 -a $KEEP -eq 1 ]; then
           RC1DIR=$3
           RC2DIR=$4
       else
          RC1DIR=$2
           RC2DIR=$3
       fi
   fi

   echo "Copying from $RC1DIR to $RC2DIR"

   TMPFILE=`tempfile`

   cd $RC1DIR
   find pool -type f | sort >$TMPFILE
   rc1base=$RC1DIR
   rc2base=$RC2DIR
   cd -
   for rc1file in `cat $TMPFILE`; do
       pkgfullname=`basename $rc1file`
       pkgname=`echo $pkgfullname | cut -f1 -d\_`
       rc1ver=`echo $pkgfullname | cut -f2 -d\_`
       pooldir=`dirname $rc1file`
       pkgend=`echo $pkgfullname | cut -f3 -d\_`
       rc2file=`ls $rc2base/$pooldir/$pkgname\\_*\\_$pkgend 2>/dev/null`
       if [ "$rc2file" ]; then
           rc2maxver="!!!!!!!!!!!!!!!!!"
           rc2maxfile="!!!!!!!!!!!!!!!!"
           for rc2match in $rc2file; do
               rc2pkgfullname=`basename $rc2match`
               rc2ver=`echo $rc2pkgfullname | cut -f2 -d\_`
               if [ "$rc2ver" ">" "$rc2maxver" ];
               then rc2maxver=$rc2ver
                   rc2maxfile=$rc2match
               fi
           done
           rc2file=$rc2maxfile
           if [ "$rc1ver" > "$rc2maxver" ] ; then
               echo "Copying $rc1file newer than $rc2file"
               if [ $MOVE -eq 1 ] ; then
                   mv -f $rc1base/$rc1file `dirname $rc2base/$rc1file`
                   if [ $KEEP -eq 1 ]; then
                       echo "Not removing obsolete $rc2file"
                   else
                       echo "Removing obsolete $rc2file"
                       rm -f $rc2base/$rc2file
                   fi
               else
                   cp $rc1base/$rc1file `dirname $rc2base/$rc1file`
                   if [ $KEEP -eq 1 ]; then
                        echo "Not removing obsolete $rc2file"
                   else
                        rm -f $rc2base/$rc2file
                   fi
               fi
               continue
           fi
       else
           echo "Copying $pkgname not in $RC2DIR"
           install -d $RC2DIR/`dirname $rc1file`
           if [ $MOVE -eq 1 ]; then
               mv -f $RC1DIR/$rc1file `dirname $RC2DIR/$rc1file`
           else
               cp $RC1DIR/$rc1file `dirname $RC2DIR/$rc1file`
           fi
       fi
   done

   rm -f $TMPFILE
   ```

#### Alternate method

Instead of copying the network install cd first, copy your APT cache to your desired pool directory first (as above), then use the above script to copy from the network install pool directory to your pool directory.

### 2. Get DebianInstaller and udebs

#### Option 1

*Should only be used when using a stable distribution"s network install cd and stable packages, for sarge or later because the udebs must match the installer for a successful install. If you insist on using it with testing or unstable, make sure you"re using the right versions of the udebs, especially kernel, for the installer. **You have been warned.***

1. Download installer-i386 from a [Debian](http://www.debian.org) mirror (e.g. <ftp://ftp.debian.org/debian/dists/sarge/main/current>)
2. You should have the correct udebs in your tree if you have downloaded the installer-i386 from the same distribution as your network install cd

#### Option 2

1. Build [DebianInstaller](https://wiki.debian.org/DebianInstaller) (which also downloads udebs). See [DebianInstaller/Build](https://wiki.debian.org/DebianInstaller/Build)
2. Copy udebs to your pool directory from debian-installer/installer/build/apt.udeb, using something like the following script: *Improved 2004-12-23*

   ```sh
   #!/bin/bash

   function print_usage {
        echo
        echo "move-installer-udebs source-directory destination-directory"
        echo
        echo "paths must be absolute"
        echo "source-directory is the directory containing the udebs"
        echo "destination-directory is the directory containing the pool directory"
   }

    if [ -z "$1" ]; then
        print_usage
        exit
    fi

    if [ -z "$2" ]; then
        print_usage
        exit
    fi

    SRCDIR=$1
    DESTDIR=$2

    echo "Copying from $SRCDIR to $DESTDIR"
    TMPFILE=`tempfile`
    pushd $SRCDIR

    find * -name "*.udeb" -a -type f | sort >$TMPFILE
    srcbase=$SRCDIR
    destbase=$DESTDIR
    cd -
    for srcfile in `cat $TMPFILE`; do
        pkgfullname=`basename $srcfile .udeb`
        pkgname=`echo $pkgfullname | cut -f1 -d\_`
        pkgver=`echo $pkgfullname | cut -f2 -d\_`
        pkgend=`echo $pkgfullname | cut -f3 -d\_`
        if [ "$pkgend" = $pkgname ]; then
            pkgend=`dpkg -I $SRCDIR/$srcfile | awk "/Architecture: / { print $2 }"`
        fi
        if [ "$pkgver" = $pkgname ]; then
            pkgver=`dpkg -I $SRCDIR/$srcfile | awk "/Version: / { print $2 }"`
        fi
        pooldir=`dpkg -I $SRCDIR/$srcfile | awk "/Source: / { print $2 }"`
        if [ -z "$pooldir" ] ; then
            pooldir=$pkgname
        fi
        poolprefix=`expr substr $pooldir 1 1`
        if [ "$poolprefix" = "l" ]; then
            poolpref2=`expr substr $pooldir 1 3`
            if [ "$poolpref2" = "lib" ] ; then
                poolprefix=`expr substr $pooldir 1 4`
            else
                poolprefix="l"
            fi
        fi
        echo "Copying $pkgname\\_$pkgver\\_$pkgend.udeb to $DESTDIR/pool/main/$poolprefix/$pooldir"
        install -d $DESTDIR/pool/main/$poolprefix/$pooldir
        cp $SRCDIR/$srcfile $DESTDIR/pool/main/$poolprefix/$pooldir/$pkgname\\_$pkgver\\_$pkgend.udeb
   done

   rm -f $TMPFILE

   popd
   ```

### 3. Get overrides.\<dist>.*

1. Download /debian/indices/overrides.\<dists>.*.gz for your distro (e.g. for sarge, /debian/indices/overrides.sarge.*.gz) into the directory indices which is in the same root directory as your pool (mirror) directory (e.g. /debian/pool, so /debian/indices).
2. gunzip the overrides, keeping the compressed files.

If you want to includes packages from non-US you ought to create another indices directory (e.g. indices-non-US), and get the overrides from a non-US mirror (from /debian-non-US/indices-non-US)

### 4. Generate Packages.gz and Release files for your "distribution"

1. generate [DebianInstaller](https://wiki.debian.org/DebianInstaller) packages files:
    * [DebianInstaller](https://wiki.debian.org/DebianInstaller) lives in \<debian-dir>/dists/\<dist>/main/debian-installer/binary-i386 so create the appropriate subdirectories (e.g. mkdir -p
     /debian/dists/sarge/main/debian-installer/binary-i386)
2. in a directory (e.g. custom-cd-scripts) for your scripts and config files for this project place the following apt.conf:

   ```conf
   APT {
        FTPArchive {
            Release {
                Origin "debian-cd";
                Label "yoursarge";
                Suite "testing";
                Version "0.1";
                Codename "sarge";
                Architectures "i386";
                Components "main contrib";
                Description "Your Sarge CD Set";
            };
        };
   };

3. And the following customcd-di.conf (creating the directories described therein, as necessary):

   ```conf
   Dir {
       ArchiveDir "/debian";
       OverrideDir "indices";
       CacheDir "/tmp";
   };

    TreeDefault {
        Directory "pool/";
    };

    BinDirectory "pool/main" {
        Packages "dists/sarge/main/debian-installer/binary-i386/Packages";
        BinOverride "override.sarge.main";
        ExtraOverride "override.sarge.extra.main";
    };

    Default {
        Packages {
            Extensions ".udeb";
            Compress ". gzip";
        };

    Contents {
            Compress "gzip";
        };
    };
    ```

    * ArchiveDir is the parent directory of your pool and dists subdirectories
    * OverrideDir is the directory which contains your overrides *Note that this means that if you want non-US, you need another .conf with your non-US directories.*
    * CacheDir is your temporary (cache) directory.
    * Under TreeDefault, Directory indicates the location of your pool (archive) directory
    * The path in quotes after BinDirectory (and before the curly brace), is the location, relative to ArchiveDir of the binary packages (well actually the alphabetic directories, which have the package directories under them).
    * Under BinDirectory, Packages is the full pathname of the Packages (without .gz even if you are creating compressed files) file you are creating (in this case the debian-installer Packages.gz).
4. execute the command in the directory containing the pool and dists directories

   ```bash
   apt-ftparchive -c custom-cd-scripts/apt.conf generate custom-cd-scripts/customcd-di.conf
   ```

5. repeat for the binary-i386 directories (under main, contrib, non-free):
   * using the following customcd.conf instead of customcd-di.conf:

      ```conf
      Dir {
         ArchiveDir "/debian";
         OverrideDir "indices";
         CacheDir "/tmp";
      };

      TreeDefault {
          Directory "pool/";
      };

      BinDirectory "pool/main" {
         Packages "dists/sarge/main/binary-i386/Packages";
         BinOverride "override.sarge.main";
         ExtraOverride "override.sarge.extra.main";
      };

      BinDirectory "pool/contrib" {
         Packages "dists/sarge/contrib/binary-i386/Packages";
         BinOverride "override.sarge.contrib";
         ExtraOverride "override.sarge.extra.contrib";
      };

      BinDirectory "pool/non-free" {
         Packages "dists/sarge/non-free/binary-i386/Packages";
         BinOverride "override.sarge.non-free";
         ExtraOverride "override.sarge.extra.non-free";
      };

      Default {
        Packages {
          Extensions ".deb";
          Compress ". gzip";
        };

        Contents {
           Compress "gzip";
        };
      };
      ```

   * If you are using any non-US packages you will need to repeat the above Packages file creation in each of the appropriate subdirectories.
6. Generate Release file:
    * execute the following command in the directory containing the pool and dists directories

      ```bash
      apt-ftparchive -c custom-cd-scripts/apt.conf release dists/sarge >dists/sarge/Release
      ```

### 5. Create list Of files to include on CD

* You can do this by hand, or if you just want to include the latest versions of everything in your mirror (pool) directory, you can use something like this script:

  ```sh
  #!/bin/sh

  function print_usage {
    echo gen-task-dfdsarge pool-directory
  }

  if [ -z "$1" ] ; then
  print_usage
  exit
  fi

  POOLDIR=$1
  TMPFILE=`/bin/tempfile`

  if [ `expr substr $POOLDIR 1 1` != \/ ]; then
       POOLDIR=`pwd`/$POOLDIR
  fi

  IFS=$"\n"
  for package in `find $POOLDIR -type f`; do
      pkgfilename=`basename $package`
      pkgname=`echo $pkgfilename|cut -f1 -d\_`
      echo $pkgname>>$TMPFILE
  done
  cat $TMPFILE | sort -u
  ```

* Alternatively combine the approaches and remove packages you don"t want. Note that dependencies are resolved for any debs (but not udebs), so don"t be afraid to removing the lib\* packages (that way only what you actually need, or manually want to include, are added to the cd), except for lib\*-udeb\* which should left if you want the installer to work correctly.

### 6. Install and configure debian-cd

1. Download and install the debian-cd package (e.g. apt-get
install debian-cd)
2. ``cd /usr/share/debian-cd`` and edit ``CONF.sh``
   A sample [=CONF.sh] is reproduced below:

   ```conf
    #
    # This file will have to be sourced where needed
    #

    # Unset all optional variables first to start from a clean state
    unset NONUS || true
    unset FORCENONUSONCD1 || true
    unset NONFREE || true
    unset CONTRIB || true
    unset EXTRANONFREE || true
    unset LOCAL || true
    unset LOCALDEBS || true
    unset SECURED || true
    unset SECURITY || true
    unset BOOTDIR || true
    unset BOOTDISKS || true
    unset SYMLINK || true
    unset COPYLINK || true
    unset MKISOFS || true
    unset MKISOFS_OPTS || true
    unset ISOLINUX || true
    unset EXCLUDE || true
    unset SRCEXCLUDE || true
    unset NORECOMMENDS || true
    unset NOSUGGESTS || true
    unset DOJIGDO || true
    unset JIGDOCMD || true
    unset JIGDOTEMPLATEURL || true
    unset JIGDOFALLBACKURLS || true
    unset JIGDOINCLUDEURLS || true
    unset JIGDOSCRIPT || true
    unset DEFBINSIZE || true
    unset DEFSRCSIZE || true
    unset FASTSUMS || true
    unset PUBLISH_URL || true
    unset PUBLISH_NONUS_URL || true
    unset PUBLISH_PATH || true
    unset UDEB_INCLUDE || true
    unset UDEB_EXCLUDE || true
    unset BASE_INCLUDE || true
    unset BASE_EXCLUDE || true
    unset INSTALLER_CD || true
    unset DI_CODENAME || true
    unset MAXCDS || true
    unset SPLASHPNG || true

    # The debian-cd dir
    # Where I am (hoping I"m in the debian-cd dir)
    export BASEDIR=`pwd`

    # Building sarge cd set ...
    export CODENAME=sarge

    # By default use Debian installer packages from $CODENAME
    if [ ! "$DI_CODENAME" ]
    then
    export DI_CODENAME=$CODENAME
    fi

    # If set, controls where the d-i components are downloaded from.
    # This may be an url, or "default", which will make it use the default url
    # for the daily d-i builds. If not set, uses the official d-i images from
    # the Debian mirror.
    #export DI_WWW_HOME=default

    # Version number, "2.2 r0", "2.2 r1" etc.
    export DEBVERSION="3.1"

    # Official or non-official set.
    # NOTE: THE "OFFICIAL" DESIGNATION IS ONLY ALLOWED FOR IMAGES AVAILABLE
    # ON THE OFFICIAL DEBIAN CD WEBSITE http://cdimage.debian.org
    #export OFFICIAL="Unofficial"
    #export OFFICIAL="Official"
    #export OFFICIAL="Official Beta"
    export OFFICIAL="Daniel"s Unofficial Debian Sarge (testing)"

    # ... for arch
    export ARCH=`dpkg --print-installation-architecture`

    # IMPORTANT : The 4 following paths must be on the same partition/device.
    # If they aren't then you must set COPYLINK below to 1. This
    # takes a lot of extra room to create the sandbox for the ISO
    # images, however. Also, if you are using an NFS partition for
    # some part of this, you must use this option.
    # Paths to the mirrors
    #export MIRROR=/ftp/debian
    export MIRROR=/home/archive/debian

    # Comment the following line if you don"t have/want non-US
    #export NONUS=/ftp/debian-non-US

    # And this option will make you 2 copies of CD1 - one with all the
    # non-US packages on it, one with none. Useful if you"re likely to
    # need both.
    #export FORCENONUSONCD1=1

    # Path of the temporary directory
    #export TDIR=/ftp/tmp
    export TDIR=/debian/tmp

    # Path where the images will be written
    #export OUT=/rack/debian-cd
    export OUT=/debian/debian-cd

    # Where we keep the temporary apt stuff.
    # This cannot reside on an NFS mount.
    #export APTTMP=/ftp/tmp/apt
    export APTTMP=/debian/tmp-apt

    # Do I want to have NONFREE merged in the CD set
    # export NONFREE=1

    # Do I want to have CONTRIB merged in the CD set
    export CONTRIB=1

    # Do I want to have NONFREE on a separate CD (the last CD of the CD set)
    # WARNING: Don"t use NONFREE and EXTRANONFREE at the same time !
    # export EXTRANONFREE=1

    # If you have a $MIRROR/dists/$CODENAME/local/binary-$ARCH dir with
    # local packages that you want to put on the CD set then
    # uncomment the following line
    # export LOCAL=1

    # If your local packages are not under $MIRROR, but somewhere else,
    # you can uncomment this line and edit to to point to a directory
    # containing dists/$CODENAME/local/binary-$ARCH
    # export LOCALDEBS=/home/joey/debian/va/debian

    # If you want a \<codename>-secured tree with a copy of the signed
    # Release.gpg and files listed by this Release file, then
    # uncomment this line
    # export SECURED=1

    # Where to find the security patches. This directory should be the
    # top directory of a security.debian.org mirror.
    #export SECURITY="$TOPDIR"/debian/debian-security

    # Sparc only : bootdir (location of cd.b and second.b)
    # export BOOTDIR=/boot

    # Symlink farmers should uncomment this line :
    # export SYMLINK=1

    # Use this to force copying the files instead of symlinking or hardlinking
    # them. This is useful if your destination directories are on a different
    # partition than your source files.
    # export COPYLINK=1

    # Options
    # export MKISOFS=/usr/bin/mkisofs
    # export MKISOFS_OPTS="-r" #For normal users
    # export MKISOFS_OPTS="-r -F ." #For symlink farmers

    # ISOLinux support for multiboot on CD1 for i386
    export ISOLINUX=1

    # uncomment this to if you want to see more of what the Makefile is doing
    #export VERBOSE_MAKE=1

    # uncomment this to make build_all.sh try to build a simple CD image if
    # the proper official CD run does not work
    #ATTEMPT_FALLBACK=yes

    # Set your disk size here in MB. Used in calculating package and
    # source file layouts in build.sh and build_all.sh. Defaults are for
    # CD-R, try ~4600 for DVD-R.
    export DEFBINSIZE=630
    export DEFSRCSIZE=635

    # We don"t want certain packages to take up space on CD1...
    export EXCLUDE="$BASEDIR"/tasks/exclude-sarge
    # ...but they are okay for other CDs (UNEXCLUDEx == may be included on CD >= x)
    export UNEXCLUDE2="$BASEDIR"/tasks/unexclude-CD2-sarge
    # Any packages listed in EXCLUDE but not in any UNEXCLUDE will be
    # excluded completely.

    # We also exclude some source packages
    #export SRCEXCLUDE="$BASEDIR"/tasks/exclude-src-potato

    # Set this if the recommended packages should be skipped when adding
    # package on the CD. The default is "false".
    export NORECOMMENDS=1

    # Set this if the suggested packages should be skipped when adding
    # package on the CD. The default is "true".
    #export NOSUGGESTS=1

    # Produce jigdo files:
    # 0/unset = Don"t do jigdo at all, produce only the full iso image.
    # 1 = Produce both the iso image and jigdo stuff.
    # 2 = Produce ONLY jigdo stuff by piping mkisofs directly into jigdo-file,
    # no temporary iso image is created (saves lots of disk space).
    # NOTE: The no-temp-iso will not work for (at least) alpha and powerpc
    # since they need the actual .iso to make it bootable. For these archs,
    # the temp-iso will be generated, but deleted again immediately after the
    # jigdo stuff is made; needs temporary space as big as the biggest image.
    #export DOJIGDO=2
    #
    # jigdo-file command & options
    # Note: building the cache takes hours, so keep it around for the next run
    #export JIGDOCMD="/usr/local/bin/jigdo-file --cache=$HOME/jigdo-cache.db"
    #
    # HTTP/FTP URL for directory where you intend to make the templates
    # available. You should not need to change this; the default value ""
    # means "template in same dir as the .jigdo file", which is usually
    # correct. If it is non-empty, it needs a trailing slash. "%ARCH%"
    # will be substituted by the current architecture.
    #export JIGDOTEMPLATEURL=""
    #
    # Name of a directory on disc to create data for a fallback server in.
    # Should later be made available by you at the URL given in
    # JIGDOFALLBACKURLS. In the directory, two subdirs named "Debian" and
    # "Non-US" will be created, and filled with hard links to the actual
    # files in your FTP archive. Because of the hard links, the dir must
    # be on the same partition as the FTP archive! If unset, no fallback
    # data is created, which may cause problems - see README.
    #export JIGDOFALLBACKPATH="$(OUT)/snapshot/"
    #
    # Space-separated list of label->URL mappings for "jigdo fallback
    # server(s)" to add to .jigdo file. If unset, no fallback URL is
    # added, which may cause problems - see README.
    #export JIGDOFALLBACKURLS="Debian=http://myserver/snapshot/Debian/ Non-US=http://myserver/snapshot/Non-US/"
    #
    # Space-separated list of "include URLs" to add to the .jigdo file.
    # The included files are used to provide an up-to-date list of Debian
    # mirrors to the jigdo _GUI_application_ (_jigdo-lite_ doesn't support
    # "[Include ...]").
    export JIGDOINCLUDEURLS="http://cdimage.debian.org/debian-cd/debian-servers.jigdo"
    #
    # $JIGDOTEMPLATEURL and $JIGDOINCLUDEURLS are passed to
    # "tools/jigdo_header", which is used by default to generate the
    # [Image] and [Servers] sections of the .jigdo file. You can provide
    # your own script if you need the .jigdo file to contain different
    # data.
    #export JIGDOSCRIPT="myscript"

    # If set, use the md5sums from the main archive, rather than calculating
    # them locally
    #export FASTSUMS=1

    # A couple of things used only by publish_cds, so it can tweak the
    # jigdo files, and knows where to put the results.
    # You need to run publish_cds manually, it is not run by the Makefile.
    export PUBLISH_URL="http://cdimage.debian.org/jigdo-area"
    export PUBLISH_NONUS_URL="http://non-US.cdimage.debian.org/jigdo-area"
    export PUBLISH_PATH="/home/jigdo-area/"

    # Where to find the boot disks
    #export BOOTDISKS=$TOPDIR/ftp/skolelinux/boot-floppies

    # File with list of packages to include when fetching modules for the
    # first stage installer (debian-installer). One package per line.
    # Lines starting with "#" are comments. The package order is
    # important, as the packages will be installed in the given order.
    #export UDEB_INCLUDE="$BASEDIR"/data/$CODENAME/udeb_include

    # File with list of packages to exclude as above.
    #export UDEB_EXCLUDE="$BASEDIR"/data/$CODENAME/udeb_exclude

    # File with list of packages to include when running debootstrap from
    # the first stage installer (currently only supported in
    # debian-installer). One package per line. Lines starting with "#"
    # are comments. The package order is important, as the packages will
    # be installed in the given order.
    #export BASE_INCLUDE="$BASEDIR"/data/$CODENAME/base_include

    # File with list of packages to exclude as above.
    #export BASE_EXCLUDE="$BASEDIR"/data/$CODENAME/base_exclude

    # Only put the installer onto the cd (set NORECOMMENDS,... as well).
    # INSTALLER_CD=0: nothing special (default)
    # INSTALLER_CD=1: just add debian-installer (use TASK=tasks/debian-installer)
    # INSTALLER_CD=2: add d-i and base (use TASK=tasks/debian-installer+kernel)
    #export INSTALLER_CD=0
    export INSTALLER_CD=1

    # Parameters to pass to kernel when the CD boots. Not currently supported
    # for all architectures.
    #export KERNEL_PARAMS="DEBCONF_PRIORITY=critical"

    # If set, limits the number of binary CDs to produce.
    #export MAXCDS=1

    # If set, overrides the boot picture used.
    #export SPLASHPNG="$BASEDIR/data/$CODENAME/splash-img.png"

    # Used by build.sh to determine what to build, this is the name of a target
    # in the Makefile. Use bin-official_images to build only binary CDs. The
    # default, official_images, builds everything.
    #IMAGETARGET=official_images
   ```

   * Note that INSTALLER_CD is set to 1. This includes tasks/debian-installer+kernel, and some other "magic". Just make sure the list of packages you produced as instructed above has all the kernel and debian-installer packages, and that tasks/debian-installer+kernel doesn't list any outdated packages.

   * Also note that the directories must all be on the same filesystem (except those under /usr/share/debian-cd)

### The remainder of the debian-cd procedure

1. Start a new shell (e.g. bash)
2. Source CONF.sh, e.g. by typing:

   ```sh
   . CONF.sh
   ```

3. make distclean
4. make mirrorcheck
    * If there are any missing dependencies, download them into your pool directory, regenerate your packages file, and start the debian-cd part of this procedure over again.
5. make status
    * This should never fail. If it does you"re best determining what went wrong, but if you insist you can try ``make correctstatus``
6. make bin-list TASK=tasks/customcd
    * This generates a binary only distribution. If you want sources as well you will need to modify the entire procedure somewhat, as I haven"t tried that yet (so far this procedure has been developed for the author and not distribution).
7. make bootable
8. Makes the binary cd(s?) bootable.
9. make bin-md5list
    * Create the md5 checksums so that the cd can be verified.
10. make bin-images
    * Actually makes the cd
11. make imagesums
    * the md5 checksum for the actual cd images
12. Burn it/them.
