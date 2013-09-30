function [opts coll] = coll_createMeshSegments(opts, coll, seglist, p0) %#ok<INUSD>
%Create a list of collocation systems over all segments.

% we build the list of segments in segs
segs    = [];

% create collocation system over each segment
for segnum = 1:length(seglist)
	fname = seglist(segnum).fname;
	NTST  = seglist(segnum).NTST;
	NCOL  = seglist(segnum).NCOL;
	seg   = coll_createMeshSegment(coll, seglist(segnum), segnum, fname, NTST, NCOL);
	segs  = [ segs ; seg ]; %#ok<AGROW>
end

% initialise the dim and segs properties of collocation structure
% in this implementation all segments have the same phase-space dimension
coll.dim     = segs(1).dim;
coll.segs    = segs;
coll.seglist = seglist;

function seg = coll_createMeshSegment(coll, iseg, segnum, fname, NTST, NCOL)
%Create a collocation system over one segment

%% set right-hand side and discretisation parameters
seg.fname = fname;
seg.NTST  = NTST;
seg.NCOL  = NCOL;

%% compute time meshes
%  compute interpolation- or base-points
seg.tk = lagrange_bpoints(NCOL+1, coll.bpdist);

%  compute Gauss nodes (collocation points)
seg.th   = gaussnodes(NCOL);

%  compute rescaling factor ka for standard element [-1,1]
seg.ka   = 0.5/NTST;

