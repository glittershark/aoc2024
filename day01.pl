% -*- mode: prolog -*-

:- use_module(utils).
:- use_module(library(readutil)).
:- use_module(library(clpfd)).
:- use_module(library(yall)).
:- use_module(library(assoc)).

%%%

read_input(File, L1 - L2) :-
    open(File, read, Stream),
    read_lines(Stream, Lines),
    maplist(
        [L, Ns]>> (
          split_string(L, " ", "", Ss),
          exclude([""] >> true, Ss, Ss1),
          maplist(number_codes, Ns, Ss1)
        ),
        Lines,
        Num_pairs
    ),
    transpose(Num_pairs, [L1, L2]).

%%%

total_dist_sorted([] - [], 0).
total_dist_sorted([X | Xs] - [Y | Ys], Dist) :-
    D is abs(X - Y),
    total_dist_sorted(Xs - Ys, Dist1),
    Dist is Dist1 + D.

total_dist(L1 - L2, Dist) :-
    msort(L1, L1_s),
    msort(L2, L2_s),
    total_dist_sorted(L1_s - L2_s, Dist).

solution_part1(File, Solution) :-
    read_input(File, Ls),
    total_dist(Ls, Solution).

%%%

bag([], R) :- empty_assoc(R).
bag([X | Xs], R) :-
    bag(Xs, R0),
    ( (
        get_assoc(X, R0, V0, R, V),
        V is V0 + 1,
        !
      )
    ; put_assoc(X, R0, 1, R)
    )
.

similarity_score(L1 - L2, Sim) :-
    bag(L2, Right_list),
    maplist(
      {Right_list}/[X, R] >> (
        ( get_assoc(X, Right_list, Occurrences) ; Occurrences is 0 ),
        R is X * Occurrences
      ),
      L1,
      Ns
    ),
    sum_list(Ns, Sim),
    !.

solution_part2(File, Solution) :-
    read_input(File, Ls),
    similarity_score(Ls, Solution).
