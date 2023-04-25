---
slug: definitions-for-zebra-and-sherlock
aliases:
- /projects/old-school/undergraduate/a-study-of-selected-algorithms-against-the-sherlock-and-zebra-problems/definitions-for-zebra-and-sherlock/
- /docs/education-academic/a-study-of-selected-algorithms-against-the-sherlock-and-zebra-problems/definitions-for-zebra-and-sherlock/
title: "Definitions for Zebra and Sherlock"
author: Daniel F. Dickinson
tags:
- archived
- theory
date: 2021-03-02T13:34:12+00:00
publishDate: 2003-02-09T10:25:00+00:00
description: "Various definitions for selected algorithms against the Zebra and Sherlock problems"
---

{{< details-toc >}}

## General Definitions

* *arc consistency* The domains of a variable V{{< sub >}}i{{< /sub >}} is such that for each constraint C{{< sub >}}i,j{{< /sub >}} V{{< sub >}}i{{< /sub >}} is consistent with the constraint for some permissible value of V{{< sub >}}j{{< /sub >}} for every value in the domain of V{{< sub >}}i{{< /sub >}} That is for every value *x* in D{{< sub >}}i{{< /sub >}} (the domain of *i*) there exists some *y* in D{{< sub >}}j{{< /sub >}} such that C{{< sub >}}i,j{{< /sub >}} is satisfied. It is important to note that arc consistency is directional (that is (V{{< sub >}}i{{< /sub >}}, V{{< sub >}}j{{< /sub >}}) being arc consistent does not mean (V{{< sub >}}j{{< /sub >}}, V{{< sub >}}i{{< /sub >}}) is arc consistent).
* *binary constraint satisfaction problem* The binary constraint satisfaction problem, as used in this paper, involves finding a solution such that a set of variables { V{{< sub >}}1{{< /sub >}}, V{{< sub >}}2{{< /sub >}}, … , V{{< sub >}}n{{< /sub >}} }, each having a domain D{{< sub >}}i{{< /sub >}} such that V{{< sub >}}i{{< /sub >}} takes on a value from D{{< sub >}}i{{< /sub >}}, does not conflict with a set of binary constraints { C{{< sub >}}1,1{{< /sub >}}, C{{< sub >}}1,2{{< /sub >}}, …, C{{< sub >}}1,n{{< /sub >}}, …, C{{< sub >}}2,1{{< /sub >}}, C{{< sub >}}2,2{{< /sub >}}, …, C{{< sub >}}2,n{{< /sub >}}, …, C{{< sub >}}n,1{{< /sub >}}, C{{< sub >}}n,2{{< /sub >}}, …, C{{< sub >}}n,n{{< /sub >}} } where C{{< sub >}}i,j{{< /sub >}} is a constraint (relation) between V{{< sub >}}i{{< /sub >}} and V{{< sub >}}j{{< /sub >}} that must be true, and if C{{< sub >}}i,j{{< /sub >}} is null there is no constraint between V{{< sub >}}i{{< /sub >}} and V{{< sub >}}j{{< /sub >}}.
* *K-consistent* Choose any K - 1 variables that satisfy the constraints among those variables. Then choose any Kth variable. If there exists a value for this variable that satisfies all the constraints among these K variables then the constraint problem can be said to be K consistent. Paraphrased from [Kumar92].

## Problem Definitions

* The Zebra Problem Is a standard test for constraint satisfaction algorithms. In [Prosser93] it is defined as follows:
  * V{{< sub >}}1{{< /sub >}} - V{{< sub >}}5{{< /sub >}} correspond to five houses; Red, Blue, Yellow, Green, and Ivory, respectively.
  * V{{< sub >}}6{{< /sub >}} - V{{< sub >}}10{{< /sub >}} correspond to five brands of cigarettes; Old-Gold, Parliament, Kools, Lucky, and Chesterfield, respectively.
  * V{{< sub >}}11{{< /sub >}} - V{{< sub >}}15{{< /sub >}} correspond to five nationalities: Norwegian, Ukrainian, Englishman, Spaniard, and Japanese, respectively.
  * V{{< sub >}}16{{< /sub >}} - V{{< sub >}}20{{< /sub >}} correspond to five pets: Zebra, Dog, Horse, Fox, and Snails, respectively.
  * V{{< sub >}}21{{< /sub >}} - V{{< sub >}}25{{< /sub >}} correspond to five drinks: Coffee, Tea, Water, Milk, Orange Juice, respectively. This can be represented in a tabular format as follows:

