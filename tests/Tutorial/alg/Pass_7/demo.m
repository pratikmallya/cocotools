addpath('../Pass_5')
echo on
%!tkn1
fun = @(x,p) x^2+(p-1)^2-1;
alg_args = {fun, 0.9, 'y', 1};
coco('run1', @alg_isol2eqn, alg_args{:}, 1, 'y', [0.5 1.5]);
coco('run2', @alg_sol2eqn, 'run1', 4, 1, 'y', [0.1 1.9]);
%!tkn2
fun = @(x,p) x^2+(p-1)^2-1;
alg1_args = {fun, 1.1, 1};
alg2_args = {fun, 0.9, 1};
compalg_args = [alg1_args, alg2_args, 'y'];
coco('run3', @compalg_isol2sys, compalg_args{:}, 1, 'y', [0.5 1.5]);
coco('run4', @compalg_sol2sys, 'run3', 2, 1, 'y', [0.5 1.5]);
%!tkn3
prob = coco_prob();
prob = alg_sol2eqn(prob, 'eq', 'run1', '', 4);
coco(prob, 'run5', [], 1, 'y',  [0.1 1.9]);
%!tkn4
sol = compalg_read_solution('', 'run4', 2)
echo off
rmpath('../Pass_5')