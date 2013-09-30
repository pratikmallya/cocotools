function [data res] = var_save_full(opts, data, pt1, varargin) %#ok<INUSL>
%  Add plotting and restart data to class DATA.

if nargout<2
	error('%s: too few output arguments', mfilename);
end

coll = data.coll;

x  = pt1.x(coll.x_idx);
p0 = pt1.x(coll.p_idx);
T  = x(coll.tintidx);

% create and save seglist for restarts and
% compute solution at base points for plots
sol.seglist = data.seglist;
sol.p0      = p0;
segs         = coll.segs;
xbp          = [];
tbp          = [];
tbp0         = 0;
M            = [];
M0           = [];
M1           = [];
f0           = [];
f1           = [];

for segnum = 1:numel(sol.seglist)
  % save x
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

	f0  = [f0 segs(segnum).fhan(al(segs(segnum).x0idx), p0)]; %#ok<AGROW>
	f1  = [f1 segs(segnum).fhan(al(segs(segnum).x1idx), p0)]; %#ok<AGROW>
	
  % save M
	malidx   = segs(segnum).midxoff + segs(segnum).malidx;
	mbpshape = segs(segnum).mbpshape;
  mm       = x(malidx);
	sol.seglist(segnum).M  = reshape(mm, mbpshape);
  m0shape = mbpshape;
  m0shape(2) = 1;
  sol.seglist(segnum).M0 = reshape(mm(segs(segnum).m0idx), m0shape);
  sol.seglist(segnum).M1 = reshape(mm(segs(segnum).m1idx), m0shape);
	
  M  = [M  sol.seglist(segnum).M ]; %#ok<AGROW>
  M0 = [M0 sol.seglist(segnum).M0]; %#ok<AGROW>
  M1 = [M1 sol.seglist(segnum).M1]; %#ok<AGROW>
end

% save solution at all base points
sol.xbp  = xbp;
sol.tbp  = tbp;
sol.M    = M ;
sol.M0   = M0;
sol.M1   = M1;
sol.x0   = reshape(x(coll.x0idx), coll.x0shape);
sol.x1   = reshape(x(coll.x1idx), coll.x1shape);
sol.f0   = f0;
sol.f1   = f1;

% save solution at collocation points
sol.xcp  = reshape(coll.W  * x, coll.xshape);
sol.xcpp = reshape(coll.Wp * x, coll.xshape);

% save times of flight for all segments
sol.T    = T;

res     = data;
res.sol = sol;
