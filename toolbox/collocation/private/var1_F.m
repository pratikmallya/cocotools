function [coll f] = var1_F(opts, coll, xp) %#ok<INUSL>
%Evaluate variational equation at (M,beta).

var1 = coll.var1;

%% initialisations
% extract x and p from xp
x = xp(var1.x_idx,1);
p = xp(var1.p_idx,1);

%  map base points to derivative at collocation points
xp = reshape(var1.Wp * x, [prod(var1.xshape) 1]);

%% evaluate variational system
%  and reshape into a single column vector
fvar = p*(var1.dfode*x) - xp;

%% evaluate continuity condition
%  for all inner points
fcont = var1.Phi * x;

%% evaluate boundary condition
%  create sparse matrix with segments of M
M0idx = reshape(var1.x0idx, [prod(var1.x0shape) 1]);
M1idx = reshape(var1.x1idx, [prod(var1.x1shape) 1]);

M0   = x(M0idx);
M1   = x(M1idx);

iw   = var1.iw(var1.kaxidx);
WM   = var1.W*x;
WMal = iw.*WM;
WMal = sparse(var1.mrows, var1.mcols, WMal(var1.midx));
MM   = WMal*WM;

fbc  = M0 + M1 + MM - var1.mbceye;

%% combine all conditions
%  into one large vector
%  Note: this will become re-ordered in the future to reduce band width.
f = [ fvar ; fcont ; fbc ];
