#№ Отчет по лабораторной работе №3
## по курсу "Логическое программирование"

## Решение задач методом поиска в пространстве состояний

### студент: Ядров А. Л.

## Результат проверки

| Преподаватель     | Дата         |  Оценка       |
|-------------------|--------------|---------------|
| Сошников Д.В. |              |               |
| Левинская М.А.|              |               |

> *Комментарии проверяющих (обратите внимание, что более подробные комментарии возможны непосредственно в репозитории по тексту программы)*


## Введение

Решение многих задач в интеллектуальных системах можно определить как проблему поиска, где искомое решение – это цель поиска, а множество возможных путей достижения цели представляет собой пространство состояний. Поиск решений в пространстве состоит в определении последовательности операторов, которые преобразуют начальное состояние в конечное.

Пространство состояний можно представить как граф, вершины которого помечены состояниями, а дуги - операторами. Получается, что такие задачи сводятся к задаче поиска в графе. Если два состояния связаны, то возможен переход системы из одного состояния в другое. Для решения такой задачи, я использовал поиск в глубину, поиск в ширину и поиск с итеративным заглублением.

Для представление графа в программировании обычно используют матричное представление, где граф задается своей матрицей смежности. В Прологе граф описывается предикатами - путем явного перечисления всех дуг в виде пар вершин. Задание графа при помощи дуг является более гибким, чем матрица смежности, поскольку дуги могут задаваться не только явным перечислением, но и при помощи правил, что позволяет нам описывать очень сложные и большие графы, для которых матричное представление нерационально и вообще не всегда возможно.

## Задание

Вариант 4.

| стол | стул |  шкаф  |
|------|------|--------|
| стул |      | кресло |

"Расстановка мебели". Площадь разделена на шесть квадратов, пять из них заняты мебелью, шестой - свободен. Переставить мебель так, чтобы шкаф и кресло поменялись местами, при этом никакие два предмета не могут стоять на одном квадрате.

## Принцип решения

Для начала определимся со способом задания вершины графа в нашем конкретном случае. Пусть вершиной графа будет вся ситема мебели. При помощи предиката `move` обеспечим переход из одной вершины графа в другую. Все возможные переходы реализованы в предикате `state`. Список, представляющий одно состояние, заменяется на список, в котором на пустое место может всать либо рядом стоящий предмет, либо  выше/ниже стоящая мебель, что позволяет получить другое состояние.

```prolog
% Варианты переходов из одного состояния в другое
% | A | B | C |
% |---|---|---|
% | D | E | F |
state([space, B, C, D, E, F],[B, space, C, D, E, F]).
state([space, B, C, D, E, F],[D, B, C, space, E, F]).
state([A, space, C, D, E, F],[A, C, space, D, E, F]).
state([A, space, C, D, E, F],[A, E, C, D, space, F]).
state([A, B, space, D, E, F],[A, B, F, D, E, space]).
state([A, B, C, space, E, F],[A, B, C, E, space, F]).
state([A, B, C, D, space, F],[A, B, C, D, F, space]).

% Предикат перехода из одного состояния в другое
move(X,Y):-
    state(X,Y);
    state(Y,X).
```

Для работы алгоритмов нам понадобятся предикат `prolong`. Он будет продлевать все пути в графе, предотвращая зацикливания.

```prolog
% Предикат продления пути без зацикливания
prolong([Current|T], [Next, Current|T]):-
    move(Current, Next),
    not(member(Next,[Current|T])).
```
А также напишем предикат, который будет печатать наш найденный путь в правильном порядке.

```prolog
% Печать в обратном порядке
reverse_print([]).
reverse_print([H|T]):-
    reverse_print(T), 
    write(H), nl.
```

Теперь перйдем к самим алгоритмам поиска. Было реализовано 3 алгоритма поиска: поиск в глубину, поиск в ширину и поиск с итеративным заглублением. Они отражены в предикатах `search_dfs`, `search_bfs` и `search_ids` соответсвенно.

### 1. Поиск в глубину (Depth First Search)

Поиск в глубину основан на рекурсивном заглублении в дерево, пока возможно продление и не будет достигнута конечная вершина, продолжаем поиск. Так как путь записан в обратном порядке, его необходимо реверсировать, для этого воспользуемся предикатом `reverse_print`, для замерки времени будем использовать встроенный преикат `get_time` (данное утверждение справедливо и для остальных алгоритмов). Найденный путь будет необязательно кратчайшим.

