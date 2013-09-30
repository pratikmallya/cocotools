echo on
%% Example1

%!tkn1
prob = coco_prob();
prob = coco_add_func(prob, 'fun1', @circ, [], 'zero', ...
  'u0', [0.9; 1.1]);
coco(prob, 'run1', [], 1);
%!tkn2
prob = coco_add_func(prob, 'fun2', @dist, [], 'inactive', 'p', ...
  'uidx', [1; 2]);
coco(prob, 'run2', [], 0);
%!tkn3
coco(prob, 'run3', [], 1, 'p', [0.1 5]);
%!tkn4
bd = coco_bd_read('run3');
%!tkn5
%% Example 2
%!tkn10
prob = coco_prob();
prob = coco_add_func(prob, 'fun1', @circ, [], 'zero', ...
  'u0', [0.9; 1.1]);
prob = coco_add_func(prob, 'fun2', @plan, [], 'zero', ...
  'uidx', 2, 'u0', -1.1);
prob = coco_add_func(prob, 'fun3', @hype, [], 'inactive', 'p', ...
  'uidx', [1; 3]);
coco(prob, 'run4', [], 0);
%!tkn11
[data chart] = coco_read_solution('fun2', 'run4', 1);
chart.x
%!tkn12
prob = coco_add_pars(prob, 'pars', 3, {'u3'}, 'active');
coco(prob, 'run5', [], 1, {'p' 'u3'}, [-0.4 0.4]);
%!tkn13
%% Example4
%!tkn14
u0 = [1; 0.3; 1.275; -0.031; -0.656; 0.382; 0.952; ...
  -0.197; -0.103; 0.286; 1.275; -0.031];
prob = period(u0, 4);
prob = coco_add_pars(prob, 'pars', [1 2], {'a' 'b'});
coco(prob, 'run6', [], 1, 'a', [0.8 1.2]);
%!tkn15
echo off

% prob = coco_prob();
% prob = coco_add_func(prob, 'fun1', @circ, [], 'zero', ...
%   'u0', [0.9; 1.1]);
% prob = coco_add_func(prob, 'fun2', @plan, [], 'zero', ...
%   'uidx', 2, 'u0', -1.1);
% prob = coco_add_func(prob, 'fun3', @dist, [], 'inactive', 'p', ...
%   'uidx', [1, 3]);
% coco(prob, 'run4', [], 0);
% 
% prob = coco_prob();
% prob = coco_add_func(prob, 'fun2', @plan, [], 'zero', ...
%   'u0', [1.1; -1.1]);
% prob = coco_add_func(prob, 'fun3', @distmod, [], ...
%   'inactive', 'p', 'uidx', 2, 'u0', 0.9);
% prob = coco_add_func(prob, 'fun1', @circ, [], 'zero', ...
%   'uidx', [3, 1]);
% coco(prob, 'run5', [], 0);