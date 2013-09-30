function opts = coco_add_glue(opts, fid, x1idx, x2idx, varargin)
% opts = coco_add_glue(opts, fid, x1idx, x2idx, varargin)
% varargin = { [gap] [par_names [par_type]] }

assert(numel(x1idx)==numel(x2idx), ...
  '%s: number of elements in x1 and x2 must be equal', mfilename);

par_names = {};
par_type  = 'zero';
gap       = zeros(numel(x1idx),1);
argidx    = 1;
if nargin>=argidx+4 && isnumeric(varargin{argidx})
  gap    = varargin{argidx};
  argidx = argidx + 1;
end
if nargin>=argidx+4
  par_names = varargin{argidx};
  par_type  = 'inactive';
  argidx    = argidx + 1;
end
if nargin>=argidx+4
  par_type  = varargin{argidx};
end

data.x1idx = 1:numel(x1idx);
data.x2idx = numel(x1idx) + (1:numel(x2idx));
data.gap   = gap;
data.J     = [speye(numel(x1idx)) , -speye(numel(x2idx))];
xidx       = [ x1idx(:) ; x2idx(:) ];

if strcmpi(par_type, 'zero')
  opts = coco_add_func(opts, fid, @func_GLUE, @func_DGLUEDX, data, ...
    'zero', 'xidx', xidx);
else
  assert(~strcmpi(par_type, 'zero'), ...
    '%s: parameter type must be one of active, inactive, internal, regular or singular', ...
    mfilename);
  
  t0 = coco_get_func_data(opts, 'efunc', 't0');
  t0 = t0(x1idx) - t0(x2idx);
  
  if any(t0)
    opts = coco_add_func(opts, fid, @func_GLUE, @func_DGLUEDX, data, ...
      par_type, par_names, 'xidx', xidx, 't0', t0);
  else
    opts = coco_add_func(opts, fid, @func_GLUE, @func_DGLUEDX, data, ...
      par_type, par_names, 'xidx', xidx);
  end
end

end

function [data g] = func_GLUE(opts, data, xp) %#ok<INUSL>
g = data.gap + data.J*xp;
end

function [data J] = func_DGLUEDX(opts, data, xp)  %#ok<INUSD,INUSL>
J = data.J;
end