```prolog
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
```
### 2. Поиск в ширину (Breadth First Search)

Поиск в ширину включает в себя последовательный обход элементов по фронту и перемещении на следующий в случае ненахождения необходимого элемента. Для него используется очередь из путей, которые можно продлить. Продленные пути добавляются в конец очереди, а путь, который мы продлевали удаляется. Если первый элемент очереди - это путь который ведет в конечную вершину, поиск можно завершить. Найденный путь гарантированно будет кратчайшим. Этот алгоритм наименее эффективен, потому что элементы по фронту не имеют прямых связей. Но главным преимуществом данного алгоритма ялвяется то, что число итераций не будет превышать число итераций алгоритма поиска в глубину.

```prolog
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
    append(QueueOfPaths,  ListOfCorrectPaths, QueueOfCorrectPaths), !,
    bfs(QueueOfCorrectPaths, Finish, Path).
% Удаляем из очереди непродляемый путь
bfs([_|T], Y, List):- 
    bfs(T, Y, List).
```

### 3. Поиск с итерационным заглублением (Iterative Deepening Search)

Для поиска с итерационным заглублением нам понадобится генератор целых чисел для реализации погружения каждый раз на новый уровень.

```prolog
% Предикат, генерирующий последовательность целых чисел
iterate(1).
iterate(X):-
    iterate(Y),
    X is Y + 1.
```
Поиск с итерационным заглублением собрал в себя всё лучшее от алгоритмов поиска в глубину и ширину. Он осуществляет поиск в глубину до достижения определенной степени погружения, по сложности он не сильно превосходит поиск в ширину, сохраняя все его положительные стороны и исключая требования к памяти. Вложенность для первой итерации равна единице, для каждой последующей это число увеличивается на единицу. Можно сказать, что данный поиск - поиск в глубину, но, т.к. мы ограничываем длину возможных решений, это позволяет нам найти кратчайший путь.

```prolog
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
```
## Результаты

Теперь посмотрим на работу наших алгоритмов. Сравним время их работы и длины первых найденных путей. Начальное и конечное состояния взяты из условия задачи.

Начнем с поиска в глубину. Предикат выводит все состояния системы мебели от начальной до конечной, а также время затраченное на поиск:

