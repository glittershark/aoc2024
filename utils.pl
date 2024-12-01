% -*- mode: prolog -*-
:- module(utils, [read_lines/2,
                  binary_number/2,
                  times/5,
                  times/6,
                  string_phrase/2,
                  string_phrase/3,
                  phrase_file/2,
                  phrase_file/3,
                  lazy_sequence/5,

                  chunks/3,
                  replace1/4,
                  list_product/2
                 ]).
:- use_module(library(clpfd)).

read_lines(Stream, []) :- at_end_of_stream(Stream).
read_lines(Stream, [X | L]) :-
    \+ at_end_of_stream(Stream),
    read_line_to_string(Stream, X),
    read_lines(Stream, L).

binary_number(Bs, N) :-
   binary_number_min(Bs, 0,N, N).

binary_number_min([], N,N, _M).
binary_number_min([B|Bs], N0,N, M) :-
   B in 0..1,
   N1 #= B+2*N0,
   M #>= N1,
   binary_number_min(Bs, N1,N, M).

times(N, G, L) --> times(N, G, [], L).

times(0, _, _, []) --> [].
times(1, G, _, [X]) -->
    call(G, X).
times(N, G, Sep, [X | Xs]) -->
    call(G, X),
    Sep,
    { N1 is N - 1 },
    times(N1, G, Sep, Xs).

:- meta_predicate
       string_phrase(//, ?),
       string_phrase(//, ?, ?).
string_phrase(RuleSet, InputString) :-
   ground(InputString),
   string_codes(InputString, Input),
   phrase(RuleSet, Input).
string_phrase(RuleSet, InputString) :-
   phrase(RuleSet, Input),
   string_codes(InputString, Input).
string_phrase(RuleSet, InputString, RestString) :-
   string_codes(InputString, Input),
   phrase(RuleSet, Input, RestCodes),
   string_codes(RestString, RestCodes).

:- meta_predicate
       phrase_file(//, +),
       phrase_file(//, +, ?).
phrase_file(RuleSet, File) :-
   open(File, read, Stream),
   read_string(Stream, _, String),
   string_phrase(RuleSet, String).
phrase_file(RuleSet, File, Rest) :-
   open(File, read, Stream),
   read_string(Stream, _, String),
   string_phrase(RuleSet, String, Rest).


:- meta_predicate lazy_sequence(:, :, ?, ?, ?).
lazy_sequence(_, _, []) --> [].
lazy_sequence(Element, _, [X]) --> call(Element, X).
lazy_sequence(Element, Sep, [X | Xs]) -->
    call(Element, X),
    Sep,
    lazy_sequence(Element, Sep, Xs).

chunks(Len, List, [Chunk | Chunks]) :-
   append(Chunk, Rest, List),
   length(Chunk, Len),
   chunks(Len, Rest, Chunks),
   !.
chunks(_, _, []).

% unify R with L, except replacing the value at position P (1-based) with E
replace1(L, P, E, R) :-
    PreLen is P - 1,
    length(Pre, PreLen),
    append(Pre, [_|T], L),
    append(Pre, [E|T], R).

list_product([], 1).
list_product([X | Xs], P) :-
   list_product(Xs, XsP),
   P #= XsP * X.

%%%

:- begin_tests(utils).

test(replace) :-
   replace1([a,b,c], 1, a2, [a2,b,c]),
   replace1([a,b,c], 2, b2, [a,b2,c]),
   replace1([a,b,c], 3, c2, [a,b,c2]),
   \+ replace1([a,b,c], 4, d2, _).

test(list_product) :-
   list_product([1234], 1234),
   list_product([1, 2, 3, 4], 24).

:- end_tests(utils).