%  compute time mesh with times at the interpolation points
tt   = (0:NTST-1)' * (2*seg.ka);
t    = repmat(seg.tk, [NTST 1]);
t    = (t+1) * seg.ka;
t    = t + repmat(tt, [1 NCOL+1]);
t    = reshape(t', [NTST*(NCOL+1) 1]);
t    = t./t(end); % correct for roundoff in summation
seg.tbp  = t;

%% compute initial solution
% interpolate initial solution provided by the user
% at the interpolation points seg.tbp
if isfield(iseg, 't0') && ~isempty(iseg.t0)
	% the user gave T0 and X0
	t0    = iseg.t0;
	x0    = iseg.x0;
  if isfield(iseg, 's0')
    s0  = iseg.s0;
  else
    s0  = [];
  end

	[m n] = size(t0);
	if n ~= 1
		t0 = t0';
		m = size(t0,1);
	end

	[xm dim] = size(x0);
	if xm~=m
		x0 = x0';
		[xm dim] = size(x0); %#ok<ASGLU>
  end

  if ~isempty(s0)
    [sm sdim] = size(s0);
    if any([sm sdim]~=[m dim])
      s0 = s0';
    end
  end

	seg.tint = t0(end)-t0(1);
	t0       = (t0-t0(1))./seg.tint;
	x0       = interp1(t0, x0, seg.tbp)';
	x0       = reshape(x0, [dim*(NCOL+1)*NTST 1]);
	seg.x0   = [ x0 ; seg.tint ];
  if ~isempty(s0)
    s0       = interp1(t0, s0, seg.tbp)';
    s0       = reshape(s0, [dim*(NCOL+1)*NTST 1]);
    seg.s0   = [ s0 ; 0 ];
  end
else
	% the user gave a starting-point function STPNT
	if ischar(iseg.stpnt)
		stpnt = str2func(iseg.stpnt);
	else
		stpnt = iseg.stpnt;
	end
	t0    = t';
	[x0 seg.tint] = stpnt(segnum, t0);

	[m tm] = size(t0);
	if m ~= 1
		t0 = t0';
		[m tm] = size(t0); %#ok<ASGLU>
	end

	[dim xm] = size(x0);
	if xm~=tm
		x0 = x0';
		dim = size(x0, 1);
	end

	x0     = reshape(x0, [dim*(NCOL+1)*NTST 1]);
	seg.x0 = [ x0 ; seg.tint ];
end

% set phase-space dimension for this segment
seg.dim  = dim;

%% compute index sets
%  Note: The index computations below are for simplifying and speeding up
%  the evaluation of the collocation system and contain frequently used
%  information.

%  compute a set of indices and shapes
seg.alidx     = (1:dim*(NCOL+1)*NTST); % indices of coeffs. of Lag. polys.
seg.tintidx   = dim*(NCOL+1)*NTST+1;   % index of T
seg.alshape   = [dim*(NCOL+1) NTST];   % shape of array of coeffs. of Lag. polys.
seg.xcolidx   = 1:NTST*NCOL;           % indices of coll. points
seg.dxcolidx  = 1:dim*NTST*NCOL;       % indices of differentials of coll. points
seg.xshape    = [dim NTST*NCOL];       % shape of array of coll. points
seg.dxshape   = [dim dim*NTST*NCOL];   % shape of array of diff. of coll. points
seg.kaxidx    = ones(seg.xshape);      % indices of scaling factors
seg.kadxidx   = ones(seg.dxshape);     % indices of scaling factors for linearisation
%  Note: the scaling factors ka will become part of the unknowns x. This
%  will affect the index sets seg.kaxidx and seg.kadxidx.

%  compute indices for assigning the linearisation of the vector field
%  to a block-diagonal matrix
dxrows     = reshape(1:dim*NTST*NCOL, [dim 1 NCOL*NTST]);
dxrows     = repmat(dxrows, [1 dim 1]);
seg.dxrows = reshape(dxrows, [dim*dim*NCOL*NTST 1]);

dxcols     = reshape(1:dim*NTST*NCOL, [1 dim NCOL*NTST]);
dxcols     = repmat(dxcols, [dim 1 1]);
seg.dxcols = reshape(dxcols, [dim*dim*NCOL*NTST 1]);

%  number of vars = coefficients + 1, ka will become a variable as well
seg.varnum = dim*(NCOL+1)*NTST+1;
seg.kanum  = 1;

%  indices of initial points
ipidx     = reshape(seg.alidx, seg.alshape);
ipidx     = ipidx(1:dim, :);
seg.x0idx = ipidx(:,1);
ipidx     = reshape(ipidx(:, 2:end), [1 dim*(NTST-1)]);

%  indices of end points
epidx     = reshape(seg.alidx, seg.alshape);
epidx     = epidx(dim*NCOL+1:end, :);
seg.x1idx = epidx(:,end);
epidx     = reshape(epidx(:,1:end-1), [1 dim*(NTST-1)]);

%  indices of internal points and linear map Phi of continuity condition
rows    = [1:dim*(NTST-1) 1:dim*(NTST-1)];
cols    = [ipidx epidx];
vals    = [-ones(1,dim*(NTST-1)) ones(1,dim*(NTST-1))];
seg.Phi = sparse(rows, cols, vals, dim*(NTST-1), dim*(NCOL+1)*NTST+1);

%% initialise point- and derivative-maps
%  row and column indices for constructing block-diagonal linear mappings
%  W  : interpolation points to collocation points
%  Wp : interpolation points to time-derivatives at collocation points

rows = reshape((1:dim*NCOL*NTST), [dim*NCOL 1 NTST]);
rows = repmat(rows, [1 dim*(NCOL+1) 1]);
rows = reshape(rows, [dim*(NCOL+1)*dim*NCOL*NTST 1]);

cols = reshape(seg.alidx, [1 dim*(NCOL+1) NTST]);
cols = repmat(cols, [dim*NCOL 1 1]);
cols = reshape(cols, [dim*(NCOL+1)*dim*NCOL*NTST 1]);

%  compute the point-map and the derivative-map for one collocation interval
%  in this segment
seg.pmap = lagrange_pmap(dim, seg.tk, seg.th);
seg.dmap = lagrange_dmap(dim, seg.tk, seg.th);

%  compute the point-map and the derivative-map for the full collocation
%  system on this segment
vals  = reshape(repmat(seg.pmap, [1 NTST]), [dim*(NCOL+1)*dim*NCOL*NTST 1]);
seg.W = sparse(rows, cols, vals, dim*NCOL*NTST, dim*(NCOL+1)*NTST+1);

vals   = reshape(repmat(seg.dmap, [1 NTST]), [dim*(NCOL+1)*dim*NCOL*NTST 1]);
seg.Wp = sparse(rows, cols, vals, dim*NCOL*NTST, dim*(NCOL+1)*NTST+1);
