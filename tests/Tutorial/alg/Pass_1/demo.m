echo on
%!tkn1
prob = alg_construct_eqn(@circle, 1, 'y', 1.1);
coco(prob, 'run', [], 1, 'y', [0.1 5]);
%!tkn2
prob = alg_construct_eqn(@(x,p) x^2+(p-1)^2-1, 1, 'y', 1.1);
%!tkn3
echo off