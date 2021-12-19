task(Dancer, Painter, Singer, Writer):-
  permutation([Dancer, Painter, Singer, Writer], [voronov, pavlov, levickiy, saharov]),
  Singer \= voronov, Singer \= levickiy,
  Painter \= pavlov, Writer \= pavlov,
  Writer \= saharov, Writer \= voronov,
  not((Painter = voronov, Writer = levickiy)),
  not((Writer = voronov, Painter = levickiy)), !.
