function [opts argidx] = coll_isol2sol(opts, oid, varargin)

data.tbid = coco_get_id(oid, 'coll');

% varargin = { @f [@dfdx [@dfdp]] t0 x0 p0 [mode [dx0]] ['end_coll'] }
argidx    = 1;
dx0       = [];
dT0       = [];
data.mode = [];

data.fhan    = varargin{argidx};
argidx       = argidx+1;
data.dfdxhan = [];
data.dfdphan = [];
if isa(varargin{argidx}, 'function_handle')
  data.dfdxhan = varargin{argidx};
  argidx       = argidx+1;
  if isa(varargin{argidx}, 'function_handle')
    data.dfdphan = varargin{argidx};
    argidx       = argidx+1;
  end
end

t0     = varargin{argidx  };
x0     = varargin{argidx+1};
p0     = varargin{argidx+2};
argidx = argidx+3;

if nargin-2>=argidx && (isnumeric(varargin{argidx}) || isstruct(varargin{argidx}))
  data.mode = varargin{argidx};
  argidx    = argidx+1;
  if nargin-2>=argidx && isnumeric(varargin{argidx})
    dx0    = varargin{argidx};
    argidx = argidx+1;
  end
end
if isempty(dx0)
  dx0 = zeros(size(x0,1),0);
else
  dT0 = 0;
end

if nargin-2>=argidx && ischar(varargin{argidx}) && strcmp('end_coll', varargin{argidx})
  argidx = argidx+1;
end

data.coll = coll_get_settings(opts, data.tbid);

coll_check(data.tbid, data, t0, x0, p0, dx0);

[data x0 dx0] = coll_system(data, t0, x0, p0, dx0, dT0);

opts = coll_create(opts, data, x0, p0, dx0);

end
