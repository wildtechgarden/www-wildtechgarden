---
slug: bibliography-and-appendices
aliases:
- /projects/old-school/undergraduate/a-study-of-selected-algorithms-against-the-sherlock-and-zebra-problems/bibliography-and-appendices/
- /docs/education-academic/a-study-of-selected-algorithms-against-the-sherlock-and-zebra-problems/bibliography-and-appendices/
title: "Bibliography and Appendices"
author: Daniel F. Dickinson
tags:
- academic
- archived
- theory
date: '2021-03-02T13:34:12+00:00'
publishDate: '2003-02-09T10:25:00+00:00'
description: "Bibliography and appendices for selected algorithms against the Zebra and Sherlock problems"
summary: "Bibliography and appendices for selected algorithms against the Zebra and Sherlock problems"
toc: true
weight: 1400
---

## Bibliography

[Kondrak94] Kondrak Grzegorz "A Theoretical Evaluation of Selected
Backtracking Algorithms." _Technical Report TR94-10, University of Alberta_
Fall 1994.

[Kondrak97] Kondrak Grzegorz van Beek Peter "A Theoretical Evaluation
of Selected Backtracking Algorithms." _Artificial Intelligence 89_:
365-387, 1997.

[Kumar92] Kumar Vipin "Algorithms for Constraint Satisfaction Problems:
A Survey." _AI Magazine_ Vol 13, Issue 1: 32-44, 1992.

[Prosser93] Prosser Patrick "Hybrid Algorithms for the Constraint
Satisfaction Problem" _Computational Intelligence_ Vol 9, Number 3:
268-299, 1993.

## Appendices

### Sample Sherlock Problem

This is a problem for which arc consistency is insufficient to solve the
problem.

