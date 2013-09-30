function [opts coll] = var_amendMeshSegments(opts, coll, var_seglist)
%Create a list of collocation systems over all segments.

% copy seglist from collocation system; will be amended here
seglist = coll.segs;

% we build the list of segments in segs
segs    = [];

% amend collocation system over each segment
for segnum = 1:length(seglist)
	seg  = var2_amendMeshSegment(seglist(segnum), var_seglist(segnum));
	segs = [ segs ; seg ]; %#ok<AGROW>
end

% re-initialise the segs property of class coll
coll.segs = segs;

function seg = var2_amendMeshSegment(seg, vseg)
%Copy segment information and expand as necessary.

seg.iw = 2*seg.ka/seg.NCOL;

%% copy initial solution
dim  = seg.dim;
NCOL = seg.NCOL;
NTST = seg.NTST;

seg.M = reshape(vseg.M, [dim*dim*(NCOL+1)*NTST 1]);

%% compute index sets
%  Note: The index computations below are for simplifying and speeding up
%  the evaluation of the collocation system and contain frequently used
%  information.

%  compute a set of indices and shapes
seg.malidx   = (1:dim*dim*(NCOL+1)*NTST); % indices of coeffs. of Lag. polys.
seg.malshape = [dim*(NCOL+1) NTST dim];   % shape of array of coeffs. of Lag. polys.
seg.mbpshape = [dim (NCOL+1)*NTST dim];   % shape of solution at base points
seg.mcolidx  = 1:dim*NTST*NCOL;           % indices of coll. points
seg.dmcolidx = 1:dim*dim*NTST*NCOL;       % indices of differentials of coll. points
seg.mshape   = [dim NTST*NCOL dim];       % shape of array of coll. points
seg.dmshape  = [dim dim*dim*NTST*NCOL];   % shape of array of diff. of coll. points
seg.kamidx   = ones(prod(seg.mshape), 1); % indices of scaling factors
seg.kadmidx  = ones(seg.dmshape);         % indices of scaling factors for linearisation
%  Note: the scaling factors ka will become part of the unknowns x. This
%  will affect the index sets seg.kaxidx and seg.kadxidx.

%  compute indices for assigning the linearisation of the vector field
%  to a block-diagonal matrix
dmrows     = reshape(1:dim*dim*NTST*NCOL, [dim 1 dim*NCOL*NTST]);
dmrows     = repmat(dmrows, [1 dim 1]);
seg.dmrows = reshape(dmrows, [dim*dim*dim*NCOL*NTST 1]);

dmcols     = reshape(1:dim*dim*NTST*NCOL, [1 dim dim*NCOL*NTST]);
dmcols     = repmat(dmcols, [dim 1 1]);
seg.dmcols = reshape(dmcols, [dim*dim*dim*NCOL*NTST 1]);

%  number of vars = #coefficients, ka will become a variable as well
seg.mvarnum = dim*dim*(NCOL+1)*NTST;
seg.kanum   = 1;

%  indices of initial points
ipidx     = reshape(seg.malidx, seg.malshape);
ipidx     = ipidx(1:dim, :,:);
seg.m0idx = reshape(ipidx(:,1,:), dim*dim, 1);
ipidx     = reshape(ipidx(:, 2:end, :), [1 dim*dim*(NTST-1)]);

%  indices of end points
epidx     = reshape(seg.malidx, seg.malshape);
epidx     = epidx(dim*NCOL+1:end, :,:);
seg.m1idx = reshape(epidx(:,end,:), dim*dim, 1);
epidx     = reshape(epidx(:,1:end-1,:), [1 dim*dim*(NTST-1)]);

%  indices of internal points and linear map MPhi of continuity condition
rows     = [1:dim*dim*(NTST-1) 1:dim*dim*(NTST-1)];
cols     = [ipidx epidx];
vals     = [-ones(1,dim*dim*(NTST-1)) ones(1,dim*dim*(NTST-1))];
seg.MPhi = sparse(rows, cols, vals, dim*dim*(NTST-1), dim*dim*(NCOL+1)*NTST);

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

%  boundary condition
seg.mbceye  = reshape(3*eye(dim,dim), [dim*dim 1]);

%% initialise point- and derivative-maps
%  row and column indices for constructing block-diagonal linear mappings
%  MW  : interpolation points to collocation points
%  MWp : interpolation points to time-derivatives at collocation points

rows = reshape((1:dim*dim*NCOL*NTST), [dim*NCOL 1 dim*NTST]);
rows = repmat(rows, [1 dim*(NCOL+1) 1]);
rows = reshape(rows, [dim*(NCOL+1)*dim*NCOL*dim*NTST 1]);

cols = reshape(seg.malidx, [1 dim*(NCOL+1) dim*NTST]);
cols = repmat(cols, [dim*NCOL 1 1]);
cols = reshape(cols, [dim*(NCOL+1)*dim*NCOL*dim*NTST 1]);

%  compute the point-map and the derivative-map for the full collocation
%  system on this segment
vals    = reshape(repmat(seg.pmap, [1 dim*NTST]), [dim*(NCOL+1)*dim*NCOL*dim*NTST 1]);
seg.MW  = sparse(rows, cols, vals, dim*NCOL*dim*NTST, dim*(NCOL+1)*dim*NTST);

vals    = reshape(repmat(seg.dmap, [1 dim*NTST]), [dim*(NCOL+1)*dim*NCOL*dim*NTST 1]);
seg.MWp = sparse(rows, cols, vals, dim*NCOL*dim*NTST, dim*(NCOL+1)*dim*NTST);
