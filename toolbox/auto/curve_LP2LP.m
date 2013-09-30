function [opts argnum] = curve_LP2LP(opts, prefix, varargin)
% Parser of toolbox curve, starting at a saved solution point.

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
if ~any(strcmp(chart.pt_type, 'FP'))
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
tx = chart.t(data.u_idx(data.x_idx));

% call toolbox constructor for zero problem
opts = curve_create(opts, prefix, f, fx, fp, fdata, x0, p0, [], []);

% call toolbox constructor for fold condition
data = coco_get_func_data(opts, 'curve', 'data');
opts = curve_create_LP(opts, prefix, data, tx);

end
