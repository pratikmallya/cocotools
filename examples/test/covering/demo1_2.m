echo on
%!tkn1
prob = coco_prob();
prob = coco_set(prob, 'cont', 'atlas', @atlas1_2.create);
%% test PtMX
% PtMX >= 0
pprob = coco_set(prob, 'cont', 'PtMX', 30);
pprob = coco_add_func(pprob, 'circle', @circle, [], 'zero', 'x0', [1.5;1] );
pprob = coco_add_pars(pprob, '', [1 2], {'x' 'y'});
coco(pprob, '1', [], 1, {'x' 'y'});
% PtMX == 0
pprob = coco_set(prob, 'cont', 'PtMX', 0);
pprob = coco_add_func(pprob, 'circle', @circle, [], 'zero', 'x0', [1.5;1] );
pprob = coco_add_pars(pprob, '', [1 2], {'x' 'y'});
coco(pprob, '1', [], 1, {'x' 'y'});
% PtMX <= 0
pprob = coco_set(prob, 'cont', 'PtMX', -30);
pprob = coco_add_func(pprob, 'circle', @circle, [], 'zero', 'x0', [1.5;1] );
pprob = coco_add_pars(pprob, '', [1 2], {'x' 'y'});
coco(pprob, '1', [], 1, {'x' 'y'});
%!tkn2

%% basic test
pprob = coco_add_func(prob, 'circle', @circle, [], 'zero', 'x0', [1.5;1] );
pprob = coco_add_pars(pprob, '', [1 2], {'x' 'y'});
coco(pprob, '1', [], 1, {'x' 'y'});
%!tkn3
%% start at fold point
pprob = coco_add_func(prob, 'func', @circle, [], 'zero', 'x0', [2;0] );
pprob = coco_add_pars(pprob, '', [1 2], {'x' 'y'});
coco(pprob, '1', [], 1, {'x' 'y'});
% exchanging parameters leads to the same result
coco(pprob, '1', [], 1, {'y' 'x'});
%!tkn4
%% start at branch point
pprob = coco_add_func(prob, 'lemniscate', @lemniscate, [], ...
  'zero', 'x0', [0;0] );
pprob = coco_add_pars(pprob, '', [1 2], {'x' 'y'});
coco(pprob, '1', [], 1, {'x' 'y'});
% this time with tangent
pprob = coco_add_func(prob, 'lemniscate', @lemniscate, [], ...
  'zero', 'x0', [0;0], 't0', [1;1] );
pprob = coco_add_pars(pprob, '', [1 2], {'x' 'y'});
coco(pprob, '1', [], 1, {'x' 'y'});
% bd = coco_bd_read('1');
% x  = coco_bd_col(bd,'x');
% y  = coco_bd_col(bd,'y');
% plot(x,y, '.-')
%!tkn5
%% MX during continuation with parameters
data.MX = true;
pprob = coco_add_func(prob, 'func', @circle, data, 'zero', 'x0', [1.5;1] );
pprob = coco_add_pars(pprob, '', [1 2], {'x' 'y'});
coco(pprob, '1', [], 1, {'x' 'y'});
%!tkn6
%% MX during continuation, no parameters
data.MX = true;
pprob = coco_add_func(prob, 'func', @circle, data, 'zero', 'x0', [1.5;1] );
coco(pprob, '1', [], 1);
%!tkn7
%% no initial convergence
pprob = coco_add_func(prob, 'func', @empty, [], 'zero', 'x0', [1;1] );
coco(pprob, '1', [], 1);
%!tkn8
%% singular problem
pprob = coco_add_func(prob, 'func', @singular, [], 'zero', 'x0', [1;1] );
coco(pprob, '1', [], 1);
%!tkn9
echo off
