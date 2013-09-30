function [opts coll] = var1_createMeshSegments(opts, coll)
%Create a list of collocation systems over all segments.

% copy seglist from collocation system; will not be altered here
seglist = coll.segs;

% we build the list of segments in segs
segs    = [];

% create collocation system over each segment
for segnum = 1:length(seglist)
	seg   = var1_createMeshSegment(seglist(segnum));
	segs  = [ segs ; seg ]; %#ok<AGROW>
end

% initialise the dim and segs properties of collocation structure
% in this implementation all segments have the same phase-space dimension
coll.var1.dim  = segs(1).dim;
coll.var1.segs = segs;

function seg = var1_createMeshSegment(iseg)
%Copy segment information and expand as necessary.

seg.fname = iseg.fname;
seg.NTST  = iseg.NTST;
seg.NCOL  = iseg.NCOL;
seg.ka    = iseg.ka;
seg.iw    = 2*iseg.ka/iseg.NCOL;
seg.tbp   = iseg.tbp;
seg.tint  = iseg.tint;
seg.dim   = iseg.dim;

%% set initial solution to unit matrix
dim  = iseg.dim;
NCOL = iseg.NCOL;
NTST = iseg.NTST;

seg.x0 = repmat(eye(dim,dim), [(NCOL+1)*NTST 1]);
seg.x0 = reshape(seg.x0, [dim*dim*(NCOL+1)*NTST 1]);

%% compute index sets
%  Note: The index computations below are for simplifying and speeding up
%  the evaluation of the collocation system and contain frequently used
%  information.

%  compute a set of indices and shapes
seg.alidx    = (1:dim*dim*(NCOL+1)*NTST); % indices of coeffs. of Lag. polys.
seg.alshape  = [dim*(NCOL+1) NTST dim];   % shape of array of coeffs. of Lag. polys.
seg.xbpshape = [dim (NCOL+1)*NTST dim];   % shape of solution at base points
seg.xcolidx  = 1:dim*NTST*NCOL;           % indices of coll. points
seg.dxcolidx = 1:dim*dim*NTST*NCOL;       % indices of differentials of coll. points
seg.xshape   = [dim dim*NTST*NCOL];       % shape of array of coll. points
seg.dxshape  = [dim dim*dim*NTST*NCOL];   % shape of array of diff. of coll. points
seg.kaxidx   = ones(prod(seg.xshape), 1); % indices of scaling factors
seg.kadxidx  = ones(seg.dxshape);         % indices of scaling factors for linearisation
%  Note: the scaling factors ka will become part of the unknowns x. This
%  will affect the index sets seg.kaxidx and seg.kadxidx.

%  compute indices for assigning the linearisation of the vector field
%  to a block-diagonal matrix
dxrows     = reshape(1:dim*dim*NTST*NCOL, [dim 1 dim*NCOL*NTST]);
dxrows     = repmat(dxrows, [1 dim 1]);
seg.dxrows = reshape(dxrows, [dim*dim*dim*NCOL*NTST 1]);

dxcols     = reshape(1:dim*dim*NTST*NCOL, [1 dim dim*NCOL*NTST]);
dxcols     = repmat(dxcols, [dim 1 1]);
seg.dxcols = reshape(dxcols, [dim*dim*dim*NCOL*NTST 1]);

%  number of vars = #coefficients, ka will become a variable as well
seg.varnum = dim*dim*(NCOL+1)*NTST;
seg.kanum  = 1;

%  indices of initial points
ipidx     = reshape(seg.alidx, seg.alshape);
ipidx     = ipidx(1:dim, :,:);
seg.x0idx = reshape(ipidx(:,1,:), dim*dim, 1);
ipidx     = reshape(ipidx(:, 2:end, :), [1 dim*dim*(NTST-1)]);

%  indices of end points
epidx     = reshape(seg.alidx, seg.alshape);
epidx     = epidx(dim*NCOL+1:end, :,:);
seg.x1idx = reshape(epidx(:,end,:), dim*dim, 1);
epidx     = reshape(epidx(:,1:end-1,:), [1 dim*dim*(NTST-1)]);

%  indices of internal points and linear map Phi of continuity condition
rows    = [1:dim*dim*(NTST-1) 1:dim*dim*(NTST-1)];
cols    = [ipidx epidx];
vals    = [-ones(1,dim*dim*(NTST-1)) ones(1,dim*dim*(NTST-1))];
seg.Phi = sparse(rows, cols, vals, dim*dim*(NTST-1), dim*dim*(NCOL+1)*NTST);

%  indices for assigning segments of M to a sparse matrix
mrows      = reshape(1:dim*dim, dim, dim);
mrows1     = reshape(mrows', dim*dim, 1);
mrows1     = mrows(mrows1)';
seg.mrows  = kron(mrows1, ones(1,dim*NCOL*NTST))';

mcols1     = reshape(1:dim*dim*NCOL*NTST, dim*NCOL*NTST, dim);
mcols1     = repmat(mcols1, dim, 1);
seg.mcols  = reshape(mcols1, dim*dim*dim*NCOL*NTST, 1);

seg.midx   = repmat(1:dim*dim*NCOL*NTST, 1, dim)';

dmrows      = reshape(1:dim*dim, dim, dim);
dmrows1     = reshape(dmrows', dim*dim, 1);
dmrows1     = mrows(dmrows1)';
seg.dmrows1 = kron(dmrows1, ones(1,dim*(NCOL+1)*NTST))';

dmcols1     = reshape(1:dim*dim*(NCOL+1)*NTST, dim*(NCOL+1)*NTST, dim);
dmcols1     = repmat(dmcols1, dim, 1);
seg.dmcols1 = reshape(dmcols1, dim*dim*dim*(NCOL+1)*NTST, 1);

seg.dmrows2 = kron(1:dim*dim, ones(1,dim*(NCOL+1)*NTST))';
seg.dmcols2 = seg.dmcols1;

seg.dmidx   = repmat(1:dim*dim*(NCOL+1)*NTST, 1, dim)';

%  subscripts for extracting boundary data from block diagonal matrix
seg.mbceye  = reshape(3*eye(dim,dim), [dim*dim 1]);

%% initialise point- and derivative-maps
%  row and column indices for constructing block-diagonal linear mappings
%  W  : interpolation points to collocation points
%  Wp : interpolation points to time-derivatives at collocation points

rows = reshape((1:dim*dim*NCOL*NTST), [dim*NCOL 1 dim*NTST]);
rows = repmat(rows, [1 dim*(NCOL+1) 1]);
rows = reshape(rows, [dim*(NCOL+1)*dim*NCOL*dim*NTST 1]);

cols = reshape(seg.alidx, [1 dim*(NCOL+1) dim*NTST]);
cols = repmat(cols, [dim*NCOL 1 1]);
cols = reshape(cols, [dim*(NCOL+1)*dim*NCOL*dim*NTST 1]);

%  compute the point-map and the derivative-map for the full collocation
%  system on this segment
vals   = reshape(repmat(iseg.pmap, [1 dim*NTST]), [dim*(NCOL+1)*dim*NCOL*dim*NTST 1]);
seg.W  = sparse(rows, cols, vals, dim*NCOL*dim*NTST, dim*(NCOL+1)*dim*NTST);

vals   = reshape(repmat(iseg.dmap, [1 dim*NTST]), [dim*(NCOL+1)*dim*NCOL*dim*NTST 1]);
seg.Wp = sparse(rows, cols, vals, dim*NCOL*dim*NTST, dim*(NCOL+1)*dim*NTST);
