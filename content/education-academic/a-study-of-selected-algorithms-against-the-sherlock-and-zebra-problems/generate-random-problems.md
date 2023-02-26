---
slug: generate-random-problems
aliases:
- /projects/old-school/undergraduate/a-study-of-selected-algorithms-against-the-sherlock-and-zebra-problems/generate-random-problems/
- /education-academic/a-study-of-selected-algorithms-against-the-sherlock-and-zebra-problems/generate-random-problems/
title: "Generate random problems"
author: Daniel F. Dickinson
tags:
- academic
- archived
- theory
date: '2021-03-02T13:34:12+00:00'
publishDate: '2003-02-09T10:25:00+00:00'
description: "This section outlines the algorithms used to generate the problems the
various solving algorithms were tested against."
summary: "This section outlines the algorithms used to generate the problems the
various solving algorithms were tested against."
toc: true
weight: 1200
---

## Preface

This section outlines the algorithms used to generate the problems the
various algorithms were tested against.

* *known-vars* A set containing the variables for which a constraint involving them has been generated.

### Generate Strongly K-consistent Problems

This algorithm starts by generating a random solution. It then begins
with two ‘anchor’ points (that is two variables whose domain has been
set to the solution) which are added to the known-vars set (which starts
empty). The algorithm then randomly picks a type of constraint (clue) to
use (the clues have different probabilities of being picked), and for
each known variable to unknown variable (the set of which is represented
as ~known-vars below) combination checks if the clue vx constraint vy
is a valid statement for the previously generated random solution. If
the clue is valid then it is added to possible-clues. If, after checking
all known-var/unknown-var combinations, there are no possible clues the
algorithm tries unknown only, and failing that known only.

Once the possible clues have been generated one of the possible clues is
randomly picked for addition to the problem set. The process of picking
a constraint and generating possible solution continues until AC-3 is
able to solve the problem.

``` JavaScript {linenos=inline}
PROCEDURE GenerateStrongKProblem()
BEGIN
	row-permutations = generate-row-permutations()
	solution = generate-random-solution()
	x1 = random number between 1 and n
	x2 = random number between 1 and n, x2 ≠ x1
	set domain[x1] = v[x1]
	set domain[x2] = v[x2]
	add x1 and x2 to known-vars
	given[x1] = v[x1]
	given[x2] = v[x2]
	WHILE ~has-one-solution()
	DO BEGIN
		clue = random constraint-type
		FOR EACH vx IN known-vars
		DO BEGIN
			FOR EACH vy IN ~known-vars
			DO BEGIN
				IF check(vx, vy, clue)
				THEN BEGIN
					 add (vx, vy) to possible-clues
				END IF
			END FOR
			IF possible-clues is empty
			THEN BEGIN
				FOR EACH vx IN ~known-vars
				DO BEGIN
					FOR EACH vy IN ~known-vars, vy ≠ vx
					DO BEGIN
						IF check(vx, vy, clue)
						THEN BEGIN
							add (vx, vy) to possible-clues
						END IF
					 END FOR
				END FOR
			END IF
			IF possible-clues is empty
			THEN BEGIN
				FOR EACH vx IN known-vars
				DO BEGIN
					FOR EACH vy IN known-vars, vy ≠ vx
					DO BEGIN
							IF check(vx, vy, clue)
							THEN BEGIN
								add (vx, vy) to possible-clues
							END IF
					END FOR
				 END FOR
			END IF
		END FOR
		new-constraint = choose a random arc from possible-clues
		IF (clue == GIVEN)
		THEN BEGIN
			 given[new-constraint.j] = v[new-constraint.j]
		ELSE
		BEGIN
			constraints[new-constraint.i][new-constraint.j] = clue
			constraints[new-constraint.j][new-constraint.i] = reverse(clue)
		END IF
	END WHILE
	output-new-problem()
END
```

``` JavaScript {lineno=table}
PROCEDURE generate-random-solution()
BEGIN
FOR i = 0 TO max-rows - 1
	DO BEGIN
		choose random row from row-permutations
		FOR j = 0 TO row.size - 1
		DO BEGIN
			v[i * max-rows + j + 1] = row[j]
		END FOR
	END FOR
END
```

``` JavaScript {linenos=inline}
PROCEDURE has-one-solution()
BEGIN
	AC-3()
	done = TRUE
	FOR i = 1 TO n
	DO BEGIN
		IF domain[i].size > 1
		THEN BEGIN
			done = FALSE
		END IF
	END FOR
	return done
END
```

### Generate ‘Totally Random’ Problems

This algorithm picks random clues from the set of all clues until a
modified form of CBJ (conflict directed backjumping) indicates that
there is at most one solution. CBJ was chosen for modification because
the process of modifying it was relatively straightforward whereas
trying to change BM-CBJ2 would have been more difficult (because of the
backmarking).

