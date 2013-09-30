function [opts coll x0 s0] = coll_mergeSegments(opts, coll)
%Create the full collocation system by merging all segments.

% segs contains the list of collocation systems and will not be altered
% here, dim is the common phase-space dimension of all segments
segs = coll.segs;
dim  = coll.dim;

% initialise all variables
W         = sparse(0,0); % combined point map
Wp        = sparse(0,0); % combined derivatives map
Phi       = sparse(0,0); % combined continuity condition
x0        = [];          % combined initial solution
s0        = [];          % combined initial tangent
ka        = [];          % rescaling factors
kaxidx    = [];          % indices for expanding ka to size xshape
kadxidx   = [];          % indices for expanding ka to size dxshape
dxrows    = [];          % row indices for Jacobians of vector fields
dxcols    = [];          % column indices for Jacobians of vector fields
xshape    = [dim 0];     % shape of array of collocation points
dxshape   = [dim 0];     % shape of array of Jacobians of vector fields
x0idx     = [];          % indices of initial points of segments
x1idx     = [];          % indices of end points of segments
tintidx   = [];          % indices of time intervals T
tintxidx  = [];          % indices for expanding T to size xshape
tintdxidx = [];          % indices for expanding T to size dxshape
fullsize  = 0;           % (column) dimension of full linearisation
varidxoff = 0;           % offset of indices of variables in segment
kaidxoff  = 0;           % offset of indices of ka in segment

% merge index sets and matricies into large index sets and matrices
% encoding the full collocation system over all segments
for segnum = 1:length(segs)
	segs(segnum).varidxoff = varidxoff;
	
	NTST = segs(segnum).NTST;
	NCOL = segs(segnum).NCOL;
	
	% increase fullsize by size of block
	fullsize = fullsize + dim * NTST * (NCOL+1) + 1;
	
	% amend point map W
	[rows, cols, vals] = find(segs(segnum).W);
	dims = size(segs(segnum).W);
	[r, c, v] = find(W);
	d = size(W);
	r = [r ; rows+d(1)]; %#ok<AGROW>
	c = [c ; cols+d(2)]; %#ok<AGROW>
	v = [v ; vals];      %#ok<AGROW>
	W = sparse(r, c, v, d(1)+dims(1), d(2)+dims(2));

	% amend derivatives map Wp
	[rows, cols, vals] = find(segs(segnum).Wp);
	dims = size(segs(segnum).Wp);
	[r, c, v] = find(Wp);
	d  = size(Wp);
	r  = [r ; rows+d(1)]; %#ok<AGROW>
	c  = [c ; cols+d(2)]; %#ok<AGROW>
	v  = [v ; vals];      %#ok<AGROW>
	Wp = sparse(r, c, v, d(1)+dims(1), d(2)+dims(2));

	% amend continuity condition Phi
	[rows, cols, vals] = find(segs(segnum).Phi);
	dims = size(segs(segnum).Phi);
	[r, c, v] = find(Phi);
	d   = size(Phi);
	r   = [r ; rows+d(1)]; %#ok<AGROW>
	c   = [c ; cols+d(2)]; %#ok<AGROW>
	v   = [v ; vals];      %#ok<AGROW>
	Phi = sparse(r, c, v, d(1)+dims(1), d(2)+dims(2));
	
	% amend ka and index sets for ka
	ka      = [ ka ; segs(segnum).ka ]; %#ok<AGROW>
	kaxidx  = [kaxidx  kaidxoff + segs(segnum).kaxidx ]; %#ok<AGROW>
	kadxidx = [kadxidx kaidxoff + segs(segnum).kadxidx]; %#ok<AGROW>
	
	% amend index sets and shapes
	dxrows = [dxrows ; max([0 ; dxrows]) + segs(segnum).dxrows]; %#ok<AGROW>
	dxcols = [dxcols ; max([0 ; dxcols]) + segs(segnum).dxcols]; %#ok<AGROW>
	
	xshape(2)  = xshape(2)  + segs(segnum).xshape(2) ;
	dxshape(2) = dxshape(2) + segs(segnum).dxshape(2);
	x0idx      = [ x0idx   ; varidxoff + segs(segnum).x0idx   ]; %#ok<AGROW>
	x1idx      = [ x1idx   ; varidxoff + segs(segnum).x1idx   ]; %#ok<AGROW>
	tintidx    = [ tintidx ; varidxoff + segs(segnum).tintidx ]; %#ok<AGROW>
	tintxidx   = [ tintxidx  segnum*ones(segs(segnum).xshape) ]; %#ok<AGROW>
	tintdxidx  = [ tintdxidx segnum*ones(segs(segnum).dxshape) ]; %#ok<AGROW>
	
	varidxoff = varidxoff + segs(segnum).varnum;
	kaidxoff  = kaidxoff  + segs(segnum).kanum;
	
	% combine initial solutions
	x0 = [ x0 ; segs(segnum).x0 ]; %#ok<AGROW>
  
  if isfield(segs(segnum), 's0')
    s0 = [ s0 ; segs(segnum).s0 ]; %#ok<AGROW>
  end
end

% update collocation structure
coll.segs      = segs;
coll.fullsize  = fullsize;
coll.W         = W;
coll.Wp        = Wp;
coll.Phi       = Phi;
coll.ka        = ka;
coll.kaxidx    = kaxidx;
coll.kadxidx   = kadxidx;
coll.dxrows    = dxrows;
coll.dxcols    = dxcols;
coll.xshape    = xshape;
coll.dxshape   = dxshape;
coll.x0idx     = x0idx;
coll.x1idx     = x1idx;
coll.tintidx   = tintidx;
coll.tintxidx  = tintxidx;
coll.tintdxidx = tintdxidx;
coll.x0shape   = [dim segnum];
coll.x1shape   = [dim segnum];
coll.tintshape = [  1 segnum];
coll.x_idx     = 1:numel(x0);
