function [coll J] = coll_DFDX(opts, coll, xp)
%Compute linearisation COLL_DFDX of collocation system at (X,P).

%% initialisations
% extract x and p from xp
x = xp(coll.x_idx,1);
p = xp(coll.p_idx,1);

%  definition of some temporary variables
rows = [];
cols = [];
vals = [];
off  = 0;

%  map base points to collocation points
xx = reshape(coll.W * x, coll.xshape);

%  expand array of parameters to fit size of xx
pp = repmat(p, [1 coll.xshape(2)]);

%  extract T from x
T  = x(coll.tintidx);

%% compute linearisation of collocation condition wrt. x
%  preallocate array for linearisation of vector fields
dfode = zeros(coll.dxshape);

%  compute linearisation of each vector field
for rhsnum=1:length(coll.rhss)
	% Note: this needs to be modified to perform tests as in
	% exacont/private/func_DFDX
	% dfode(:, coll.rhss(rhsnum).dxcolidx) = ...
	% 	coco_num_DFDXv(coll.rhss(rhsnum).fhan, ...
	% 		xx(:,coll.rhss(rhsnum).xcolidx), ...
	% 		pp(:,coll.rhss(rhsnum).xcolidx));
    
  xcolidx  = coll.rhss(rhsnum).xcolidx;
  dxcolidx = coll.rhss(rhsnum).dxcolidx;
  dfdxhan  = coll.rhss(rhsnum).dfdxhan;
  
  if isempty(dfdxhan)
    fhan = coll.rhss(rhsnum).fhan;
    if coll.rhss(rhsnum).vectorised
      dfode(:,dxcolidx) = coco_num_DFDXv(fhan, xx(:,xcolidx), pp(:,xcolidx));
    else
      dfode(:,dxcolidx) = coco_num_DFDX (fhan, xx(:,xcolidx), pp(:,xcolidx));
    end
  else
    % fhan = coll.rhss(rhsnum).fhan;
    % dfode(:,dxcolidx) = coco_num_DFDXv(fhan, xx(:,xcolidx), pp(:,xcolidx));
    dfode(:,dxcolidx) = reshape(...
      dfdxhan(xx(:,xcolidx), pp(:,xcolidx)), ...
      [size(dfode,1) size(dxcolidx,2)]);
  end
end

%  expand T and ka to fit size of d(xx)
T     = T(coll.tintdxidx);
ka    = coll.ka(coll.kadxidx);

%  compute linearisation of T .* ka .* fode with respect to xx
%  and convert into sparse matrix
dfode = T .* ka .* dfode;
dfode = reshape(dfode, [prod(coll.dxshape) 1]);
dfode = sparse(coll.dxrows, coll.dxcols, dfode);

%  compute linearisation with respect to x ( = dfode * W - Wp [chain rule])
%  and split resulting sparse matrix
dfode = dfode * coll.W - coll.Wp;
[r c v] = find(dfode);
rows = [rows ; off + r];
cols = [cols ; c];
vals = [vals ; v];

%% compute linearisation of collocation condition wrt. T
%  preallocate array for derivative with respect to T
fode = zeros(coll.xshape);

%  evaluate each vector field
for rhsnum=1:length(coll.rhss)
	fode(:, coll.rhss(rhsnum).xcolidx) = ...
		coll.rhss(rhsnum).fhan(xx(:,coll.rhss(rhsnum).xcolidx), ...
		pp(:,coll.rhss(rhsnum).xcolidx));
end

%  expand ka to fit size of xx
ka   = coll.ka(coll.kaxidx);

%  compute linearisation and append data to rows, cols and vals
fode = ka .* fode;
r    = (1:prod(coll.xshape))';
c    = coll.tintidx(coll.tintxidx);
c    = reshape(c, [prod(coll.xshape) 1]);
fode = reshape(fode, [prod(coll.xshape) 1]);

rows = [rows ; off + r];
cols = [cols ; c];
vals = [vals ; fode];
off  = off + prod(coll.xshape);

%% linearisation of continuity condition
[r c v] = find(coll.Phi);
rows = [rows ; off + r];
cols = [cols ; c];
vals = [vals ; v];
%off  = off + size(coll.Phi,1);

%% Create sparse matrix of linearisation
%  Note: this might become re-ordered in the future to reduce band width.
J1 = sparse(rows, cols, vals);

% for timing tests (no improvement):
% J1 = sparse(rows, cols, vals, coll.fullsize, coll.fullsize, numel(vals));

%% add derivatives wrt parameters
[coll J2] = coll_DFDP(opts, coll, x, p, 1:numel(p));

%% combine the two Jacobians
J = sparse([J1 J2]);

%% for debugging purposes:
% evaluate this line to compute finite difference approximation
% of linearisation
% [coll J1] = fdm_ezDFDX('f(o,d,x)', opts, coll, @coll_F, xp);

