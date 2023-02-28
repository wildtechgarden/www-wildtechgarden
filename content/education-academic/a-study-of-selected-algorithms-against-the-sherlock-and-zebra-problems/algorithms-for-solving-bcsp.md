---
slug: algorithms-for-solving-bcsp
aliases:
- /projects/old-school/undergraduate/a-study-of-selected-algorithms-against-the-sherlock-and-zebra-problems/algorithms-for-solving-bcsp/
- /projects/old-school/undergraduate/a-study-of-selected-algorithms-against-the-sherlock-and-zebra-problems/algorithms-for-solving-bcsp/
- /docs/education-academic/a-study-of-selected-algorithms-against-the-sherlock-and-zebra-problems/algorithms-for-solving-bcsp/
title: "Algorithms for solving Zebra and Sherlock"
author: Daniel F. Dickinson
tags:
- academic
- archived
- theory
date: '2021-03-02T13:34:12+00:00'
publishDate: '2003-02-09T10:25:00+00:00'
description: "This section contains pseudocode of the algorithms used in the paper as
well as a brief discussion of each algorithm."
summary: "This section contains pseudocode of the algorithms used in the paper as
well as a brief discussion of each algorithm."
toc: true
weight: 1100
---

## Preface

This section contains pseudocode of the algorithms used in the paper as
well as a brief discussion of each algorithm.

## Definitions for the Algorithms

These definition are based on the descriptions in [Prosser93] and
[Kondrak97].

* *v* An array of values such that v[i] is the value assigned to V{{< sub >}}i{{< /sub >}} in the binary constraint satisfaction problem.
* *n* The number of variables actually in the problem. v[1] is the first variable and the last variable is v[n].
* *domain* An array such that domain[i] is the domain of of i (D{{< sub >}}i{{< /sub >}} from the bcsp).
* *current-domain* An array such that current-domain[i] is the set of values in D{{< sub >}}i{{< /sub >}} which has not yet been shown to be inconsistent in the current search process. current-domain[i] is initialized to domain[i].
* *C* An n x n array such that C[i,j] contains the set of constraints between V{{< sub >}}i{{< /sub >}} and V{{< sub >}}j{{< /sub >}} in the bcsp. It corresponds to C{{< sub >}}i,j{{< /sub >}} in the bcsp.
* *check(i,j)* A function that returns true if the constraint between V{{< sub >}}i{{< /sub >}} and V{{< sub >}}j{{< /sub >}} is satisfied. (If there is no constraint between i and j then constraint is considered to be satisfied). Each call to check(i,j) is considered a consistency check for the measurements elsewhere in this paper.
* *mcl* An n x m (where m is the maximum domain size) array which holds the deepest variable that the instantiation v[i] = k was checked against (that is, mcl[i,k] = h was assigned when check(i,h) was performed)
* *mbl* In BM-CBJ an array of size n which holds the shallowest past variable that changed value since v[i] was the current variable. In BM-CBJ2 mbl is an n x m array in which mbl[i,j] holds the shallowest past variable that has changed value since v[i] last held the jth value in it’s domain.
* *conf-set* An array of size n such that conf-set[i] holds the subset of of the past variables in conflict (failed consistency checks) with V{{< sub >}}i{{< /sub >}}.
* *row-permutes* A set containing all possible permutations of a row. The size of the set should be |D{{< sub >}}r{{< /sub >}}|! where D{{< sub >}}r{{< /sub >}} is the domain of any variable in the row (the domain should be identical for each item in a row).

### Achieving Arc Consistency: AC-3

