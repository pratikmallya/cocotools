echo on
%!tkn1
funs = {@(x,p) x^2+(p-1)^2-1, @(x,p) 2*x, @(x,p) 2*(p-1)};
prob = alg_construct_eqn(funs{:}, 1, 'y', 1.1);
coco(prob, 'run', [], 1, 'y', [0.1 5]);
%!tkn2
data = coco_read_solution('', 'run', 3)
%!tkn2b
data = coco_read_solution('alg', 'run', 3)
%!tkn3
[x p] = alg_read_solution('run', 4)
%!tkn4
echo off