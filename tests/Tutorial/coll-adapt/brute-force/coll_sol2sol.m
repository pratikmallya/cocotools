function [opts argidx] = coll_sol2sol(opts, oid, varargin)

% varargin = { rrun [roid] rlab }

tbid = coco_get_id(oid, 'coll');

rrun = varargin{1};
if ischar(varargin{2})
  rtbid  = coco_get_id(varargin{2}, 'coll');
  rlab   = varargin{3};
  argidx = 4;
else
  rtbid  = tbid;
  rlab   = varargin{2};
  argidx = 3;
end

if argidx<=nargin-2 && strcmpi(varargin{argidx}, 'end_coll')
  argidx = argidx+1;
end

[data chart] = coco_read_solution(rtbid, rrun, rlab);
data.tbid    = tbid;

dim  = data.dim;
NCOL = data.coll.NCOL;
NTST = data.coll.NTST;

t0  = data.tbp*chart.x(data.Tidx);
t0  = t0(data.tbp_uidx);
x0  = reshape(chart.x(data.xbpidx), [dim (NCOL+1)*NTST])';
x0  = x0(data.tbp_uidx,:);
p0  = chart.x(data.p_idx);
dx0 = reshape(chart.t(data.xbpidx), [dim (NCOL+1)*NTST])';
dx0 = dx0(data.tbp_uidx,:);
dT0 = chart.t(data.Tidx);
dx0 = zeros(numel(data.tbp_uidx),0);
dT0 = [];

data.coll = coll_get_settings(opts, data.tbid);

[data x0 dx0] = coll_system(data, t0, x0, p0, dx0, dT0);

opts = coll_create(opts, data, x0, p0, dx0);

end
