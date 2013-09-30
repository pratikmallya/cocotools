echo on
%!tkn1
prob = alg_isol2eqn(@(x,p) x^2+(p-1)^2-1, 0.9, 'y', 1.1);
bd1 = coco(prob, 'run1', [], 1, 'y', [0.1 5]);
prob = alg_sol2eqn('run1', 9);
bd2 = coco(prob, 'run2', [], 1, 'y', [0.1 1]);
%!tkn2
sol = alg_read_solution('run2', 2)
%!tkn3
echo off