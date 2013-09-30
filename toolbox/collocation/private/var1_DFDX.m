function [coll J] = var1_DFDX(opts, coll, xp) %#ok<INUSL>
%Compute linearisation of variational equation at (M,beta).

var1 = coll.var1;

%% initialisations
% extract x and p from xp
x = xp(var1.x_idx,1);
p = xp(var1.p_idx,1);

%% for debugging purposes:
% evaluate this line to compute finite difference approximation
% of linearisation
% [opts J1] = coco_num_DFDX(opts, @var1_F, xp); %#ok<NASGU>

%  definition of some temporary variables
rows = [];
cols = [];
vals = [];
off  = 0;

%% compute linearisation of variational system wrt. (x,p)
dfode = [p*var1.dfode - var1.Wp var1.dfode*x];
[r c v] = find(dfode);
rows = [rows ; off + r];
cols = [cols ; c];
vals = [vals ; v];
off  = off + size(var1.Wp,1);

%% linearisation of continuity condition
[r c v] = find(var1.Phi);
rows = [rows ; off + r];
cols = [cols ; c];
vals = [vals ; v];
off  = off + size(var1.Phi,1);

%% linearisation of boundary condition
M0idx = reshape(var1.x0idx, [prod(var1.x0shape) 1]);
M1idx = reshape(var1.x1idx, [prod(var1.x1shape) 1]);

rows = [rows ; off + (1:length(M0idx))' ; off + (1:length(M1idx))'];
cols = [cols ; M0idx ; M1idx];
vals = [vals ; ones(length(M0idx)+length(M1idx), 1) ];

iw   = var1.iw(var1.kaxidx);
xx   = var1.W'*(iw.*(var1.W*x));
xx   = xx(var1.dmidx);
WMal = sparse(var1.dmrows1, var1.dmcols1, xx);
WM   = sparse(var1.dmrows2, var1.dmcols2, xx);

[r c v] = find(WMal + WM);
rows = [rows ; off + r];
cols = [cols ; c];
vals = [vals ; v];
%off  = off + size(Jbc,1);

%% Create sparse matrix of linearisation
%  Note: this will become re-ordered in the future to reduce band width.
J = sparse(rows, cols, vals);

% for timing tests (no improvement):
% J = sparse(rows, cols, vals, opts.var1.fullsize, opts.var1.fullsize, numel(vals));