An algorithm used extensively in preparing in this paper is AC-3, as
presented by Kumar in [Kumar92]. This algorithm eliminates values from
the domains of a given variable which cannot work based on the
constraints and domains of the rest of the variables. The resulting
constraint network is said to be [arc consistent](definitions-for-zebra-and-sherlock/#general-definitions) for all arcs
(constraints).

The algorithm achieves arc consistency for all arcs by eliminating the
values from the domain of a given variable which cannot be made
consistent with the rest of the variables. That is, for each x €
D{{< sub >}}i{{< /sub >}}, if there is no y € D{{< sub >}}j{{< /sub >}} such that
C{{< sub >}}i,j{{< /sub >}} is true, x is removed from D{{< sub >}}i{{< /sub >}}.

Procedure REVISE makes a given arc arc-consistent with the current set
of constraints. Procedure AC-3 executes REVISE for every arc in the
constraint problem. Note that it is not sufficient to execute REVISE
once for each arc as eliminating an arc affects the validity of other
arcs. AC-3 reruns REVISE only for those arcs possibly affected by the
elimination of a given arc.

#### procedure AC-3

``` JavaScript
begin AC-3;
	G := { All (i,j) such that Ci,j is not null }
	Q := { All (Vi, Vj) such that (i, j) € G, i ≠ j }

	while Q not empty
		select and delete any arc (Vk, Vm) from Q;
		if (REVISE(Vk, Vm) then
			Q = Q union { (Vi, Vk) such that (i, k) € G, i ≠ k, i ≠ m) };
		end if;
	end while;
	end AC-3;
```

#### procedure REVISE

`REVISE(V{{< sub >}}i{{< /sub >}}, V{{< sub >}}j{{< /sub >}})`

``` JavaScript
begin REVISE(Vi, Vj)
	DELETE = false;
	for each x is an element of Di do
		if there is no such vj €; Dj such that (x, vj) is consistent,
		then
			delete x from Di;
			DELETE = true;
		end if;
	end for;
	return DELETE;
end REVISE;
```

### Backmarking with Conflict-Directed Backjumping 2: BM-CBJ2

BM-CBJ2 is a modification of the algorithm in [Prosser93] based on
information in [Kondrak97] and [Kondrak94]. It is a backtracking
algorithm which keeps track of conflicts between variables and, when the
current variable cannot be made consistent with a prior variable, jumps
(skips multiple nodes rather than simply backtracking) back until a
consistent node is reached. The algorithm also keeps track of successful
and unsuccessful instantiations of a given variable with other variables
and, when possible, uses this information to skip re-checking for
consistency.

The original algorithm, BM-CBJ, as it appears in [Prosser93], is
presented below. Note that it consists of three functions: bcssp,
bm-cbj-label, and bm-cbj-unlabel. Prosser used this format for
conceptual clarity. It is easier to see the backtracking actions in this
format than in a recursive function.

#### BM-CBJ

``` JavaScript
1 PROCEDURE bcssp (n, status)
2 BEGIN
3	consistent = true;
4	status = "unknown";
5	i = 1;
6		WHILE status = "unknown"
7		DO BEGIN
8			IF consistent
9			THEN i = label(i,consistent)
10			ELSE i = unlabel(i,consistent);
11			IF i > n
12			THEN status = "solution"
13			ELSE IF i = 0
14			THEN status = "impossible"
15		END
16 END;
```

Note label and unlabel in lines 9 and 10 are replaced by bm-cbj-label
and bm-cbj-unlabel (which are presented below).

``` JavaScript
 1 FUNCTION bm-cbj-label (i,consistent): INTEGER
 2 BEGIN
 3	consistent = false;
 4	FOR K = EACH ELEMENT OF current-domain[i] WHILE not consistent
 5	DO BEGIN
 6		consistent = mcl[i,k] ≥ mbl[j];
 7		FOR h = mbl[i] TO i - 1 WHILE consistent
 8		DO BEGIN
 9			v[i] = k;
10			consistent = check(i, h);
11			mcl[i,k] = h
12		END;
13		If not consistent
14		THEN BEGIN
15			pushnew(mcl[i,k],conf-set[i]);
16			current-domain[i] = remove(v[i],current-domain[i])
17		END
18	END;
19	IF consistent THEN return(i+1) ELSE return(i)
20 END;
```

```JavaScript
  1 FUNCTION bm-cbj-unlabel(i,consistent): INTEGER
  2 BEGIN
  3	h = max-list(conf-set[i]);
  4	conf-set[h] = remove(h,union(conf-set[h],conf-set[i]));
4.1	mbl[i] = h;
4.2	FOR j = h + 1 TO n DO mbl[j] = min(mbl[j],h);
  5	FOR j = h + 1 TO i
  6	DO BEGIN
  7		conf-set[j] = {0}
  8		current-domain[j] = domain[j];
  9	END;
 10	current-domain[h] = remove(v[h],current-domain[h]);
 11	consistent = current-domain[h] ≠ nil;
 12	return(h)
 13 END;
```

The modified algorithm, BM-CBJ2 is presented below. It has been changed
from BM-CBJ as follows: Lines 9 and 10 of bcssp are modified to used
bm-cbj2-label and bm-cbj2-unlabel instead of bm-cbj-label and
bm-cbj-unlabel, in bm-cbj2-label lines 6, and 7 have been modified to
use mbl\[i]\[k] instead of mbl\[i], line 9 has been moved to 6.1,
line 6.2 has been added, line 4.1 has been deleted, and in
bm-cbj2-unlabel line 4.2 has been replaced with lines 4.2.1 - 4.2.7.

The purpose of these changes is to correct a deficiency in BM-CBJ.
BM-CBJ fails to account for the fact that backjumping means that not all
values in the domain of a variable are tested (since backjumping occurs
immediately when a conflict is found) and therefore redundant checks are
performed. To correct this the mbl array needs to maintain a separate
record of the shallowest variable whose value has changed since
x{{< sub >}}i{{< /sub >}} was last instantiated with that value, for each
variable-value pair. This is achieved by making mbl a two-dimensional
array and recording instantiation points at bm-cbj2-label 6.2 instead of
in bm-cbj2-unlabel (at 4.1).

The need for these changes and a general description of the changes
required can be found in \[Kondrak97], however there is no example in
that paper. Code for a similar change to BMJ (backmarking with
backjumping) can be found in \[Kondrak94] and was invaluable in making
the changes described in this paper.

#### BM-CBJ2

```JavaScript
 1 PROCEDURE bcssp (n, status)
 2 BEGIN
 3	consistent = true;
 4	status = "unknown";
 5	i = 1;
 6	WHILE status = "unknown"
 7	DO BEGIN
 8		IF consistent
 9		THEN i = bm-cbj2-label(i,consistent)
10		ELSE i = bm-cbj2-unlabel(i,consistent);
11		IF i > n
12		THEN status = "solution"
13		ELSE IF i = 0
14		THEN status = "impossible"
15		END
16 END;
```

```JavaScript
  1 FUNCTION bm-cbj2-label (i,consistent): INTEGER
  2 BEGIN
  3	consistent = false;
  4	FOR K = EACH ELEMENT OF current-domain[i] WHILE not consistent
  5	DO BEGIN
  6		consistent = mcl[i,k] ≥ mbl[j][k];
 6.1		v[i] = k;
 6.2		mbl[i][k] = i;
   7		FOR h = mbl[i][k] TO i - 1 WHILE consistent
   8		DO BEGIN
  10			consistent = check(i, h);
  11			mcl[i,k] = h
  12	END;
  13	IF not consistent
  14	THEN DO BEGIN
14.1		pushnew(mcl[i,k],conf-set[i]);
14.2		current-domain[i] = remove(v[i],current-domain[i])
14.3	END
  15	END;
16    IF consistent THEN return(i+1) ELSE return(i)
17 END;
```

```JavaScript
     1 FUNCTION bm-cbj2-unlabel(i,consistent): INTEGER
     2 BEGIN
     3	h = max-list(conf-set[i]);
     4	conf-set[h] = remove(h,union(conf-set[h],conf-set[i]));
 4.2.1	FOR j = h + 1 TO n
 4.2.2	DO BEGIN
 4.2.3		FOR 0 to m
 4.2.4		DO BEGIN
 4.2.5			mbl[j][m] = min(mbl[j][m],h);
 4.2.6		END
 4.2.7	END
     5	FOR j = h + 1 TO i
     6	DO BEGIN
     7		conf-set[j] = {0}
     8		current-domain[j] = domain[j];
     9	END;
    10	current-domain[h] = remove(v[h],current-domain[h]);
    11	consistent = current-domain[h] ≠ nil;
    12	return(h)
    13 END;
```

## Genetic Algorithms

### Summary

This section describes the three genetic algorithms designed by this
author to solve the Zebra and Sherlock problems for Assignment #3 for
CIS*4750 at the University of Guelph. The first algorithm uses only
mutation and is called, aptly enough, Mutate, the second algorithm uses
crossover with mutation and is called Xover, while the third algorithm
uses double crossover and is called DoubleX.

### Definitions for Genetic Algorithms

* *Genetic Algorithm* A genetic algorithm is paradigm modelled after evolutionary processes. A ‘population’ of possible solutions is generated and evaluated for fitness. A partially-random selection of solutions is then taken (possibly multiple times, with the ‘most fit’ algorithms being used most often) and from that selection new solutions are generated and evaluated. This process is repeated until a solution which meets some terminal criterion is found.
* *Mutation* In the context of genetic algorithms mutations refers to a random change in some part of the individual (solution) such that a new individual (solution) is created.
* *Crossover* Crossover occurs during reproduction involving two parents. Some random point is selected up to which one parent’s ‘genetic’ information is is used and after which the other parent’s information is used.
* *Death* In a genetic algorithm death occurs when the individual is removed from the population (e.g. in a fixed size array with the least fit on the bottom, children replace the least fit individual which can be said to have died).
* *calculate-distance-from-consistent* This is the heuristic used to calculate fitness in the genetic algorithms discussed in this paper. When a solution violates a constraint, the number of columns one of the variables would have to move to be consistent is calculated (e.g. if there is a constraint that says the coffee is next to the zebra, but the coffee is in the same column as the zebra a distance of one is calculated).
* *fitness* An attempt measure of how close the solution is to a solution. In the following algorithms a higher number for fitness is worse and a lower value is better.
* *chromosone* For this paper chromosone is an array of size n whose contents correspond to the value of the variables in the constraint problem to be solved.

### Mutate

This is a simple algorithm that does asexual reproduction. A selection
of the best fit, as well as a small number of the ‘least fit but not
dying’, individuals are copied and then mutated to create children. The
random selection of ‘least fit but not dying’ individuals is done to
help prevent the algorithm from getting ‘stuck’ on a local minimum by
boosting the probability a diverse population will exist. Experience
gathered while watching the debug output during development reveals that
this, unfortunately, has had limited success and that the mutation-only
algorithm still tends to land a local minimum, and has poor chances of
getting out.

The pseudocode for the algorithm is outlined below.

```JavaScript
  1 PROCEDURE Mutate()
  2	FOR 1 TO max_population
  3	DO BEGIN
  4		select a solution from the set of possible solutions
  5	END FOR
  6	evaluate-fitness()
  7	fitness-sort()
  8	WHILE best-solution-is-not-the-solution()
  9	DO BEGIN
 10		select-fit-individuals()
 11		reproduce()
 12		evaluate-fitness()
 13		fitness-sort()
 14	END WHILE
 15	output-solution()
 16 END PROCEDURE

  1 PROCEDURE evaluate-fitness()
  2	FOR EACH variable i
  3	DO BEGIN
  4		IF domain[i] does not contain v[i]
  5		THEN BEGIN
  6			fitness += 200
  7		END IF
  8	END FOR
  9	FOR EACH constraint
 10	DO BEGIN
 11		IF constraint ≠ "not-equal"
 12		THEN fitness += calculate-distance-to-consistent
 13		ELSE
 14			DO BEGIN
 15				fitness += 25
 16			END IF
 17		END FOR
 18 END evaluate-fitness

  1 PROCEDURE fitness-sort
  2	place lowest fitness in population[0], next in population[1], etc.
  3 END fitness-sort

  1 PROCEDURE select-fit-individuals
  2	calculate-relative-probability()
  3	FOR 0 to (num-children - num-poor-fit)
  4	DO BEGIN
  5		add population[get-parent()] to parents
  6	END FOR
  7	FOR 0 to (num-poor-fit)
  8	DO BEGIN
  9		add population[get-poor-parent()] to parents
 10	END FOR
 11 END select-fit-individuals

  1 PROCEDURE calculate-relative-probability
  2	total-times-better = 0
  3	FOR i = 0 TO population-size - num-to-die
  4	DO BEGIN
  5		times-better[i] = (max-fitness + 1 - population[i].fitness)
  6		total-times-better += times-better[i]
  7	END FOR
  8	x = 1 ÷ totalTimesBetter
  9	FOR i = 0 TO times-better.size
 10	DO BEGIN
 11		cancel-reproducing = times-better[i] × x
 12	END FOR
 13 END calculate-relative-probability

  1 PROCEDURE get-parent()
  2	parent = first accumulated-chance-reproducing > random number between 0 and 1
  3 END get-parent

  1 PROCEDURE get-poor-parent()
  2	parent = first (1 - accumulated-chance-reproducing) > random number between 0 and 1
  3 END get-parent

  1 PROCEDURE reproduce()
  2	FOR i = 1 to num-parents
  3	DO BEGIN
  4		child = parents[i]
  5		FOR j = 1 TO n
  6		DO BEGIN
  7			IF (random number between 0 and 1 < mutation-probability)
  8			THEN BEGIN
  9				child.chromosone[j] = random number between 1 and max-domain
 10			END IF
 11		END FOR
 12		population[max-population - num-children + i] = child
 13	END FOR
 14 END reproduce
```

### Xover

This genetic algorithm replaces the asexual reproduction of Mutate with
a two parent reproduction scheme using a combination of crossover and a
chance of mutation of the result of the parent’s combined contributions.

Xover() is identical to Mutate(), except the name while select() and
reproduce() have been modified to use two parents and crossover.

Xover proves to be much more robust than Mutate, solving problems much
more quickly and usually being able to solve the problem in a somewhat
reasonable time-frame, rather than getting stuck on a local minimum and
only getting out after an unlikely mutation.

```JavaScript
  1 PROCEDURE select-fit-individuals
  2	calculate-relative-probability()
  3	FOR 0 to (num-children ÷ 2)
  4	DO BEGIN
  5		parent-num = get-parent()
  6		add population[parent-num] to parents
  7		add population[population-size - num-children - parent-num] to parents
  8	END FOR
  9	IF (parents.size < num-children + 1)
 10	THEN BEGIN
 11		add population[get-parent()]
 12	END IF
 13 END select-fit-individuals

  1 PROCEDURE reproduce()
  2	FOR i = 1 to (num-parents - 1) STEP 2
  3	DO BEGIN
  4		k = random number between 1 and n
  5		FOR j = 1 to k
  6		DO BEGIN
  7			child1.chromosone[j] = parents[i].chromosone[j]
  8			child2.chromosone[j] = parents[i + 1].chromosone[j]
  9		END FOR
 10		FOR j = k to n
 11		DO BEGIN
 12			child1.chromosone[j] = parents[i + 1].chromosone[j]
 13			child2.chromosone[j] = parents[i].chromosone[j]
 14		END FOR
 15		FOR j = 1 TO n
 16		DO BEGIN
 17			IF (random number between 0 and 1 < mutation-probability)
 18			THEN BEGIN
 19				child1.chromosone[j] = random number between 1 and max-domain
 20				child2.chromosone[j] = random number between 1 and max-domain
 21			END IF
 22		END FOR
 23		population[max-population - num-children + i] = child1;
 24		population[max-population - num-children + i + 1] = child2;
 25	END FOR
 26 END reproduce
```

### DoubleX

This is a variation on Xover which uses two crossover points instead of
only one. The only change to the algorithm from Xover is in the
reproduce() function in which the second crossover point is added (lines
4.1, and 9.1-9.5 are added while lines 9 and 10 are modified). DoubleX()
is exactly same as Xover() except the name.

DoubleX does not seem to be much different than Xover, and in fact may
experience decreased performance. Unfortunately, due to run times
required to test this question it has not been answered for this paper.

```JavaScript
   1 PROCEDURE reproduce()
   2	FOR i = 1 to (num-parents - 1) STEP 2
   3	DO BEGIN
   4		k = random number between 1 and n
 4.1		l = random number between k + 1 and n
   5		FOR j = 1 to k
   6		DO BEGIN
   7			child1 = parents[i].chromosone[j]
   8			child2 = parents[i + 1].chromosone[j]
   9		END FOR
 9.1		FOR j = k to l
 9.2		DO BEGIN
 9.3			child1 = parents[i + 1].chromosone[j]
 9.4			child2 = parents[i].chromosone[j]
 9.5		END FOR
  10		FOR j = l to n
  11		DO BEGIN
  12			child1 = parents[i + 1].chromosone[j]
  13			child2 = parents[i].chromosone[j]
  14		END FOR
  15		FOR j = 1 TO n
  16		DO BEGIN
  17			IF (random number between 0 and 1 < mutation-probability)
  18			THEN BEGIN
  19				child1.chromosone[j] = random number between 1 and max-domain
  20				child2.chromosone[j] = random number between 1 and max-domain
  21			END IF
  22		END FOR
  23		population[max-population - num-children + i] = child1;
  24		population[max-population - num-children + i + 1] = child2;
  25	END FOR
  26 END reproduce
```
