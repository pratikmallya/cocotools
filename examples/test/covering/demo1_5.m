echo on
%!tkn1
prob = coco_prob();
% prob = coco_set(prob, 'cont', 'cseg', 'cseg4');
prob = coco_set(prob, 'cont', 'atlas', @atlas1_5.create);
%% computational boundary
pprob = coco_add_func(prob, 'circle', @circle, [], 'zero', 'x0', [1.5;1] );
pprob = coco_add_pars(pprob, '', [1 2], {'x' 'y'});
coco(pprob, '1', [], 1, {'x' 'y'}, [0.25 3]);
%!tkn2
%% test locate each type of event
pprob = coco_add_func(prob, 'circle', @circle, [], 'zero', 'x0', [1.5;1] );
pprob = coco_add_pars(pprob, '', [1 2], {'x' 'y'});
pprob = coco_add_pars(pprob, 'reg', 1, 'xr', 'regular');
pprob = coco_add_pars(pprob, 'sing', 1, 'xs', 'singular');
pprob = coco_add_event(pprob, 'CONT', 'x', 0.9);
pprob = coco_add_event(pprob, 'REG',  'xr', 1.1);
pprob = coco_add_event(pprob, 'SING', 'xs', 1);
coco(pprob, '1', [], 1, {'x' 'y'}, [0.75 3]);
%!tkn3

%% basic test
pprob = coco_add_func(prob, 'circle', @circle, [], 'zero', 'x0', [1.5;1] );
pprob = coco_add_pars(pprob, '', [1 2], {'x' 'y'});
coco(pprob, '1', [], 1, {'x' 'y'});
% bd = coco_bd_read('1');
% x  = coco_bd_col(bd,'x');
% y  = coco_bd_col(bd,'y');
% plot(x,y, '.-'); axis equal
%!tkn4
%% test closed branch
pprob = coco_set(pprob, 'cont', 'PtMX', 100);
coco(pprob, '1', [], 1, {'x' 'y'});
%!tkn5
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
% PtMX <= 0 (== PtMX>0)
pprob = coco_set(prob, 'cont', 'PtMX', -30);
pprob = coco_add_func(pprob, 'circle', @circle, [], 'zero', 'x0', [1.5;1] );
pprob = coco_add_pars(pprob, '', [1 2], {'x' 'y'});
coco(pprob, '1', [], 1, {'x' 'y'});
%!tkn6
%% test theta method
% theta == 0 : tangent predictor (explicit Euler)
pprob = coco_set(prob, 'cont', 'theta', 0, 'PtMX', 5);
pprob = coco_add_func(pprob, 'circle', @ellipse, [], 'zero', 'x0', [1.2;0.9] );
pprob = coco_add_pars(pprob, '', [1 2], {'x' 'y'});
coco(pprob, 'th1', [], 1, {'x' 'y'}, [1.19 2]);
% theta = 0.5 : linearly implicit mid-point rule
pprob = coco_set(prob, 'cont', 'theta', 0.5, 'PtMX', 5);
pprob = coco_add_func(pprob, 'circle', @ellipse, [], 'zero', 'x0', [1.2;0.9] );
pprob = coco_add_pars(pprob, '', [1 2], {'x' 'y'});
coco(pprob, 'th2', [], 1, {'x' 'y'}, [1.19 2]);
% theta = 1 : linearly implicit Euler
pprob = coco_set(prob, 'cont', 'theta', 1, 'PtMX', 5);
pprob = coco_add_func(pprob, 'circle', @ellipse, [], 'zero', 'x0', [1.2;0.9] );
pprob = coco_add_pars(pprob, '', [1 2], {'x' 'y'});
coco(pprob, 'th3', [], 1, {'x' 'y'}, [1.19 2]);
coco_view_log('th1', 'type')
coco_view_log('th2', 'type')
coco_view_log('th3', 'type')
%!tkn7
%% start at fold point
pprob = coco_add_func(prob, 'func', @circle, [], 'zero', 'x0', [2;0] );
pprob = coco_add_pars(pprob, '', [1 2], {'x' 'y'});
coco(pprob, '1', [], 1, {'x' 'y'});
% exchanging parameters leads to the same result
coco(pprob, '1', [], 1, {'y' 'x'});
%!tkn8
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
%!tkn9
%% test DROP
pprob = coco_add_func(prob, 'ellipse', @ellipse, [], 'zero', 'x0', [0.6;0.5] );
pprob = coco_add_pars(pprob, '', [1 2], {'x' 'y'});
coco(pprob, '1', [], 1, {'x' 'y'});
%!tkn10
%% MX during continuation with parameters
data.MX = true;
pprob = coco_add_func(prob, 'func', @circle, data, 'zero', 'x0', [1.5;1] );
pprob = coco_add_pars(pprob, '', [1 2], {'x' 'y'});
coco(pprob, '1', [], 1, {'x' 'y'});
%!tkn11
%% MX during continuation, no parameters
data.MX = true;
pprob = coco_add_func(prob, 'func', @circle, data, 'zero', 'x0', [1.5;1] );
coco(pprob, '1', [], 1);
%!tkn12
%% no initial convergence
pprob = coco_add_func(prob, 'func', @empty, [], 'zero', 'x0', [1;1] );
coco(pprob, '1', [], 1);
%!tkn13
%% singular problem
pprob = coco_add_func(prob, 'func', @singular, [], 'zero', 'x0', [1;1] );
coco(pprob, '1', [], 1);
%!tkn14
echo off