{{< highlight Javascript >}}
S
2 is 1
9 is 1
11 is 2
17 is 2
20 is 3
21 is 2
22 is 4
24 is 5
27 is 6
28 is 5
1 not-next-same 2
1 not-equal 2
1 not-equal 3
1 not-equal 4
1 not-equal 5
1 not-equal 6
1 not-next-to 14
1 not-same-col 26
1 same-col 33
2 not-next-same 1
2 not-equal 1
2 not-equal 3
2 not-equal 4
2 not-equal 5
2 not-equal 6
2 left-of 13
2 left-of 25
2 not-next-to 35
3 not-equal 1
3 not-equal 2
3 left-of 4
3 not-equal 4
3 not-equal 5
3 not-equal 6
3 next-right 30
3 not-next-same 36
4 not-equal 1
4 not-equal 2
4 right-of 3
4 not-equal 3
4 not-equal 5
4 not-equal 6
4 not-same-col 19
4 not-same-col 20
4 not-next-to 25
4 right-of 30
5 not-equal 1
5 not-equal 2
5 not-equal 3
5 not-equal 4
5 not-equal 6
5 not-same-col 14
5 not-next-same 25
5 not-same-col 33
5 next-to 34
6 not-equal 1
6 not-equal 2
6 not-equal 3
6 not-equal 4
6 not-equal 5
6 not-next-to 17
6 not-next-to 24
6 not-same-col 29
7 not-equal 8
7 not-equal 9
7 not-equal 10
7 not-equal 11
7 not-equal 12
7 not-next-to 15
7 left-of 22
7 left-of 28
7 left-of 35
8 not-equal 7
8 not-equal 9
8 not-equal 10
8 not-equal 11
8 not-equal 12
8 not-same-col 17
8 not-next-same 22
8 not-same-col 33
9 not-equal 7
9 not-equal 8
9 not-equal 10
9 not-equal 11
9 not-equal 12
9 not-same-col 21
10 not-equal 7
10 not-equal 8
10 not-equal 9
10 not-equal 11
10 not-equal 12
10 not-same-col 32
10 not-next-to 34
10 same-col 34
11 not-equal 7
11 not-equal 8
11 not-equal 9
11 not-equal 10
11 not-equal 12
11 not-next-same 15
11 next-to 33
12 not-equal 7
12 not-equal 8
12 not-equal 9
12 not-equal 10
12 not-equal 11
12 next-right 16
12 not-same-col 23
13 right-of 2
13 next-left 14
13 not-equal 14
13 not-equal 15
13 not-equal 16
13 not-equal 17
13 not-equal 18
13 not-next-same 25
13 not-same-col 30
13 not-next-to 31
13 not-next-to 36
14 not-next-to 1
14 not-same-col 5
14 next-right 13
14 not-equal 13
14 not-equal 15
14 not-equal 16
14 not-equal 17
14 not-equal 18
15 not-next-to 7
15 not-next-same 11
15 not-equal 13
15 not-equal 14
15 not-equal 16
15 not-equal 17
15 not-equal 18
15 not-next-same 20
15 right-of 25
15 not-same-col 36
16 next-left 12
16 not-equal 13
16 not-equal 14
16 not-equal 15
16 not-equal 17
16 not-equal 18
16 not-same-col 31
16 not-next-same 34
16 next-to 35
16 next-left 35
17 not-next-to 6
17 not-same-col 8
17 not-equal 13
17 not-equal 14
17 not-equal 15
17 not-equal 16
17 not-equal 18
17 not-next-to 21
17 not-same-col 24
17 not-next-same 26
18 not-equal 13
18 not-equal 14
18 not-equal 15
18 not-equal 16
18 not-equal 17
18 next-left 21
18 not-next-same 22
19 not-same-col 4
19 right-of 20
19 not-next-same 20
19 not-equal 20
19 not-equal 21
19 not-equal 22
19 not-equal 23
19 not-equal 24
19 not-same-col 29
20 not-same-col 4
20 not-next-same 15
20 left-of 19
20 not-next-same 19
20 not-equal 19
20 not-equal 21
20 not-equal 22
20 not-next-same 23
20 not-equal 23
20 left-of 24
20 not-equal 24
20 not-next-same 32
20 not-next-to 36
21 not-same-col 9
21 not-next-to 17
21 next-right 18
21 not-equal 19
21 not-equal 20
21 not-equal 22
21 not-equal 23
21 not-equal 24
21 not-next-to 27
22 right-of 7
22 not-next-same 8
22 not-next-same 18
22 not-equal 19
22 not-equal 20
22 not-equal 21
22 not-equal 23
22 not-equal 24
22 not-next-same 27
23 not-same-col 12
23 not-equal 19
23 not-next-same 20
23 not-equal 20
23 not-equal 21
23 not-equal 22
23 not-equal 24
23 not-next-same 33
24 not-next-to 6
24 not-same-col 17
24 not-equal 19
24 right-of 20
24 not-equal 20
24 not-equal 21
24 not-equal 22
24 not-equal 23
24 not-same-col 29
25 right-of 2
25 not-next-to 4
25 not-next-same 5
25 not-next-same 13
25 left-of 15
25 not-equal 26
25 not-equal 27
25 not-equal 28
25 not-equal 29
25 not-equal 30
25 not-next-to 31
26 not-same-col 1
26 not-next-same 17
26 not-equal 25
26 not-equal 27
26 not-equal 28
26 not-equal 29
26 not-equal 30
26 next-to 33
27 not-next-to 21
27 not-next-same 22
27 not-equal 25
27 not-equal 26
27 not-equal 28
27 not-equal 29
27 not-equal 30
28 right-of 7
28 not-equal 25
28 not-equal 26
28 not-equal 27
28 not-equal 29
28 not-equal 30
28 same-col 34
29 not-same-col 6
29 not-same-col 19
29 not-same-col 24
29 not-equal 25
29 not-equal 26
29 not-equal 27
29 not-equal 28
29 not-equal 30
30 next-left 3
30 left-of 4
30 not-same-col 13
30 not-equal 25
30 not-equal 26
30 not-equal 27
30 not-equal 28
30 not-equal 29
30 left-of 35
31 not-next-to 13
31 not-same-col 16
31 not-next-to 25
31 not-equal 32
31 not-equal 33
31 not-equal 34
31 not-equal 35
31 not-equal 36
32 not-same-col 10
32 not-next-same 20
32 not-equal 31
32 not-equal 33
32 not-equal 34
32 not-equal 35
32 not-equal 36
33 same-col 1
33 not-same-col 5
33 not-same-col 8
33 next-to 11
33 not-next-same 23
33 next-to 26
33 not-equal 31
33 not-equal 32
33 not-equal 34
33 not-equal 35
33 not-equal 36
34 next-to 5
34 not-next-to 10
34 same-col 10
34 not-next-same 16
34 same-col 28
34 not-equal 31
34 not-equal 32
34 not-equal 33
34 not-equal 35
34 not-equal 36
35 not-next-to 2
35 right-of 7
35 next-to 16
35 next-right 16
35 right-of 30
35 not-equal 31
35 not-equal 32
35 not-equal 33
35 not-equal 34
35 not-same-col 36
35 not-next-same 36
35 not-equal 36
36 not-next-same 3
36 not-next-to 13
36 not-same-col 15
36 not-next-to 20
36 not-equal 31
36 not-equal 32
36 not-equal 33
36 not-equal 34
36 not-same-col 35
36 not-next-same 35
36 not-equal 35
{{< /highlight >}}

### Source Code

If you wish you can download the source code for [selected algorithms against the Sherlock and Zebra problems and related programs](../../../assets/files/cis4750-web.zip).
