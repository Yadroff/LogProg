%  Вариант представления: 2 (two.pl)
%  Вариант задания: 3
:-['two.pl'].
:- encoding(utf8).
%Для каждого студента, найти средний балл, и сдал ли он экзамены или нет
%подсчет суммы оценок:
sum_grades([], 0).
sum_grades([H|T], S):- sum_grades(T, S1), S is S1+H.
sum_balls([],0).
sum_balls(Student, Sum):- findall(X, grade(_,Student,_,X), MarksList),
    sum_grades(MarksList, Sum).
sdal([], 'Sdal').
sdal([_|_], 'Ne sdal'). 
%расчет среднего балла
%(Фамилия студента, результат)
sr_ball([], 0).
sr_ball(Student, Mark):- 
    sum_balls(Student, Sum),
    length(MarksList, Len),
    Mark is Sum / Len.
%Вывод информации для одного студента
task_1([]).
task_1([Student|L]):-
    sum_balls(Student, Mark),
    write(Student),
    write(': '),
    write(Mark),
    write(' '),
    findall(X, grade(_, Student, X, 2), Peresdachi),
    sdal(Peresdachi, S),
    write(S),
    write('\n'),
   	task_1(L).
remove_duplicates([], []):-!.
remove_duplicates([X|Xs], Ys):-
      member(X, Xs),
      !, remove_duplicates(Xs, Ys).
remove_duplicates([X|Xs], [X|Ys]):-
%     \+ member(X, Xs),
      !, remove_duplicates(Xs, Ys).
%Вывод информации для каждого студента
main_1():-
    findall(Student, grade(_,Student,_,_), StudentsList),
    remove_duplicates(StudentsList, A),
    task_1(A).
%Нахождение количества несдавших студентов
%(Предмет, количество)
has_bad_marks([], 0).
has_bad_marks(Subject, Ans):-
    findall(Student, grade(_,Student,Subject,2), Peresdachi),
    length(Peresdachi, Ans).
%Вывод информации по списку предметов
task_2([]).
task_2([Subject|L]):-
       write(Subject),
       write(': '),
       has_bad_marks(Subject, X),
       write(X),
       write('\n'), 
       task_2(L).
main_2():-
    findall(Subject, grade(_,_,Subject,_),A),
    remove_duplicates(A, SubjectsList),
    task_2(SubjectsList).
max_ball([], 0).
max_ball([Student|L], N):- max_ball(L, B), sum_balls(Student, A),  A =< B, N is B.
max_ball([Student|L], N):- max_ball(L, B), sum_balls(Student, A), A >= B, N is A.
%Для одной группы.
task_3([]).
task_3([Group|L]):-
    findall(Student, grade(Group,Student,_,_), A),
    remove_duplicates(A, StudentsList),
   	max_ball(StudentsList, N),
    findall(Student, (grade(Group,Student,_,_), sum_balls(Student,N)), Studentss),
    remove_duplicates(Studentss, Students),
    write(Students),
	write('\n'),
	task_3(L).
%Для всех групп
main_3():-
	findall(Group, grade(Group,_,_,_), A),
    remove_duplicates(A, GroupsList),
	task_3(GroupsList).
