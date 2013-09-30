function circ03
% add screen output

opts = [];

% add continuation problem (zero problem)
opts = coco_add_func(opts, 'circle', @circle, [], 'zero', ...
  'x0', [1;0]);

% define u(2)='mu' as parameter
opts = coco_add_parameters(opts, '', 2, 'mu');

% add x to bifurcation diagram
opts = coco_add_slot(opts, 'circle_bddat', @circle_bddat, ...
  [], 'bddat');

% add x to screen output
opts = coco_add_slot(opts, 'circle_print', @circle_print, ...
  [], 'cont_print');

% run continuation, name branch '1'
bd = coco(opts, '1', [], 'mu', [-2 2]);

% plot bifurcation diagram
x  = coco_bd_col(bd, 'x');
mu = coco_bd_col(bd, 'mu');
plot(mu, x)

end

function [data y] = circle(opts, data, u) %#ok<INUSL>
y = u(1)^2 + u(2)^2 - 1;
end

function [data res] = circle_bddat(opts, data, command, sol) %#ok<INUSL>
switch command
  case 'init'
    res = { 'x' };
  case 'data'
    res = { sol.x(1) };
end
end

function data = circle_print(opts, data, command, x) %#ok<INUSL>
switch command
  case 'init'
    fprintf('%10s', 'x');
  case 'data'
    fprintf('%10.2e', x(1));
end
end