#### CBJ-Multi

This algorithm is a modified version of CBJ whichhas been modified from
the presentation in \[Prosser93] so that it detects if there is more
than one solution. It accomplishes this by adding an array cbf of size n
which is initialized to false and indicates when the conflict set
(conf-set) for a given variable no longer means that the reason for the
conflict is an invalid instantiation but rather that a solution was
found. In such a case a single step back is the desired action rather
than the backjumping behaviour normally used by this algorithm.

In bcssp the following changes have been made: 4.1 has been added, 12
has been modified, 12.1-12.8 have been added, and 13.1-13.3 have been
added. cbj-label remains the same as in \[Prosser93] while cbj-unlabel
is modified in the following fashion: 2.1-2.3 have been added with 3 and
4 being placed inside the else of 2.3. Also 8.1 and 11.1 have been
added.

``` javascript
   1 PROCEDURE bcssp (n, status)
   2 BEGIN
   3	consistent = true;
   4	status = "unknown";
 4.1	prev-status = "unknown";
   5	i = 1;
   6	WHILE status = "unknown"
   7	DO BEGIN
   8		IF consistent
   9		THEN i = label(i,consistent)
  10		ELSE i = unlabel(i,consistent);
  11		IF i > n
  12		THEN IF prev-status = "unknown"
12.1		THEN prev-status = "solution"
12.2			FOR j = 0 TO n
12.3			DO BEGIN
 2.4				cbf[j] = true
12.5			END FOR
12.6			i = n
12.7		ELSE IF prev-status = "solution"
12.8			THEN status = "more-than-one-solution"
  13			ELSE IF i = 0
13.1			THEN IF prev-status = "solution"
13.2					status = "solution"
13.3				ELSE
  14					status = "impossible"
  15			END IF
  16		END IF
  17	END;

   1 FUNCTION cbj-unlabel (i,consistent): INTEGER
   2 BEGIN
 2.1	IF cbf[i]
 2.2	THEN h = i - 1
 2.3	ELSE
   3		h = max-list(conf-set[i])
   4		conf-set[h] = remove(h,union(conf-set[h],conf-set[i]));
   5		FOR j = h + 1 TO i
   6		DO BEGIN
   7			conf-set[i] = {0};
   8			current-domain[j] = domain[j]
 8.1			cbf[j] = false
   9		END;
  10		current-domain[h] = remove(v[h],current-domain[h]);
  11		consistent = current-domain[h] ≠ nil;
11.1		cbf[j] = false
  12		return(h)
  13	END
  14 END;
```

``` JavaScript {linenos=inline}
FUNCTION cbj-label(i,consistent): INTEGER
BEGIN
	consistent = false;
	FOR v[i] = EACH ELEMENT OF current-domain[i] WHILE not consistent
	DO BEGIN
		consistent = true;
		FOR h = 1 TO i - 1 WHILE consistent
		DO consistent = check(i,h);
		IF not consistent
		THEN BEGIN
			pushnew(h - 1,conf-set[i]);
			current-domain[i] = remove(v[i],current-domain[i])
		END
	END;
	IF consistent THEN return(i+1) ELSE return(i)
END;
```

#### GenerateRandomProblem

``` javascript {linenos=inline}
PROCEDURE GenerateStrongKProblem()
BEGIN
	row-permutations = generate-row-permutations()
	solution = generate-random-solution()
	possible-clues = find-possible-clues()
	WHILE (!has-one-possible-solution())
	DO BEGIN
		new-clue = pick random clue from possible-clues
		IF new-clue.type == GIVEN
		THEN BEGIN
			given[new-clue.j] = v[new-clue.j]
			add v[new-clue.j] to domain[new-clue.j]
		ELSE
		BEGIN
			constraints[new-clue.i][new-clue.j].add(new-clue.type)
			constraints[new-clue.j][new-clue.i].add(reverse(new-clue.type))
		END IF
	END WHILE
END GenerateStrongKProblem
```

``` javascript {linenos=inline}
PROCEDURE has-one-possible-solution()
BEGIN
	result = bcssp(n)
	IF (result = "solution")
	THEN RETURN true
	ELSE IF (result = "no solution")
		THEN ERROR-EXIT("No solution possible.")
	END IF
	RETURN false
END
```

``` javascript {linenos=inline}
PROCEDURE find-possible-clues()
BEGIN
	FOR vx = TO n
	DO BEGIN
		FOR vy = to n, vy ≠ vx
		DO BEGIN
			FOR EACH clue IN allowed-relations
			DO BEGIN
				IF check(vx, vy, clue)
				THEN BEGIN
					add (vx, clue, vy) to possible-clues
				END IF
			END FOR
		END FOR
	END FOR
END find-possible-clues
```
