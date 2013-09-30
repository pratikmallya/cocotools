function [opts argnum] = curve_sol2sol(opts, prefix, varargin)
% Parser of toolbox curve, starting at a saved solution point.

% varargin = { f [fx [fp]]   ['fdata' fdata] x0 p0 ... }
%          | { [f [fx [fp]]] ['fdata' fdata] RRUN RLAB ... }

f     = [];
fx    = [];
fp    = [];
fdata = {};
tx    = [];
tp    = [];

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

if ischar(varargin{argidx}) || iscell(varargin{argidx})
  rrun   = varargin{argidx};
  rlab   = varargin{argidx+1};
  argidx = argidx+2;
  fid = coco_get_id(prefix,'curve_save');
  [data chart] = coco_read_solution(fid, rrun, rlab);
  if isempty(f)
    f     = data.f;
    fx    = data.fx;
    fp    = data.fp;
    fdata = data.fdata;
  end
  x0 = chart.x(data.u_idx(data.x_idx));
  tx = chart.t(data.u_idx(data.x_idx));
  p0 = chart.x(data.u_idx(data.p_idx));
  tp = chart.t(data.u_idx(data.p_idx));
else
  x0 = varargin{argidx};
  p0 = varargin{argidx+1};
  argidx = argidx+2;
end

% return number of processed arguments
argnum = argidx;

% call toolbox constructor
opts = curve_create(opts, prefix, f, fx, fp, fdata, x0, p0, tx, tp);

end
