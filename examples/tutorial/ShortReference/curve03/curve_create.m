function opts = curve_create(opts, f, x0, p0)
% Constructor of toolbox curve. Called by parser functions of toolbox
% curve.

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

% create pointer to data to enable sharing data between
% several function
data_ptr = coco_ptr(data);

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
  % add test function for limit points
  opts = coco_add_func(opts, 'curve_TF', @curve_TF, data_ptr, 'singular', ...
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
  data, 'cont_print');

% save toolbox data for labelled solution points
opts = coco_add_slot(opts, 'curve_save', @coco_save_ptr_data, ...
  data_ptr, 'save_full');
end

function [data y] = curve(opts, data, u) %#ok<INUSL>
% define zero problem
y = data.f(u(data.x_idx), u(data.p_idx));
end

function [data_ptr y] = curve_TF(opts, data_ptr, u) %#ok<INUSL>
% define test functions for limit points and branch points
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
% Update tangent vector and index of active continuation parameter for test
% function for branch points.

data = data_ptr.data;

switch cmd
  case 'update'
    data.t       = varargin{2}';
    if ~isfield(data, 'acp_idx')
      data.acp_idx = find(abs(data.t(data.p_idx))>opts.corr.TOL);
    end
    data.t       = data.t([data.x_idx data.x_idx(end) + data.acp_idx]);
    data.t       = data.t/norm(data.t);
    
  otherwise
end

data_ptr.data = data;

end

function [data res] = curve_bddat(opts, data, command, sol) %#ok<INUSL>
% add data to bifurcation diagram
switch command
  case 'init'
    res = { 'x' 'p' };
  case 'data'
    res = { sol.x(data.x_idx) sol.x(data.p_idx) };
end
end

function data = curve_print(opts, data, command, x) %#ok<INUSL>
% add data to screen output
switch command
  case 'init'
    fprintf('%10s', '||x||');
  case 'data'
    fprintf('%10.2e', norm(x(data.x_idx)));
end
end
