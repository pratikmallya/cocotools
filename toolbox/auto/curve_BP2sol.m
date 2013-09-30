function [opts argnum] = curve_BP2sol(opts, prefix, varargin)
% Parser of toolbox curve, starting at a branch point.

% varargin = { [f [fx [fp]]] ['fdata' fdata] RRUN RLAB ... }

f     = [];
fx    = [];
fp    = [];
fdata = {};

argidx = 1;
if isa(varargin{argidx}, 'function_handle')
  f = varargin{argidx};
  argidx = argidx+1;
  if isa(varargin{argidx}, 'function_handle')
    fx = varargin{argidx};
    argidx = argidx+1;
    if isa(varargin{argidx}, 'function_handle')
      fp = varargin{argidx};
      argidx = argidx+1;
    end
  end
end

if ischar(varargin{argidx}) && strcmpi(varargin{argidx},'fdata')
  fdata  = varargin{argidx+1};
  argidx = argidx+2;
end

rrun   = varargin{argidx};
rlab   = varargin{argidx+1};
argidx = argidx+2;
argnum = argidx;

fid = coco_get_id(prefix,'curve_save');
[data chart] = coco_read_solution(fid, rrun, rlab);
if strcmp(chart.pt_type, 'BP')
  cdata = coco_get_chart_data(chart, 'lsol');
  if isempty(cdata) || ~isfield(cdata, 'v')
    error('%s: cannot restart because linear solver did not save null vector', ...
      mfilename);
  else
    t = cdata.v;
  end
else
  error('%s: solution point run ''%s'' label %d is not a branch point', ...
    mfilename, rrun, rlab);
end

if isempty(f)
  f     = data.f;
  fx    = data.fx;
  fp    = data.fp;
  fdata = data.fdata;
end
x0 = chart.x(data.u_idx(data.x_idx));
p0 = chart.x(data.u_idx(data.p_idx));
tx = t(data.u_idx(data.x_idx));
tp = t(data.u_idx(data.p_idx));

% make small step in direction of [tx;tp]
h = coco_get(opts, 'cont.h0');
if isstruct(h)
  h = 0.001;
else
  h = 0.5*h;
end
x0 = x0 + h*tx;
p0 = p0 + h*tp;

% call toolbox constructor
opts = curve_create(opts, prefix, f, fx, fp, fdata, x0, p0, tx, tp);

end
