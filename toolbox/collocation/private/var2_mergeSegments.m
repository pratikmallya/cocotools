function [opts coll x0] = var2_mergeSegments(opts, coll, x0)
%Create the full collocation system by merging all segments.

% segs contains the list of collocation systems and will not be altered
% here, dim is the common phase-space dimension of all segments
segs = coll.segs;
dim  = coll.dim;

% initialise all variables
fullsize  = length(x0);  % (column) dimension of full linearisation
MW        = sparse(0,fullsize); % combined point map
MWp       = sparse(0,fullsize); % combined derivatives map
MPhi      = sparse(0,fullsize); % combined continuity condition
iw        = [];          % Gauss integration weights
kamidx    = [];          % indices for expanding ka to size xshape
kadmidx   = [];          % indices for expanding ka to size dxshape
dmrows    = [];          % row indices for Jacobians of vector fields
dmcols    = [];          % column indices for Jacobians of vector fields
mshape    = [dim 0 dim]; % shape of array of collocation points
dmshape   = [dim 0];     % shape of array of Jacobians of vector fields
mrows     = [];          % row indices for norm condition on M
mcols     = [];          % column indices for norm condition on M
midx      = [];          % indices for expanding M
dmrows1   = [];          % row indices for norm condition on M
dmcols1   = [];          % column indices for norm condition on M
dmrows2   = [];          % row indices for norm condition on M
dmcols2   = [];          % column indices for norm condition on M
dmidx     = [];          % indices for expanding M
mbceye    = [];          % right-hand side of norm condition on M
m0idx     = [];          % indices of initial points of segments
m1idx     = [];          % indices of end points of segments
midxoff   = length(x0);  % offset of indices of variables in segment
dmcoff    = midxoff;     % offset of columns in norm condition on M
kaidxoff  = 0;           % offset of indices of ka in segment