```prolog
?- search_dfs([table, chair, wardrobe, chair, space, armchair], [table, chair, armchair, chair, space, wardrobe]).
[table,chair,wardrobe,chair,space,armchair]
[table,chair,wardrobe,chair,armchair,space]
[table,chair,space,chair,armchair,wardrobe]
[table,space,chair,chair,armchair,wardrobe]
[table,armchair,chair,chair,space,wardrobe]
[table,armchair,chair,chair,wardrobe,space]
[table,armchair,space,chair,wardrobe,chair]
[table,space,armchair,chair,wardrobe,chair]
[table,wardrobe,armchair,chair,space,chair]
[table,wardrobe,armchair,chair,chair,space]
[table,wardrobe,space,chair,chair,armchair]
[table,space,wardrobe,chair,chair,armchair]
[space,table,wardrobe,chair,chair,armchair]
[chair,table,wardrobe,space,chair,armchair]
[chair,table,wardrobe,chair,space,armchair]
[chair,table,wardrobe,chair,armchair,space]
[chair,table,space,chair,armchair,wardrobe]
[chair,space,table,chair,armchair,wardrobe]
[chair,armchair,table,chair,space,wardrobe]
[chair,armchair,table,chair,wardrobe,space]
[chair,armchair,space,chair,wardrobe,table]
[chair,space,armchair,chair,wardrobe,table]
[chair,wardrobe,armchair,chair,space,table]
[chair,wardrobe,armchair,chair,table,space]
[chair,wardrobe,space,chair,table,armchair]
[chair,space,wardrobe,chair,table,armchair]
[space,chair,wardrobe,chair,table,armchair]
[chair,chair,wardrobe,space,table,armchair]
[chair,chair,wardrobe,table,space,armchair]
[chair,chair,wardrobe,table,armchair,space]
[chair,chair,space,table,armchair,wardrobe]
[chair,space,chair,table,armchair,wardrobe]
[chair,armchair,chair,table,space,wardrobe]
[chair,armchair,chair,table,wardrobe,space]
[chair,armchair,space,table,wardrobe,chair]
[chair,space,armchair,table,wardrobe,chair]
[chair,wardrobe,armchair,table,space,chair]
[chair,wardrobe,armchair,space,table,chair]
[space,wardrobe,armchair,chair,table,chair]
[wardrobe,space,armchair,chair,table,chair]
[wardrobe,armchair,space,chair,table,chair]
[wardrobe,armchair,chair,chair,table,space]
[wardrobe,armchair,chair,chair,space,table]
[wardrobe,space,chair,chair,armchair,table]
[wardrobe,chair,space,chair,armchair,table]
[wardrobe,chair,table,chair,armchair,space]
[wardrobe,chair,table,chair,space,armchair]
[wardrobe,space,table,chair,chair,armchair]
[wardrobe,table,space,chair,chair,armchair]
[wardrobe,table,armchair,chair,chair,space]
[wardrobe,table,armchair,chair,space,chair]
[wardrobe,table,armchair,space,chair,chair]
[space,table,armchair,wardrobe,chair,chair]
[table,space,armchair,wardrobe,chair,chair]
[table,armchair,space,wardrobe,chair,chair]
[table,armchair,chair,wardrobe,chair,space]
[table,armchair,chair,wardrobe,space,chair]
[table,space,chair,wardrobe,armchair,chair]
[table,chair,space,wardrobe,armchair,chair]
[table,chair,chair,wardrobe,armchair,space]
[table,chair,chair,wardrobe,space,armchair]
[table,space,chair,wardrobe,chair,armchair]
[space,table,chair,wardrobe,chair,armchair]
[wardrobe,table,chair,space,chair,armchair]
[wardrobe,table,chair,chair,space,armchair]
[wardrobe,table,chair,chair,armchair,space]
[wardrobe,table,space,chair,armchair,chair]
[wardrobe,space,table,chair,armchair,chair]
[wardrobe,armchair,table,chair,space,chair]
[wardrobe,armchair,table,chair,chair,space]
[wardrobe,armchair,space,chair,chair,table]
[wardrobe,space,armchair,chair,chair,table]
[wardrobe,chair,armchair,chair,space,table]
[wardrobe,chair,armchair,chair,table,space]
[wardrobe,chair,space,chair,table,armchair]
[wardrobe,space,chair,chair,table,armchair]
[space,wardrobe,chair,chair,table,armchair]
[chair,wardrobe,chair,space,table,armchair]
[chair,wardrobe,chair,table,space,armchair]
[chair,wardrobe,chair,table,armchair,space]
[chair,wardrobe,space,table,armchair,chair]
[chair,space,wardrobe,table,armchair,chair]
[chair,armchair,wardrobe,table,space,chair]
[chair,armchair,wardrobe,table,chair,space]
[chair,armchair,space,table,chair,wardrobe]
[chair,space,armchair,table,chair,wardrobe]
[chair,chair,armchair,table,space,wardrobe]
[chair,chair,armchair,space,table,wardrobe]
[space,chair,armchair,chair,table,wardrobe]
[chair,space,armchair,chair,table,wardrobe]
[chair,armchair,space,chair,table,wardrobe]
[chair,armchair,wardrobe,chair,table,space]
[chair,armchair,wardrobe,chair,space,table]
[chair,space,wardrobe,chair,armchair,table]
[chair,wardrobe,space,chair,armchair,table]
[chair,wardrobe,table,chair,armchair,space]
[chair,wardrobe,table,chair,space,armchair]
[chair,space,table,chair,wardrobe,armchair]
[chair,table,space,chair,wardrobe,armchair]
[chair,table,armchair,chair,wardrobe,space]
[chair,table,armchair,chair,space,wardrobe]
[chair,table,armchair,space,chair,wardrobe]
[space,table,armchair,chair,chair,wardrobe]
[table,space,armchair,chair,chair,wardrobe]
[table,armchair,space,chair,chair,wardrobe]
[table,armchair,wardrobe,chair,chair,space]
[table,armchair,wardrobe,chair,space,chair]
[table,space,wardrobe,chair,armchair,chair]
[table,wardrobe,space,chair,armchair,chair]
[table,wardrobe,chair,chair,armchair,space]
[table,wardrobe,chair,chair,space,armchair]
[table,space,chair,chair,wardrobe,armchair]
[table,chair,space,chair,wardrobe,armchair]
[table,chair,armchair,chair,wardrobe,space]
[table,chair,armchair,chair,space,wardrobe]

DFS time: 0.15979504585266113

true .
```

