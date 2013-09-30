function [coll J] = var_DFDX(opts, coll, xp) %#ok<INUSL>
%Compute linearisation of extended collocation system at (x,M,p).

%% initialisations
% extract x and p from xp
x = xp(coll.x_idx,1);
p = xp(coll.p_idx,1);

%  map base points to collocation points
xx = reshape(coll.W   * x, coll.xshape);
M  = coll.MW  * x;
MM = reshape(M(coll.mcolidx), coll.mshape);

%  expand array of parameters to fit size of xx
pp = repmat(p, [1 coll.xshape(2)]);

%  extract T and kappa from x (and coll)
T  = x(coll.tintidx);
ka = coll.ka;

%% compute vector field and commonly used derivatives
%  preallocate arrays for (linearisations of) vector fields
F   = zeros(coll.xshape);

J   = zeros([coll.xshape(1) coll.xshape]);
JM  = zeros([coll.xshape coll.xshape(1)]);
J2M = zeros([coll.xshape coll.xshape([1 1])]);

FP  = zeros([coll.xshape length(p)]);
JPM = zeros([coll.xshape coll.xshape(1) length(p)]);

%  compute linearisation of each vector field
for rhsnum=1:length(coll.rhss)
	% Note: this needs to be modified to perform tests as in
	% exacont/private/func_DFDX
  xcolidx = coll.rhss(rhsnum).xcolidx;
  F(:,xcolidx) = ...
		coll.rhss(rhsnum).fhan(xx(:,xcolidx), pp(:,xcolidx));
  [J(:,:,xcolidx) JM(:,xcolidx,:) J2M(:,xcolidx,:,:)] = ...
		coco_num_D2FDX2(coll.rhss(rhsnum).fhan, ...
			xx(:,xcolidx), pp(:,xcolidx), MM(:,xcolidx,:));
  [FP(:,xcolidx,:) JPM(:,xcolidx,:,:)] = ...
		coco_num_D2FDP2(coll.rhss(rhsnum).fhan, ...
			xx(:,xcolidx), pp(:,xcolidx), 1:length(p), MM(:,xcolidx,:));
end

%% for debugging purposes:
% evaluate this line to compute finite difference approximation
% of linearisation
% [opts JJ] = coco_num_DFDX(opts, @var_F, xp); %#ok<NASGU>

%% compute linearisation of collocation system and variational equation
[coll J1] = var_coll_DFDX(coll, T, ka, F, J, FP, length(x));
[coll J2] = var_var_DFDX (coll, T, ka, M, J, JM, J2M, JPM, length(x));

% isfield(opts.cont, 'It') && opts.cont.It>=11
J = [J1 ; J2];

% [opts JJ] = coco_num_DFDX(opts, @var_F, xp);
% figure(1); spy( abs(J-JJ)>1.0e-4 );
% figure(2); spy(JJ);

end

function [coll J dfode] = var_coll_DFDX(coll, T, ka, F, J, FP, ncols)
%Compute linearisation COLL_DFDX of collocation system at (X,P).

%% initialisations
%  definition of some temporary variables
rows = [];
cols = [];
vals = [];
off  = 0;

%% compute linearisation of collocation condition wrt. x
%  expand T and ka to fit size of J
TT    = reshape(T(coll.tintdxidx), [coll.xshape(1) coll.xshape]);
kka   = reshape(ka(coll.kadxidx),  [coll.xshape(1) coll.xshape]);

%  linearisation of rescaled ODE
dfode = reshape( TT .* kka .* J, [prod(coll.dxshape) 1]);
dfode = sparse(coll.dxrows, coll.dxcols, dfode);

%  linearisation of collocation condition
%  ( = dfodes * W - Wp [chain rule])
dfode = dfode * coll.W - coll.Wp;
[r c v] = find(dfode);
rows = [rows ; off + r];
cols = [cols ; c];
vals = [vals ; v];

%% compute linearisation of collocation condition wrt. T
%  expand ka to fit size of F
kka   = reshape(ka(coll.kaxidx), coll.xshape);

