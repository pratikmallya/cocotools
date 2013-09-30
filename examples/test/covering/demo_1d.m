echo on
%!tkn1
prob = coco_prob();
prob = coco_set(prob, 'cont', 'atlas', @atlas_1d.create);
%% basic test
pprob = coco_add_func(prob, 'circle', @circle, [], 'zero', 'x0', [1.5;1] );
pprob = coco_add_pars(pprob, '', [1 2], {'x' 'y'});
coco(pprob, '1', [], 1, {'x' 'y' 'atlas_FP' 'atlas_BP'}, {[-1 3], [-2 2]});
% bd = coco_bd_read('1');
% x  = coco_bd_col(bd,'x');
% y  = coco_bd_col(bd,'y');
% plot(x,y, '.-'); axis equal
%!tkn6
%% computational boundary
pprob = coco_add_func(prob, 'circle', @circle, [], 'zero', 'x0', [1.5;1] );
pprob = coco_add_pars(pprob, '', [1 2], {'x' 'y'});
coco(pprob, '1', [], 1, {'x' 'y' 'atlas_FP' 'atlas_BP'}, [0.75 3]);
%!tkn7
%% test locate each type of event
pprob = coco_add_func(prob, 'circle', @circle, [], 'zero', 'x0', [1.5;1] );
pprob = coco_add_pars(pprob, '', [1 2], {'x' 'y'});
pprob = coco_add_pars(pprob, 'reg', 1, 'xr', 'regular');
pprob = coco_add_pars(pprob, 'sing', 1, 'xs', 'singular');
pprob = coco_add_event(pprob, 'CONT', 'x', 0.9);
pprob = coco_add_event(pprob, 'REG',  'xr', 1.1);
pprob = coco_add_event(pprob, 'SING', 'xs', 1);
coco(pprob, '1', [], 1, {'x' 'y' 'atlas_FP' 'atlas_BP'}, [0.75 3]);
%!tkn8
%% IP outside computational domain
pprob = coco_add_func(prob, 'circle', @circle, [], 'zero', 'x0', [1.5;1] );
pprob = coco_add_pars(pprob, '', [1 2], {'x' 'y'});
coco(pprob, '1', [], 1, {'x' 'y' 'atlas_FP' 'atlas_BP'}, {[0 1], [-1 0]});
%!tkn2
%% IP on boundary of computational domain, direction tangent
pprob = coco_add_func(prob, 'circle', @circle, [], 'zero', 'x0', [1;1] );
pprob = coco_add_pars(pprob, '', [1 2], {'x' 'y'});
coco(pprob, '1', [], 1, {'x' 'y' 'atlas_FP' 'atlas_BP'}, {[1 2], [-1 1]});
%!tkn3
%% IP on boundary of computational domain, no direction admissible
pprob = coco_add_func(prob, 'circle', @circle, [], 'zero', 'x0', [1;1] );
pprob = coco_add_pars(pprob, '', [1 2], {'x' 'y'});
coco(pprob, '1', [], 1, {'x' 'y' 'atlas_FP' 'atlas_BP'}, {[1 1], [-2 2]});
%!tkn4
%% IP on boundary of computational domain, direction transversal
pprob = coco_add_func(prob, 'circle', @circle, [], 'zero', 'x0', [1;1] );
pprob = coco_add_pars(pprob, '', [1 2], {'x' 'y'});
coco(pprob, '1', [], 1, {'x' 'y' 'atlas_FP' 'atlas_BP'}, {[1 2], [-1 2]});
%!tkn5
%% test ItMX, uni-directional
% PtMX >= 0
pprob = coco_set(prob, 'cont', 'ItMX', 30, 'bi_direct', false);
pprob = coco_add_func(pprob, 'circle', @circle, [], 'zero', 'x0', [1.5;1] );
pprob = coco_add_pars(pprob, '', [1 2], {'x' 'y'});
coco(pprob, '1', [], 1, {'x' 'y' 'atlas_FP' 'atlas_BP'});
% PtMX == 0
pprob = coco_set(prob, 'cont', 'ItMX', 0, 'bi_direct', false);
pprob = coco_add_func(pprob, 'circle', @circle, [], 'zero', 'x0', [1.5;1] );
pprob = coco_add_pars(pprob, '', [1 2], {'x' 'y'});
coco(pprob, '1', [], 1, {'x' 'y' 'atlas_FP' 'atlas_BP'});
% PtMX <= 0
pprob = coco_set(prob, 'cont', 'ItMX', -30, 'bi_direct', false);
pprob = coco_add_func(pprob, 'circle', @circle, [], 'zero', 'x0', [1.5;1] );
pprob = coco_add_pars(pprob, '', [1 2], {'x' 'y'});
coco(pprob, '1', [], 1, {'x' 'y' 'atlas_FP' 'atlas_BP'});
%!tkn10
%% test ItMX, bi-directional
% PtMX >= 0
pprob = coco_set(prob, 'cont', 'ItMX', [0 30]);
pprob = coco_add_func(pprob, 'circle', @circle, [], 'zero', 'x0', [1.5;1] );
pprob = coco_add_pars(pprob, '', [1 2], {'x' 'y'});
coco(pprob, '1', [], 1, {'x' 'y' 'atlas_FP' 'atlas_BP'});
% PtMX == 0
pprob = coco_set(prob, 'cont', 'ItMX', [0 0]);
pprob = coco_add_func(pprob, 'circle', @circle, [], 'zero', 'x0', [1.5;1] );
pprob = coco_add_pars(pprob, '', [1 2], {'x' 'y'});
coco(pprob, '1', [], 1, {'x' 'y' 'atlas_FP' 'atlas_BP'});
% PtMX <= 0
pprob = coco_set(prob, 'cont', 'ItMX', [30 0]);
pprob = coco_add_func(pprob, 'circle', @circle, [], 'zero', 'x0', [1.5;1] );
pprob = coco_add_pars(pprob, '', [1 2], {'x' 'y'});
coco(pprob, '1', [], 1, {'x' 'y' 'atlas_FP' 'atlas_BP'});
%!tkn10
%% start at fold point
pprob = coco_add_func(prob, 'func', @circle, [], 'zero', 'x0', [2;0] );
pprob = coco_add_pars(pprob, '', [1 2], {'x' 'y'});
coco(pprob, '1', [], 1, {'x' 'y'});
% exchanging parameters leads to the same result
coco(pprob, '1', [], 1, {'y' 'x' 'atlas_FP' 'atlas_BP'});
%!tkn12
%% start at branch point
pprob = coco_add_func(prob, 'lemniscate', @lemniscate, [], ...
  'zero', 'x0', [0;0] );