|     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |
|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|
| R   | B   | Y   | G   | I   |     | R   | B   | Y   | G   | I   |     | R   | B   | Y   | G   | I   |     | R   | B   | Y   | G   | I   |     | R   | B   | Y   | G   | I   |
| O   | P   | K   | L   | C   |     | O   | P   | K   | L   | C   |     | O   | P   | K   | L   | C   |     | O   | P   | K   | L   | C   |     | O   | P   | K   | L   | C   |
| N   | U   | E   | S   | J   |     | N   | U   | E   | S   | J   |     | N   | U   | E   | S   | J   |     | N   | U   | E   | S   | J   |     | N   | U   | E   | S   | J   |
| Z   | D   | H   | F   | S   |     | Z   | D   | H   | F   | S   |     | Z   | D   | H   | F   | S   |     | Z   | D   | H   | F   | S   |     | Z   | D   | H   | F   | S   |
| C   | T   | W   | M   | O   |     | C   | T   | W   | M   | O   |     | C   | T   | W   | M   | O   |     | C   | T   | W   | M   | O   |     | C   | T   | W   | M   | O   |
{.no-responsive-table, .no-zebra-table}

> **Zebra Table**

All instances of the Zebra have the following constraints:

* Each house is of a different colour,
* and is inhabited by a single person,
* who smokes a unique brand of cigarettes,
* has a preferred drink,
* and owns a pet. In addition to these constraints each instance of the Zebra problem has a subset of all valid constraints for the instance’s solution. The valid constraints for the Zebra Problem are chosen from the set { V{{< sub >}}i{{< /sub >}} in-same-column-as V{{< sub >}}j{{< /sub >}}, V{{< sub >}}i{{< /sub >}} next-to V{{< sub >}}j{{< /sub >}}, V{{< sub >}}i{{< /sub >}} next-to-and-right-of V{{< sub >}}j{{< /sub >}}, and V{{< sub >}}i{{< /sub >}} = known-column } [^1] where the constraint is true for a give i and j.

For the purposes of the paper, the query is, “Who lives in which house, smokes which brand of cigarette, is a citizen of which country, owns which pet, and drinks which drink?” The benchmark Zebra problem has the following constraints:

* The Englishman lives in the Red house.
* The Spaniard owns a Dog.
* Coffee is drunk in the Green house.
* The Ukrainian drinks tea.
* The Green house is to the immediate right of the Ivory house.
* The Old-Gold smoker owns Snails.
* Kools are smoked in the Yellow house.
* Milk is drunk in the middle house.
* The Norwegian lives in the first house on the left.
* The Chesterfield smoker lives next to the Fox owner.
* Kools are smoked in the house next to the house where the Horse is kept.
* The Lucky smoker drinks Orange Juice.
* The Japanese smokes Parliament.
* The Norwegian lives next to the Blue house.
* The Sherlock Problem Is based on a computer game called Sherlock. It is a variation of the Zebra problem with six choices and rows and has additional types of constraints. It can be defined as follows:
  * V{{< sub >}}1{{< /sub >}} - V{{< sub >}}6{{< /sub >}} correspond to six houses; Red, Blue, Yellow, Green, and Ivory, and Brown respectively.
  * V{{< sub >}}7{{< /sub >}} - V{{< sub >}}12{{< /sub >}} correspond to six nationalities: Norwegian, Ukrainian, Englishman, Spaniard, Japanese, and African respectively.
  * V{{< sub >}}13{{< /sub >}} - V{{< sub >}}18{{< /sub >}} correspond to six house numbers; 1, 2, 3, 4, 5, and 6 respectively.
  * V{{< sub >}}19{{< /sub >}} - V{{< sub >}}24{{< /sub >}} correspond to six fruits: Pear, Orange, Apple, Banana, Cherry, and Strawberry respectively.
  * V{{< sub >}}25{{< /sub >}} - V{{< sub >}}30{{< /sub >}} correspond to six road signs: Stop, Hospital, Speed Limit, One Way, Railroad Crossing, and Dead End respectively.
  * V{{< sub >}}30{{< /sub >}} - V{{< sub >}}36{{< /sub >}} correspond to six letters: H, O, L, M, E, and S respectively. This can be represented in a tabular format as follows:

|     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| R   | Bl  | Y   | G   | I   | Br  |     | R   | Bl  | Y   | G   | I   | Br  |     | R   | Bl  | Y   | G   | I   | Br  |     | R   | Bl  | Y   | G   | I   | Br  |     | R   | Bl  | Y   | G   | I   | Br  |     | R   | Bl  | Y   | G   | I   | Br  |
| N   | U   | E   | S   | J   | A   |     | N   | U   | E   | S   | J   | A   |     | N   | U   | E   | S   | J   | A   |     | N   | U   | E   | S   | J   | A   |     | N   | U   | E   | S   | J   | A   |     | N   | U   | E   | S   | J   | A   |
| 1   | 2   | 3   | 4   | 5   | 6   |     | 1   | 2   | 3   | 4   | 5   | 6   |     | 1   | 2   | 3   | 4   | 5   | 6   |     | 1   | 2   | 3   | 4   | 5   | 6   |     | 1   | 2   | 3   | 4   | 5   | 6   |     | 1   | 2   | 3   | 4   | 5   | 6   |
| P   | O   | A   | B   | C   | S   |     | P   | O   | A   | B   | C   | S   |     | P   | O   | A   | B   | C   | S   |     | P   | O   | A   | B   | C   | S   |     | P   | O   | A   | B   | C   | S   |     | P   | O   | A   | B   | C   | S   |
| St  | H   | Sl  | O   | R   | D   |     | St  | H   | Sl  | O   | R   | D   |     | St  | H   | Sl  | O   | R   | D   |     | St  | H   | Sl  | O   | R   | D   |     | St  | H   | Sl  | O   | R   | D   |     | St  | H   | Sl  | O   | R   | D   |
| H   | O   | L   | M   | E   | S   |     | H   | O   | L   | M   | E   | S   |     | H   | O   | L   | M   | E   | S   |     | H   | O   | L   | M   | E   | S   |     | H   | O   | L   | M   | E   | S   |     | H   | O   | L   | M   | E   | S   |
{.no-responsive-table, .no-zebra-table}

>**Sherlock Table**

All instances of the Sherlock have the following constraints:

* Each house is of a different colour,
* has a unique house number,
* and is inhabited by a single person,
* who has a favourite fruit,
* hates a particular road sign,
* and whose first name starts with a unique letter. In addition to these constraints each instance of the Sherlock problem has a subset of all valid constraints for the instance’s solution. The valid constraints for the Sherlock Problem are chosen from the set { V{{< sub >}}i{{< /sub >}} in-same-column-as V{{< sub >}}j{{< /sub >}}, V{{< sub >}}i{{< /sub >}} next-to V{{< sub >}}j{{< /sub >}}, V{{< sub >}}i{{< /sub >}} next-to-and-right-of V{{< sub >}}j{{< /sub >}}, V{{< sub >}}i{{< /sub >}} next-to-and-left-of V{{< sub >}}j{{< /sub >}}, V{{< sub >}}i{{< /sub >}} not-same-column-as V{{< sub >}}j{{< /sub >}}, V{{< sub >}}i{{< /sub >}} not-next-to V{{< sub >}}j{{< /sub >}}, V{{< sub >}}i{{< /sub >}} right-of V{{< sub >}}j{{< /sub >}}, V{{< sub >}}i{{< /sub >}} left-of V{{< sub >}}j{{< /sub >}}, V{{< sub >}}i{{< /sub >}} between V{{< sub >}}j{{< /sub >}} and V{{< sub >}}k{{< /sub >}} [^2], and V{{< sub >}}i{{< /sub >}} = known-column } [^3] where the constraint is true for a given i and j.

[^1]:  Note that all constraints are also present reversed (i.e. V{{< sub >}}i{{< /sub >}} next-to-and-right-of V{{< sub >}}j{{< /sub >}} requires that V{{< sub >}}j{{< /sub >}} next-to-and-left-of V{{< sub >}}i{{< /sub >}} also be in the set of constraints.)
[^2]:  For the sake of simplicity this is replaced with V{{< sub >}}i{{< /sub >}} next-to V{{< sub >}}j{{< /sub >}}, V{{< sub >}}i{{< /sub >}} next-to V{{< sub >}}k{{< /sub >}}, and V{{< sub >}}j{{< /sub >}} not-same-column-as V{{< sub >}}k{{< /sub >}}
[^3]:  Note that all constraints are also present reversed.
