function curve02
% added test function for branch points

% f = @(x,p) x^2 + p^2 - 1;
f  = @(x,p) (p+x-x^3)*((x-2)^2-p+2);
% f = @(x,p) [
%   x(1)^2+x(2)^2-p(1)^2
%   [sin(p(2)) 0 cos(p(2))]*[x(1);x(2);p(1)-1]
%   ];

opts = [];

opts = coco_set(opts, 'cont', 'ItMX', 50);

% parametrs of curve
% LP = 1; % enable/disable detection of limit points
% BP = 1; % enable/disable detection of branch points
% ParNames = {...}; % assign descriptive names to parameters

opts = coco_set(opts, 'curve', 'LP', 1);
opts = coco_set(opts, 'curve', 'BP', 1);
opts = coco_set(opts, 'curve', 'ParNames', {'mu'});
% opts = coco_set(opts, 'curve', 'ParNames', {'r' 'alpha'});

% call toolbox constructor
opts = curve_create(opts, f, 0, 0);
% opts = curve_create(opts, f, [sqrt(0.5);sqrt(0.5)], [1;0.1]);

% run continuation, name branch '1'
bd = coco(opts, '1', [], 'mu', [-2 4]);
% bd = coco(opts, '1', [], 'r', [-2 2]);

% plot bifurcation diagram
x = coco_bd_col(bd, 'x');
p = coco_bd_col(bd, 'p');
plot(p,x)

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
data.t     = [];

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
if copts.LP || copts.BP
  % create pointer to data to enable sharing data between
  % test functions and call-back function
  data_ptr = coco_ptr(data);
  
  % add test function for limit points
  opts = coco_add_func(opts, 'curve_TF', @curve_TF, data_ptr, 'regular', ...
    {'test_LP' 'test_BP'});
  
  if copts.LP
    % add event for zero crossing of test_LP
    opts = coco_add_event(opts, 'LP', 'test_LP', 0);
  end
  if copts.BP
    % add event for zero crossing of test_LP
    opts = coco_add_event(opts, 'BP', 'test_BP', 0);
    
    % add update event for BP test function
    opts = coco_add_slot(opts, 'curve_TF_update', @curve_TF_update, ...
      data_ptr, 'covering_update');
  end
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

function [data_ptr y] = curve_TF(opts, data_ptr, u) %#ok<INUSL>
data   = data_ptr.data;
J      = fdm_ezDFDX('f(x,p)', data.f, u(data.x_idx), u(data.p_idx));
y(1,1) = det(J);
if isempty(data.t)
  y(2,1) = 1;
else
  JP     = fdm_ezDFDP('f(x,p)', data.f, u(data.x_idx), u(data.p_idx), data.acp_idx);
  J      = [ J JP ; data.t ];
  y(2,1) = det(J);
end
end

function data_ptr = curve_TF_update(opts, data_ptr, cmd, varargin)
%Update previous-point information for phase condition.

data = data_ptr.data;

switch cmd
  case 'update'
    data.t       = varargin{2}';
    if ~isfield(data, 'acp_idx')
      acp_idx = find(abs(data.t(data.p_idx))>opts.corr.TOL);
      if ~isempty(acp_idx)
        data.acp_idx = acp_idx;
      end
    end
    if isfield(data, 'acp_idx')
      data.t       = data.t([data.x_idx data.x_idx(end) + data.acp_idx]);
      data.t       = data.t/norm(data.t);
    else
      data.t = [];
    end
    
  otherwise
end

data_ptr.data = data;

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
