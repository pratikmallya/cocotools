function [data res] = var1_save_full(opts, data, pt1, varargin) %#ok<INUSL>
%  Add restart data to class DATA.

if nargout<2
	error('%s: too few output arguments', mfilename);
end

coll = data.coll;
var1 = coll.var1;

x = pt1.x(var1.x_idx);

% create and save seglist for restarts and
% compute solution at base points for plots
res.seglist  = coll.segs;
segs         = var1.segs;
M            = [];
M0           = [];
M1           = [];

for segnum = 1:numel(res.seglist)
	alidx    = segs(segnum).varidxoff + segs(segnum).alidx;
	xbpshape = segs(segnum).xbpshape;
  xx       = x(alidx);
	res.seglist(segnum).M  = reshape(xx, xbpshape);
  x0shape = xbpshape;
  x0shape(2) = 1;
  res.seglist(segnum).M0 = reshape(xx(segs(segnum).x0idx), x0shape);
  res.seglist(segnum).M1 = reshape(xx(segs(segnum).x1idx), x0shape);
	
  M  = [M  res.seglist(segnum).M ]; %#ok<AGROW>
  M0 = [M0 res.seglist(segnum).M0]; %#ok<AGROW>
  M1 = [M1 res.seglist(segnum).M1]; %#ok<AGROW>
end

% save solution at all base points
res.M  = M ;
res.M0 = M0;
res.M1 = M1;
