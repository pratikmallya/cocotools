function circ04
% create simple toolbox for continuation problem

% f = @(x,p) x^2 + p^2 - 1;
f  = @(x,p) (p+x-x^3)*((x-2)^2-p+2);

opts = [];
opts = circle_create(opts, f, 1, 0);

% run continuation, name branch '1'
bd = coco(opts, '1', [], 'mu', [-2 2]);

% plot bifurcation diagram
x  = coco_bd_col(bd, 'x');
mu = coco_bd_col(bd, 'mu');
plot(mu, x)

end

function opts = circle_create(opts, f, x0, p0)

% initialise data structure
data.f = f;

% add continuation problem (zero problem)
opts = coco_add_func(opts, 'circle', @circle, data, 'zero', ...
  'x0', [ x0 ; p0 ]);

% define u(2)='mu' as parameter
opts = coco_add_parameters(opts, '', 2, 'mu');

% add x to bifurcation diagram
opts = coco_add_slot(opts, 'circle_bddat', @circle_bddat, ...
  [], 'bddat');

% add x to screen output
opts = coco_add_slot(opts, 'circle_print', @circle_print, ...
  [], 'cont_print');

end

function [data y] = circle(opts, data, u) %#ok<INUSL>
y = data.f(u(1), u(2));
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
