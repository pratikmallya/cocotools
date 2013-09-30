function [opts argidx] = coll_isol2sol(opts, oid, varargin)

data.tbid = coco_get_id(oid, 'coll');

argidx = 1;
data.fhan = varargin{argidx};

argidx  = argidx+1;
dfdxhan = [];
dfdphan = [];
mode    = struct();
dx0     = [];
count   = 0;
idata   = {};
while argidx<=nargin-2 && (count<3 || ischar(varargin{argidx}))
  if ischar(varargin{argidx})
    switch lower(varargin{argidx})
      case 'dfdx'
        dfdxhan = varargin{argidx+1};
        argidx = argidx + 2;
      case 'dfdp'
        dfdphan = varargin{argidx+1};
        argidx = argidx + 2;
      case 'mode'
        mode = varargin{argidx+1};
        argidx = argidx + 2;
      case 'tangent'
        dx0  = varargin{argidx+1};
        argidx = argidx + 2;
      case 'end_coll'
        argidx = argidx + 1;
        break
      otherwise
        break;
    end
  else
    idata  = [ idata varargin{argidx} ]; %#ok<AGROW>
    count  = count + 1;
    argidx = argidx + 1;
  end
end
data.dfdxhan = dfdxhan;
data.dfdphan = dfdphan;
data.mode    = mode;
assert(count==3, ...
  '%s: input for initial solution (t0,x0,p0) missing', data.tbid);
[t0 x0 p0]   = deal(idata{:});
if isempty(dx0)
  dx0 = zeros(size(x0,1),0);
  dT0 = [];
else
  dT0 = 0;
end

data.coll = coll_get_settings(opts, data.tbid);

coll_check(data.tbid, data, t0, x0, p0, dx0);

[data x0 dx0] = coll_system(data, t0, x0, p0, dx0, dT0);

opts = coll_create(opts, data, x0, p0, dx0);

end
