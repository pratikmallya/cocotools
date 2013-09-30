echo on
%!tkn1
funs = {@(x,p) x^2+(p-1)^2-1, @(x,p) 2*x, @(x,p) 2*(p-1)};
prob = alg_construct_eqn(funs{:}, 1, 'y', 1.1);
coco(prob, 'run', [], 1, 'y', [0.1 5]);
%!tkn2
funs = {@(x,p) x^2+(p-1)^2-1, @(x,p) 2*x, []};
prob = alg_construct_eqn(funs{:}, 1, 'y', 1.1);
coco(prob, 'run', [], 1, 'y', [0.1 5]);
%!tkn3
echo off