%  compute linearisation and append data to rows, cols and vals
fode = kka .* F;
r    = (1:prod(coll.xshape))';
c    = coll.tintidx(coll.tintxidx);
c    = reshape(c, [prod(coll.xshape) 1]);
fode = reshape(fode, [prod(coll.xshape) 1]);

rows = [rows ; off + r];
cols = [cols ; c];
vals = [vals ; fode];

%% compute linearisation of collocation condition wrt. parameters
%  expand T and ka to fit size of FP
TT    = reshape(T(coll.tintxidx), coll.xshape);
kka   = reshape(ka(coll.kaxidx),  coll.xshape);
TT    = repmat(TT,  [1 1 size(FP, 3)]);
kka   = repmat(kka, [1 1 size(FP, 3)]);

%  compute linearisation and append data to rows, cols and vals
dfode = reshape(TT .* kka .* FP, [size(FP, 1)*size(FP, 2) size(FP, 3)]);

[r c v] = find(dfode);
rows = [rows ; off + r];
cols = [cols ; ncols + c];
vals = [vals ; v];

off  = off + prod(coll.xshape);

%% linearisation of continuity condition
[r c v] = find(coll.Phi);
rows = [rows ; off + r];
cols = [cols ; c];
vals = [vals ; v];

off  = off + size(coll.Phi,1);

%% Create sparse matrix of linearisation
%  Note: this will become re-ordered in the future to reduce band width.
J = sparse(rows, cols, vals, off, ncols+size(FP,3));

end

function [coll J] = var_var_DFDX(coll, T, ka, M, J, JM, J2M, JPM, ncols)
%Compute linearisation of variational equation at (M,beta).

%  definition of some temporary variables
rows = [];
cols = [];
vals = [];
off  = 0;

%% compute linearisation of variational system wrt. x
%  expand ka to fit size of J2M
mcolidx = repmat(coll.mcolidx,  [1 1 1 size(J2M, 4)]);
[n1 n2 n3 n4] = size(J2M);
% mcolidx = coll.mcolidx;
% mcolidx = reshape(coll.mcolidx, [n1 n2 n3 1]);
% mcolidx = repmat(mcolidx,  [1 1 1 n4]);
% mcolidx = permute(coll.mcolidx, [1 2 3]);
% mcolidx = reshape(mcolidx(coll.midx), size(J2M));
% mcolidx = reshape(mcolidx(coll.midx), size(J2M));
kkamidx = reshape(coll.kamidx(mcolidx), size(J2M));
TT      = reshape(T(kkamidx),  size(J2M));
kka     = reshape(ka(kkamidx), size(J2M));

%  bug: replace kamidx with tintmidx as soon as possible
% TTxidx  = reshape(coll.tintmidx, [size(JM,1) size(JM,3) size(JM,2)]);
% TTxidx  = permute(TTxidx, [1 3 2]);

%  compute linearisation and append data to rows, cols and vals
% dfode   = permute(kka .* JM, [1 3 2]);
dfode   = TT .* kka .* J2M;
dfode   = reshape(dfode, [n1*n2*n3 n4]);
dfode(coll.mcolidx,:) = dfode;
dfode   = reshape(dfode, [n1 n2 n3 n4]);
dfode   = permute(dfode, [1 4 2 3]);
dfode   = reshape(dfode, numel(J2M), 1);
dfode   = sparse(coll.dmrows, coll.dmcols, dfode);
dfode   = dfode*coll.MW;
[r c v] = find(dfode);
c       = coll.dmcoltr(c);

rows = [rows ; off + r];
cols = [cols ; c];
vals = [vals ; v];

%% compute linearisation of variational system wrt. M
%  expand T and ka to fit size of J
TT    = reshape(T(coll.tintdxidx), [coll.xshape(1) coll.xshape]);
kka   = reshape(ka(coll.kadxidx),  [coll.xshape(1) coll.xshape]);

