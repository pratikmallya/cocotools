echo on
%% load alg toolbox
addpath('../Pass_5')
%!tkn1
funs = {@(x,p) x^2+(p-1)^2-1, @(x,p) x^2+(p-1)^2-1};
prob = coco_prob();
prob = compalg_isol2sys(prob, 'sys1', funs, {1 -1}, 'y', 1);
coco(prob, 'run1', [], 1, 'y', [0.5 1.5]);
%!tkn2
[sol data] = compalg_read_solution('sys1', 'run1', 4)
%!tkn3
prob = coco_prob();
prob = compalg_sol2sys(prob, 'sys2', 'run1', 'sys1', 4);
coco(prob, 'run2', [], 1, 'y', [0.5 1.5]);
%!tkn4
%% additional runs
prob = coco_prob();
prob = compalg_isol2sys(prob, '', funs{2}, -1, 'y', 1);
coco(prob, 'run1', [], 1, 'y', [0.5 1.5]);
rmpath('../Pass_5');
echo off