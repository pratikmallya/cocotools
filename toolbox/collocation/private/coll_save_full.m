function [data res] = coll_save_full(opts, data, pt1, varargin) %#ok<INUSL>
%  Add plotting and restart data to class DATA.

if nargout<2
	error('%s: too few output arguments', mfilename);
end

coll = data.coll;
uu = pt1.x(data.xidx);
x  = uu(coll.x_idx);
p0 = uu(coll.p_idx);
% al = reshape(x(coll.alidx), coll.alshape);
xx = reshape(coll.W  * x, coll.xshape);
xp = reshape(coll.Wp * x, coll.xshape);
T  = x(coll.tintidx);

% create and save seglist for restarts and
% compute solution at base points for plots
sol.seglist = data.seglist;
sol.p0      = p0;
segs         = coll.segs;
xbp          = [];
tbp          = [];
tbp0         = 0;
for segnum = 1:numel(sol.seglist)
	alidx    = segs(segnum).varidxoff + segs(segnum).alidx;
	alshape  = segs(segnum).alshape;
	al       = reshape(x(alidx), alshape);
	x0       = al(1:end-segs(segnum).dim, :);
	x0shape  = [segs(segnum).dim segs(segnum).NCOL*segs(segnum).NTST];
	sol.seglist(segnum).x0 = reshape(x0, x0shape);
	sol.seglist(segnum).x0 = [sol.seglist(segnum).x0 al(end-segs(segnum).dim+1:end)'];
	
	t0shape = [segs(segnum).NCOL+1 segs(segnum).NTST];
	t0      = reshape(tbp0 + segs(segnum).tbp'*T(segnum), t0shape);
	te      = t0(end);
	t0      = t0(1:end-1,:);
	sol.seglist(segnum).t0 = [t0(:)' te];
	tbp0    = tbp0 + T(segnum);
	
	xbp = [xbp sol.seglist(segnum).x0]; %#ok<AGROW>
	tbp = [tbp sol.seglist(segnum).t0]; %#ok<AGROW>
end

% save solution at all base points
sol.xbp  = xbp;
sol.tbp  = tbp;

% save solution at collocation points
sol.xcp  = reshape(xx, coll.xshape);
sol.xcpp = reshape(xp, coll.xshape);

% save times of flight for all segments
sol.T    = T;

res     = data;
res.sol = sol;
