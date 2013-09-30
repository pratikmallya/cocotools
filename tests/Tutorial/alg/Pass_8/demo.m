addpath('../Pass_7')
echo on
%!tkn1
fun = @(x,p) x^2+(p-1)^2-1;
alg_args = {fun, 1.1, 'mu', 1};
prob = coco_prob();
prob = coco_set(prob, 'alg', 'norm', true);
bd1 = coco(prob, 'run1', @alg_isol2eqn, alg_args{:}, 1, ...
  'mu', [0.5 1.5]);
%!tkn2
fun = @(x,p) x^2+(p-1)^2-1;
alg1_args = {fun, 1.1, 1};
alg2_args = {fun, 0.9, 1};
compalg_args = [alg1_args, alg2_args, 'mu'];
prob = coco_prob();
prob = coco_set(prob, 'compalg.alg', 'norm', true);
prob = coco_set(prob, 'compalg.eqn2.alg', 'norm', false);
bd2 = coco(prob, 'run2', @compalg_isol2sys, compalg_args{:}, ...
  1, 'mu', [0.5 1.5]);
%!tkn3
bd3 = coco(prob, 'run3', @compalg_sol2sys, 'run2', 2, ...
  1, 'mu', [0.5 1.5]);
echo off
rmpath('../Pass_7')