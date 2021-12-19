% Вариант 4
%
% "Расстановка мебели". 
% Площадь разделена на шесть квадратов, пять из них заняты мебелью, шестой - свободен. 
% Переставить мебель так, чтобы шкаф и кресло поменялись местами, 
% при этом никакие два предмета не могут стоять на одном квадрате.

% Варианты переходов из одного состояния в другое
% | A | B | C |
% |---|---|---|
% | D | E | F |
state([space, B, C, D, E, F],[B, space, C, D, E, F]).
state([A, space, C, D, E, F],[A, C, space, D, E, F]).
state([A, B, C, space, E, F],[A, B, C, E, space, F]).
state([A, B, C, D, space, F],[A, B, C, D, F, space]).
state([space, B, C, D, E, F],[D, B, C, space, E, F]).
state([A, space, C, D, E, F],[A, E, C, D, space, F]).
state([A, B, space, D, E, F],[A, B, F, D, E, space]).



% Предикат перехода из одного состояния в другое
move(X,Y):-
    state(X,Y);
    state(Y,X).
 
% Предикат продления пути без зацикливания
prolong([Current|T], [Next, Current|T]):-
    move(Current, Next),
    not(member(Next,[Current|T])).

% Предикат, генерирующий последовательность целых чисел
iterate(1).
iterate(X):-
    iterate(Y),
    X is Y + 1.

% Печать в обратном порядке
reverse_print([]).
reverse_print([H|T]):-
    reverse_print(T), 
    write(H), nl.

% Поиск в глубину (Depth First Search)
% Формат ввода: (список начального расположения мебели, список искомого расположения мебели)
% Печатает шаги работы алгоритма в прямом порядке и замеряет время
search_dfs(Start, Finish):-
    get_time(Time1),
    dfs([Start], Finish, Path),
    reverse_print(Path),
    get_time(Time2),
    Time is Time2 - Time1, nl,
    write('DFS time: '),
    write(Time), nl, nl.

% Завершение, если мы нашли целевую вершину
dfs([Finish|T], Finish, [Finish|T]).
% Иначе продляем путь и продолжаем поиск
dfs(CurrentPath, Finish, Path):-
    prolong(CurrentPath, NextPath),
    dfs(NextPath, Finish, Path).

% Поиск в ширину (Breadth First Search)
% Формат ввода: (список начального расположения мебели, список искомого расположения мебели)
% Печатает шаги работы алгоритма в прямом порядке и замеряет время
search_bfs(Start, Finish):-
    get_time(Time1),
    bfs([[Start]], Finish, Path),
    reverse_print(Path),
    get_time(Time2),
    Time is Time2 - Time1, nl,
    write('BFS time: '),
    write(Time), nl, nl.

% Найдена конечная вершина
bfs([[Finish|T]|_], Finish, [Finish|T]).
% Продление первого пути в очереди всеми возможными способами
bfs([CurrentPath|QueueOfPaths], Finish, Path):-
    findall(NextPath, prolong(CurrentPath, NextPath), ListOfCorrectPaths),
    append(QueueOfPaths,  ListOfCorrectPaths, QueueOfCorrectPaths), !, % Отсечение лишнего прохождения при слиянии списков, на логику это влиягия не оказывает
    bfs(QueueOfCorrectPaths, Finish, Path).
% Удаляем из очереди непродляемый путь
bfs([_|T], Y, List):- 
    bfs(T, Y, List).

% Поиск с итерационным заглублением (Iterative Deepening Search)
% Формат ввода: (список начального расположения мебели, список искомого расположения мебели)
% Печатает шаги работы алгоритма в прямом порядке и замеряет время
search_ids(Start, Finish):-
    get_time(Time1),
    iterate(Level),
    ids([Start], Finish, Path, Level),
    reverse_print(Path),
    get_time(Time2),
    Time is Time2 - Time1, nl,
    write('IDS time: '),
    write(Time), nl, nl.

% Достигли нулевого уровня
ids([Finish|T], Finish, [Finish|T], 0).
% Иначе продолжаем погружение
ids(CurrentPath, Finish, Path, L):-
    L > 0,
    prolong(CurrentPath, NewPath),
    L1 is L - 1,
    ids(NewPath, Finish, Path, L1).

% Ищем пути на разных уровнях
search_ids(Start, Finish, Path):-
    iterate(Level),
    search_ids(Start, Finish, Path, Level).