%  linearisation of rescaled ODE
dfode = reshape( TT .* kka .* J, [prod(coll.dxshape) 1]);
dfode = reshape(dfode(coll.midx), [prod(coll.dmshape) 1]);
dfode = sparse(coll.dmrows, coll.dmcols, dfode);
dfode = dfode*coll.MW  - coll.MWp;
[r c v] = find(dfode);
rows = [rows ; off + r];
cols = [cols ; c];
vals = [vals ; v];

%% compute linearisation of variational system wrt. T
%  expand ka to fit size of JM
kkaxidx = reshape(coll.kamidx(coll.mcolidx), coll.mshape);
kka     = reshape(ka(kkaxidx), coll.mshape);

%  bug: replace kamidx with tintmidx as soon as possible
% TTxidx  = reshape(coll.tintmidx, [size(JM,1) size(JM,3) size(JM,2)]);
% TTxidx  = permute(TTxidx, [1 3 2]);

%  compute linearisation and append data to rows, cols and vals
% dfode   = permute(kka .* JM, [1 3 2]);
dfode   = kka .* JM;
dfode   = reshape(dfode, numel(JM), 1);
r       = reshape(coll.mcolidx, numel(coll.mcolidx), 1);
c       = reshape(coll.tintidx(kkaxidx),  numel(kkaxidx),  1);

rows = [rows ; off + r];
cols = [cols ; c];
vals = [vals ; dfode];

%% compute linearisation of variational system wrt. parameters
%  expand ka to fit size of JPM
mcolidx = repmat(coll.mcolidx,  [1 1 1 size(JPM, 4)]);
kkamidx = reshape(coll.kamidx(mcolidx), size(JPM));
TT      = reshape(T(kkamidx),  size(JPM));
kka     = reshape(ka(kkamidx), size(JPM));

%  bug: replace kamidx with tintmidx as soon as possible
% TTxidx  = reshape(coll.tintmidx, [size(JM,1) size(JM,3) size(JM,2)]);
% TTxidx  = permute(TTxidx, [1 3 2]);

%  compute linearisation and append data to rows, cols and vals
% dfode   = permute(kka .* JM, [1 3 2]);
dfode   = TT .* kka .* JPM;
dfode   = reshape(dfode, numel(JPM), 1);
r       = reshape(mcolidx, numel(JPM), 1);
c       = reshape(1:size(JPM,4), [1 1 1 size(JPM,4)]);
c       = repmat(c, [size(JPM,1) size(JPM,2) size(JPM,3) 1]);
c       = reshape(c, numel(JPM), 1);

rows = [rows ; off + r];
cols = [cols ; ncols + c];
vals = [vals ; dfode];

off  = off + size(coll.MWp,1);

%% linearisation of continuity condition
[r c v] = find(coll.MPhi);
rows = [rows ; off + r];
cols = [cols ; c];
vals = [vals ; v];
off  = off + size(coll.MPhi,1);

%% linearisation of boundary condition
M0idx = reshape(coll.m0idx, [prod(coll.m0shape) 1]);
M1idx = reshape(coll.m1idx, [prod(coll.m1shape) 1]);

rows = [rows ; off + (1:length(M0idx))' ; off + (1:length(M1idx))'];
cols = [cols ; M0idx ; M1idx];
vals = [vals ; ones(length(M0idx)+length(M1idx), 1) ];

iw   = coll.iw(coll.kamidx);
WMal = coll.MW'*(iw.*reshape(M, numel(M), 1));
WMal = WMal(coll.dmidx);
WM   = sparse(coll.dmrows2, coll.dmcols2, WMal);
WMal = sparse(coll.dmrows1, coll.dmcols1, WMal);

[r c v] = find(WMal + WM);
rows = [rows ; off + r];
cols = [cols ; c];
vals = [vals ; v];

off  = off + size(WM,1);

%% Create sparse matrix of linearisation
%  Note: this will become re-ordered in the future to reduce band width.
J = sparse(rows, cols, vals, off, ncols+size(JPM,4));

% for timing tests (no improvement):
% J = sparse(rows, cols, vals, coll.fullsize, coll.fullsize, numel(vals));
end
