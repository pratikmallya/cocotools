echo on
%!tkn1
prob = coco_prob();
fhan = @(x,p) x^2+(p-1)^2-1;
prob = alg_isol2eqn(prob, 'eqn1', fhan, 0.9, 'y1', 1.1);
prob = alg_isol2eqn(prob, 'eqn2', fhan, 0.1, 'y2', 1.9);
coco(prob, 'run1', [], 1, {'y1' 'y2'}, [0.5 2]);
%!tkn2
prob = coco_prob();
prob = alg_sol2eqn(prob, 'eqn3', 'run1', 'eqn1', 4);
prob = alg_sol2eqn(prob, 'eqn4', 'run1', 'eqn2', 4);
coco(prob, 'run2', [], 1, {'y2' 'y1'}, [0.5 2]);
%!tkn3
alg_read_solution('eqn1', 'run1', 4)
alg_read_solution('eqn2', 'run1', 4)
%!tkn4
echo off