% merge index sets and matricies into large index sets and matrices
% encoding the full collocation system over all segments
for segnum = 1:length(segs)
	segs(segnum).midxoff = midxoff;
	
	NTST = segs(segnum).NTST;
	NCOL = segs(segnum).NCOL;
	
	% increase fullsize by size of block
	fullsize = fullsize + dim*dim * NTST * (NCOL+1);
	
	% amend point map MW
	[rows, cols, vals] = find(segs(segnum).MW);
	dims = size(segs(segnum).MW);
	[r, c, v] = find(MW);
	d  = size(MW);
	r  = [r ; rows+d(1)]; %#ok<AGROW>
	c  = [c ; cols+d(2)]; %#ok<AGROW>
	v  = [v ; vals]; %#ok<AGROW>
	MW = sparse(r, c, v, d(1)+dims(1), d(2)+dims(2));

	% amend derivatives map MWp
	[rows, cols, vals] = find(segs(segnum).MWp);
	dims = size(segs(segnum).MWp);
	[r, c, v] = find(MWp);
	d   = size(MWp);
	r   = [r ; rows+d(1)]; %#ok<AGROW>
	c   = [c ; cols+d(2)]; %#ok<AGROW>
	v   = [v ; vals]; %#ok<AGROW>
	MWp = sparse(r, c, v, d(1)+dims(1), d(2)+dims(2));

	% amend continuity condition MPhi
	[rows, cols, vals] = find(segs(segnum).MPhi);
	dims = size(segs(segnum).MPhi);
	[r, c, v] = find(MPhi);
	d    = size(MPhi);
	r    = [r ; rows+d(1)]; %#ok<AGROW>
	c    = [c ; cols+d(2)]; %#ok<AGROW>
	v    = [v ; vals]; %#ok<AGROW>
	MPhi = sparse(r, c, v, d(1)+dims(1), d(2)+dims(2));
	
	% amend ka and index sets for ka
	iw      = [ iw ; segs(segnum).iw ]; %#ok<AGROW>
	kamidx  = [kamidx  ; kaidxoff + segs(segnum).kamidx ]; %#ok<AGROW>
	kadmidx = [kadmidx   kaidxoff + segs(segnum).kadmidx]; %#ok<AGROW>
	
	% amend index sets and shapes
	dmrows   = [dmrows  ; max([0 ; dmrows ]) + segs(segnum).dmrows ]; %#ok<AGROW>
	dmcols   = [dmcols  ; max([0 ; dmcols ]) + segs(segnum).dmcols ]; %#ok<AGROW>
  mrows    = [mrows   ; max([0 ; mrows  ]) + segs(segnum).mrows  ]; %#ok<AGROW>
  mcols    = [mcols   ; max([0 ; mcols  ]) + segs(segnum).mcols  ]; %#ok<AGROW>
  midx     = [midx    ; max([0 ; midx   ]) + segs(segnum).midx   ]; %#ok<AGROW>
  dmrows1  = [dmrows1 ; max([0 ; dmrows1]) + segs(segnum).dmrows1]; %#ok<AGROW>
  dmcols1  = [dmcols1 ; max([dmcoff ; dmcols1]) + segs(segnum).dmcols1]; %#ok<AGROW>
  dmrows2  = [dmrows2 ; max([0 ; dmrows2]) + segs(segnum).dmrows2]; %#ok<AGROW>
  dmcols2  = [dmcols2 ; max([dmcoff ; dmcols2]) + segs(segnum).dmcols2]; %#ok<AGROW>
  dmidx    = [dmidx   ; max([dmcoff ; dmidx  ]) + segs(segnum).dmidx  ]; %#ok<AGROW>
  mbceye   = [mbceye  ; segs(segnum).mbceye ]; %#ok<AGROW>
	
	mshape(2)  = mshape(2)  + segs(segnum).mshape(2) ;
	dmshape(2) = dmshape(2) + segs(segnum).dmshape(2);
	m0idx      = [ m0idx ; midxoff + segs(segnum).m0idx ]; %#ok<AGROW>
	m1idx      = [ m1idx ; midxoff + segs(segnum).m1idx ]; %#ok<AGROW>
	
	midxoff  = midxoff  + segs(segnum).mvarnum;
	kaidxoff = kaidxoff + segs(segnum).kanum;
	
	% combine initial solutions
	x0 = [ x0 ; segs(segnum).M ]; %#ok<AGROW>
end

% store updated segs list
coll.segs = segs;

% extend point map W
[rows, cols, vals] = find(coll.W);
dims = size(coll.W);
coll.W = sparse(rows, cols, vals, dims(1), fullsize);

% extend derivatives map Wp
[rows, cols, vals] = find(coll.Wp);
dims = size(coll.Wp);
coll.Wp = sparse(rows, cols, vals, dims(1), fullsize);

% extend continuity condition Phi
[rows, cols, vals] = find(coll.Phi);
dims = size(coll.Phi);
coll.Phi = sparse(rows, cols, vals, dims(1), fullsize);
	
% store variables in properties of class 'var1'
coll.fullsize = fullsize;
coll.MW       = MW;
coll.MWp      = MWp;
coll.MPhi     = MPhi;
coll.iw       = iw;
coll.kamidx   = kamidx;
coll.kadmidx  = kadmidx;
coll.dmrows   = dmrows;
coll.dmcols   = dmcols;
coll.mshape   = mshape;
coll.dmshape  = dmshape;
coll.mrows    = mrows;
coll.mcols    = mcols;
coll.midx     = midx;
coll.dmidx    = dmidx;
coll.dmrows1  = dmrows1;
coll.dmcols1  = dmcols1;
coll.dmrows2  = dmrows2;
coll.dmcols2  = dmcols2;
coll.mbceye   = mbceye;
coll.m0idx    = m0idx;
coll.m1idx    = m1idx;

coll.m0shape  = [dim*dim segnum];
coll.m1shape  = [dim*dim segnum];
coll.x_idx    = 1:numel(x0);
