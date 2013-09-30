function opts = coco_add_pars(opts, fid, varargin)
%COCO_ADD_PARS   Add external parameters to continuation problem.
%
% coco_add_pars(opts, fid, varargin)
% varargin = { pidx,      par_names, [par_type] }
%          | { par_names, pvals,     [par_type] }

% bug: disallow zero functions

if nargin<5
  varargin{3} = 'inactive';
end

if isempty(fid)
  fid = 'pars';
end

if isnumeric(varargin{1})
  opts = map_vars(opts, fid, varargin{:});
else
  opts = add_pars(opts, fid, varargin{:});
end

end

function opts = map_vars(opts, fid, pidx, par_names, par_type)

assert(~strcmpi(par_type, 'zero'), ...
  '%s: parameter type must be one of active, inactive, internal, regular or singular', ...
  mfilename);

if ischar(par_names)
  par_names = { par_names };
end

t0 = coco_get_func_data(opts, 'efunc', 't0');
t0 = t0(pidx);

if any(t0) && ~any(strcmpi(par_type, {'regular' 'singular'}))
  opts = coco_add_func(opts, fid, ...
    @func_PARS, @func_DPARSDX, [], ...
    par_type, par_names, 'xidx', pidx, 't0', t0);
else
  opts = coco_add_func(opts, fid, ...
    @func_PARS, @func_DPARSDX, [], ...
    par_type, par_names, 'xidx', pidx);
end

end

function opts = add_pars(opts, fid, par_names, pvals, par_type)

assert(~any(strcmpi(par_type, {'zero' 'regular' 'singular'})), ...
  '%s: parameter type must be one of active, inactive or internal', ...
  mfilename);

if ischar(par_names)
  par_names = { par_names };
end

opts = coco_add_func(opts, fid, ...
  @func_PARS, @func_DPARSDX, [], ...
  par_type, par_names, 'x0', pvals);

end

function [data g] = func_PARS(opts, data, xp) %#ok<INUSL>
g = xp;
end

function [data J] = func_DPARSDX(opts, data, xp)  %#ok<INUSL>
J = speye(size(xp,1));
end
