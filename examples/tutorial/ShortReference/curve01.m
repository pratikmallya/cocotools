function curve01
% added option for parameter names

% f = @(x,p) x^2 + p^2 - 1;
% f  = @(x,p) (p+x-x^3)*((x-2)^2-p+2);
f = @(x,p) [
  x(1)^2+x(2)^2-p(1)^2
  [sin(p(2)) 0 cos(p(2))]*[x(1);x(2);p(1)-1]
  ];

opts = [];

opts = coco_set(opts, 'cont', 'ItMX', 50);

% parametrs of curve
% LP = 1; % enable/disable detection of limit points
% ParNames = {...}; % assign descriptive names to parameters

opts = coco_set(opts, 'curve', 'LP', 1);
opts = coco_set(opts, 'curve', 'ParNames', {'r' 'alpha'});

% call toolbox constructor
opts = curve_create(opts, f, [sqrt(0.5);sqrt(0.5)], [1;0.1]);

% run continuation, name branch '1'
bd = coco(opts, '1', [], 'r', [-2 2]);

% plot bifurcation diagram
x = coco_bd_col(bd, 'x');
p = coco_bd_col(bd, 'p');
plot(x(1,:), x(2,:))
axis equal

end

function opts = curve_create(opts, f, x0, p0)

% initialise defaults
defaults.LP = 1; % detect limit points
defaults.ParNames = {}; % descriptive parameter names

copts = coco_get(opts, 'curve');
copts = coco_set(defaults, copts);

% initialise data structure
data.f = f;
data.x_idx = 1:numel(x0);
data.p_idx = data.x_idx(end) + (1:numel(p0));

% add continuation problem (zero problem)
opts = coco_add_func(opts, 'curve', @curve, data, 'zero', ...
  'x0', [ x0 ; p0 ]);

% define u(data.p_idx) as parameters
if isempty(copts.ParNames)
  opts = coco_add_parameters(opts, '', data.p_idx, 1:numel(p0));
else
  opts = coco_add_parameters(opts, '', data.p_idx, copts.ParNames);
end

% enable detection of limit points
if copts.LP
  % add test function for limit points
  opts = coco_add_func(opts, 'test_LP', @test_LP, data, 'regular', ...
    'test_LP');
  
  % add event for zero crossing of test_LP
  opts = coco_add_event(opts, 'LP', 'test_LP', 0);
end

% add x to bifurcation diagram
opts = coco_add_slot(opts, 'curve_bddat', @curve_bddat, ...
  data, 'bddat');

% add x to screen output
opts = coco_add_slot(opts, 'curve_print', @curve_print, ...
  [], 'cont_print');

end

function [data y] = curve(opts, data, u) %#ok<INUSL>
y = data.f(u(data.x_idx), u(data.p_idx));
end

function [data y] = test_LP(opts, data, u) %#ok<INUSL>
J = fdm_ezDFDX('f(x,p)', data.f, u(data.x_idx), u(data.p_idx));
y = det(J);
end

function [data res] = curve_bddat(opts, data, command, sol) %#ok<INUSL>
switch command
  case 'init'
    res = { 'x' 'p' };
  case 'data'
    res = { sol.x(data.x_idx) sol.x(data.p_idx) };
end
end

function data = curve_print(opts, data, command, x) %#ok<INUSL>
switch command
  case 'init'
    fprintf('%10s', 'x');
  case 'data'
    fprintf('%10.2e', x(1));
end
end
