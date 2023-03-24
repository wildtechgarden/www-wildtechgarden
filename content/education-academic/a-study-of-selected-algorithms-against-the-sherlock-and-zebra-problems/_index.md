---
slug: a-study-of-selected-algorithms-against-the-sherlock-and-zebra-problems
aliases:
- /2003/02/09/a-study-of-selected-algorithms-against-the-sherlock-and-zebra-problems/
- /post/a-study-of-selected-algorithms-against-the-sherlock-and-zebra-problems/
- /docs/education-academic/a-study-of-selected-algorithms-against-the-sherlock-and-zebra-problems/
- /a-study-of-selected-algorithms-against-the-sherlock-and-zebra-problems/
- /projects/old-school/undergraduate/a-study-of-selected-algorithms-against-the-sherlock-and-zebra-problems/
author: Daniel F. Dickinson
date: '2021-03-02T13:34:12+00:00'
publishDate: '2003-02-09T10:25:00+00:00'
summary: The binary constraint satisfaction problem (bcsp) is an important area of
  research because so many problems can be represented in this form [Kumar92].
description: The binary constraint satisfaction problem (bcsp) is an important area of
  research because so many problems can be represented in this form [Kumar92].
tags:
- archived
- theory
title: A Study of selected algorithms against the Sherlock and Zebra problems
showChildPages: false
card: true
frontCard: true
---

## CIS*4750 Course Project

Author: Daniel F. Dickinson

Date: 2003-02-09

{{< details-toc >}}

## Introduction

The binary constraint satisfaction problem (bcsp) is an important area of research because so many problems can be represented in this form [Kumar92]. For that reason this paper attempts to answer a number of questions about the use of bcsp’s using two different types of problem. The hypotheses that this paper studies are:

1. Arc consistency, found using AC-3 from [Kumar92], alone is sufficient to solve the Zebra problem.
2. Arc consistency, found using AC-3, alone is sufficient to solve the Sherlock problem.
3. Backmarking with conflict-directed backjumping (as modified by [Kondrak97] and called BM-CBJ2) is more efficient at solving the Zebra problem than making the problem arc consistent using AC-3 for a large set of random instances of the Zebra problem.
4. BM-CBJ2 is more efficient at solving most cases in a large random sample of instances of the Sherlock problem than AC-3.
5. BM-CBJ2 is more efficient at solving most cases in a large random sample of instances of the Zebra problem than the genetic algorithms developed by the author for an assignment for CIS*4750.

In order to test these hypotheses the author developed software which
generated random Sherlock and Zebra problems and saved them to disk. The
author also wrote implementations of the above algorithms which could
read the problems from disk and solve them using the desired algorithm.
This software was written and run in Java 2 SE using Sun’s JDK1.4 on a
system with an AMD-K6-2 300 CPU, 196MB of RAM, and running RedHat Linux
7.2 (Enigma). In addition to the Java software, script files were
written which allowed the author to measure the CPU and
system-on-behalf-of-the-program time and record it in a file suitable
for import into a spreadsheet program.

## Table of Contents

1. [Definitions for the Zebra and Sherlock problems](definitions-for-zebra-and-sherlock.md)
2. [Algorithms for solving binary constraint satisfaction problems](algorithms-for-solving-bcsp.md)
3. [Generate random problems](generate-random-problems.md)
4. [Results for solving Zebra and Sherlock problems](results-for-solving-zebra-and-sherlock.md)
5. [Bibliography and Appendices](bibliography-and-appendices)