pprob = coco_add_pars(pprob, '', [1 2], {'x' 'y'});
coco(pprob, '1', [], 1, {'x' 'y' 'atlas_FP' 'atlas_BP'});
% this time with tangent
pprob = coco_add_func(prob, 'lemniscate', @lemniscate, [], ...
  'zero', 'x0', [0;0], 't0', [1;1] );
pprob = coco_add_pars(pprob, '', [1 2], {'x' 'y'});
coco(pprob, '1', [], 1, {'x' 'y' 'atlas_FP' 'atlas_BP'});
%!tkn13
%% MX during continuation with parameters
data.MX = true;
pprob = coco_add_func(prob, 'func', @circle, data, 'zero', 'x0', [1.5;1] );
pprob = coco_add_pars(pprob, '', [1 2], {'x' 'y'});
coco(pprob, '1', [], 1, {'x' 'y' 'atlas_FP' 'atlas_BP'});
%!tkn15
%% MX during continuation, no parameters
data.MX = true;
pprob = coco_add_func(prob, 'func', @circle, data, 'zero', 'x0', [1.5;1] );
coco(pprob, '1', [], 1);
%!tkn16
%% no initial convergence
pprob = coco_add_func(prob, 'func', @empty, [], 'zero', 'x0', [1;1] );
coco(pprob, '1', [], 1);
%!tkn17
%% singular problem
pprob = coco_add_func(prob, 'func', @singular, [], 'zero', 'x0', [1;1] );
coco(pprob, '1', [], 1);
%!tkn18
echo off