Теперь взглянем на поиск в ширину. Предикат выводит все состояния системы мебели от начальной до конечной, а также время затраченное на поиск:

```prolog
?- search_bfs([table, chair, wardrobe, chair, space, armchair], [table, chair, armchair, chair, space, wardrobe]).
[table,chair,wardrobe,chair,space,armchair]
[table,chair,wardrobe,chair,armchair,space]
[table,chair,space,chair,armchair,wardrobe]
[table,space,chair,chair,armchair,wardrobe]
[table,armchair,chair,chair,space,wardrobe]
[table,armchair,chair,space,chair,wardrobe]
[space,armchair,chair,table,chair,wardrobe]
[armchair,space,chair,table,chair,wardrobe]
[armchair,chair,space,table,chair,wardrobe]
[armchair,chair,wardrobe,table,chair,space]
[armchair,chair,wardrobe,table,space,chair]
[armchair,space,wardrobe,table,chair,chair]
[space,armchair,wardrobe,table,chair,chair]
[table,armchair,wardrobe,space,chair,chair]
[table,armchair,wardrobe,chair,space,chair]
[table,armchair,wardrobe,chair,chair,space]
[table,armchair,space,chair,chair,wardrobe]
[table,space,armchair,chair,chair,wardrobe]
[table,chair,armchair,chair,space,wardrobe]

BFS time: 0.0869753360748291

true .
```

И напоследок поиск с итерационным заглублением. Предикат выводит все состояния системы мебели от начальной до конечной, а также время затраченное на поиск:

```prolog
?- search_ids([table, chair, wardrobe, chair, space, armchair], [table, chair, armchair, chair, space, wardrobe]).
[table,chair,wardrobe,chair,space,armchair]
[table,chair,wardrobe,chair,armchair,space]
[table,chair,space,chair,armchair,wardrobe]
[table,space,chair,chair,armchair,wardrobe]
[table,armchair,chair,chair,space,wardrobe]
[table,armchair,chair,space,chair,wardrobe]
[space,armchair,chair,table,chair,wardrobe]
[armchair,space,chair,table,chair,wardrobe]
[armchair,chair,space,table,chair,wardrobe]
[armchair,chair,wardrobe,table,chair,space]
[armchair,chair,wardrobe,table,space,chair]
[armchair,space,wardrobe,table,chair,chair]
[space,armchair,wardrobe,table,chair,chair]
[table,armchair,wardrobe,space,chair,chair]
[table,armchair,wardrobe,chair,space,chair]
[table,armchair,wardrobe,chair,chair,space]
[table,armchair,space,chair,chair,wardrobe]
[table,space,armchair,chair,chair,wardrobe]
[table,chair,armchair,chair,space,wardrobe]

IDS time: 0.06670713424682617

true .
```
Для наглядности все данные собраны в таблице, представленной ниже.

! Алгоритм поиска |  Длина найденного первым пути  |  Время работы     |
|----------------------------------------------------------------------|
| В глубину       |              115               |0.15979504585266113|
| В ширину        |              19                |0.0869753360748291 |
| ID              |              19                |0.06670713424682617|

## Выводы

Все три, использованные мною, алгоритма решили поставленную задачу. Поиск в глубину является естественным для языка Пролог, он используется машиной вывода Пролога для вычисления целей. Поэтому поиск в глубину путей на графах реализуется в языке Пролог наиболее просто.  Алгоритм поиска в глубину оказался самым быстрым из трех реализованных алгоритмов, но путь, который он нашел во много раз превышает путь, найденный алгоритмом поиска в ширину и алгоритмом поиска с итеративным заглублением. Если нужно было бы выбирать по критерию длины пути, то алгоритм поиска в глубину можно было бы сразу исключить из рассмотрения.

Поиск в ширину программируется не так легко, как поиск в глубину. Причина состоит в том, что нам приходится сохранять все множество альтернативных вершин-кандидатов, а не только одну вершину, как при поиске в глубину. Несложно заметить, что такой поиск в ширину имеет экспоненциальную сложность как по времени, так и по памяти. В лучшем случае решение может найтись сразу, тогда можно избежать таких растрат, но зачастую это маловероятно.

Я считаю, что поиск с итеративным углублением является наиболее подходящим для решения данной задачи, по следующим причинам:

- в отличии от DFS, он находит кратчайший путь для решения, хоть и работает дольше, 
- использование BFS оперативной памяти желает оставлять лучшего.
