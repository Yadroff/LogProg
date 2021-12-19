:-['res.pl'].

%3
wife(Husband, Wife):-
    male(Husband),
    female(Wife),
    child(Child, Husband),
    child(Child, Wife).
sibling(Person, Sibling):-
    child(Person, P),
    child(Sibling, P),
    Person \= Sibling.
shurin(Man, Brother_mans_wife):-
    wife(Man, Wife),
    sibling(Brother_mans_wife, Wife).
%4
check(shurin, Man, Shurin) :- shurin(Man, Shurin).
check(husband, Wife, Husband) :- wife(Husband, Wife).
check(wife, Husband, Wife) :- wife(Wife, Husband).
check(brother, Y, Brother) :- sibling(Brother, Y), male(Brother).
check(sister, Y, Sister) :- sibling(Sister, Y), female(Sister).
check(father, Child, Father) :- child(Child, Father), male(Father).
check(mother, Child, Mother) :- child(Child, Mother), female(Mother).
check(son, Parent, Child) :- child(Child, Parent), male(Child).
check(daughter, Parent, Child) :- child(Child, Parent), female(Child).

next_iteration(X, Z) :- child(X,Z).
next_iteration(X, Z) :- child(Z,X).
next_iteration(X, Z) :- sibling(X, Z).

inc(1).
inc(M):- inc(N), (N < 6 -> M is N+1; !, fail).

search(Path, X, Y, N) :- N = 1, check(A, X, Y), Path = [A].
search(Path, X, Y, N) :- N > 1, next_iteration(X, Z), N1 is N-1, search(Res, Z, Y, N1), check(B, X, Z), append([B], Res, Path).


relative(Res, X, Y) :- var(Res), inc(N), N < 6,  search(Res, X, Y, N), Y \= X.
relative(Res, X, Y) :- nonvar(Res), length(Res, N), search(Res, X, Y, N), Y \= X.

% 5

question_1(X) :- member(X, [whose, "Whose"]).
question_2(X) :- member(X, [what, "What"]).
rel(X) :- member(X, [relations, relationship]).
bet(X) :- member(X, [between]).
word_1(X) :- member(X, [is, "Is"]).
word_2(X) :- member(X, [and, "And"]).
have_lst([X], REL) :- member(X, [REL]).
question_sign(X) :- member(X, ['?']).

write_list([]).
write_list([X|T]):- write(X), (T \= [] ->  write(" - "), write_list(T); !).
question(L) :-
    L = [IS, NAME_0, REL,NAME_1, QS],
    word_1(IS), relative(X, NAME_1,NAME_0), !,
    have_lst(X, REL), question_sign(QS),
    write(NAME_0), write(" is "), write(REL), write(" "), write(NAME_1),write(".").
question(L) :-
    L = [WHOSE, REL, IS, NAME, QS],
    question_1(WHOSE), word_1(IS), question_sign(QS),
    relative([REL], NAME, Ans),
    write(NAME), write(" is "), write(REL), write(" "), write(Ans), write("."), nl.
question(L) :-
    L = [WHAT, RELATIONS, BETWEEN, NAME_1, AND, NAME_0,QS],
    question_2(WHAT), rel(RELATIONS), bet(BETWEEN), word_2(AND), question_sign(QS),
    relative(Res, NAME_1, NAME_0),
    write_list(Res), nl.