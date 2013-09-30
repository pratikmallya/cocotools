function [opts coll x0] = var1_mergeSegments(opts, coll)
%Create the full collocation system by merging all segments.

var1 = coll.var1;

% segs contains the list of collocation systems and will not be altered
% here, dim is the common phase-space dimension of all segments
segs = var1.segs;
dim  = var1.dim;

% initialise all variables
W         = sparse(0,0); % combined point map
Wp        = sparse(0,0); % combined derivatives map
Phi       = sparse(0,0); % combined continuity condition
x0        = [];          % combined initial solution
ka        = [];          % rescaling factors
iw        = [];          % Gauss integration weights
kaxidx    = [];          % indices for expanding ka to size xshape
kadxidx   = [];          % indices for expanding ka to size dxshape
dxrows    = [];          % row indices for Jacobians of vector fields
dxcols    = [];          % column indices for Jacobians of vector fields
xshape    = [dim 0];     % shape of array of collocation points
dxshape   = [dim 0];     % shape of array of Jacobians of vector fields
mrows     = [];          % row indices for norm condition on M
mcols     = [];          % column indices for norm condition on M
midx      = [];          % indices for expanding M
dmrows1   = [];          % row indices for norm condition on M
dmcols1   = [];          % column indices for norm condition on M
dmrows2   = [];          % row indices for norm condition on M
dmcols2   = [];          % column indices for norm condition on M
dmidx     = [];          % indices for expanding M
mbceye    = [];          % right-hand side of norm condition on M
x0idx     = [];          % indices of initial points of segments
x1idx     = [];          % indices of end points of segments
tint      = [];          % time intervals T
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
	fullsize = fullsize + dim*dim * NTST * (NCOL+1);
	
	% amend point map W
	[rows, cols, vals] = find(segs(segnum).W);
	dims = size(segs(segnum).W);
	[r, c, v] = find(W);
	d = size(W);
	r = [r ; rows+d(1)]; %#ok<AGROW>
	c = [c ; cols+d(2)]; %#ok<AGROW>
	v = [v ; vals]; %#ok<AGROW>
	W = sparse(r, c, v, d(1)+dims(1), d(2)+dims(2));

	% amend derivatives map Wp
	[rows, cols, vals] = find(segs(segnum).Wp);
	dims = size(segs(segnum).Wp);
	[r, c, v] = find(Wp);
	d  = size(Wp);
	r  = [r ; rows+d(1)]; %#ok<AGROW>
	c  = [c ; cols+d(2)]; %#ok<AGROW>
	v  = [v ; vals]; %#ok<AGROW>
	Wp = sparse(r, c, v, d(1)+dims(1), d(2)+dims(2));

	% amend continuity condition Phi
	[rows, cols, vals] = find(segs(segnum).Phi);
	dims = size(segs(segnum).Phi);
	[r, c, v] = find(Phi);
	d   = size(Phi);
	r   = [r ; rows+d(1)]; %#ok<AGROW>
	c   = [c ; cols+d(2)]; %#ok<AGROW>
	v   = [v ; vals]; %#ok<AGROW>
	Phi = sparse(r, c, v, d(1)+dims(1), d(2)+dims(2));
	
	% amend ka and index sets for ka
	ka      = [ ka ; segs(segnum).ka ]; %#ok<AGROW>
	iw      = [ iw ; segs(segnum).iw ]; %#ok<AGROW>
	kaxidx  = [kaxidx  ; kaidxoff + segs(segnum).kaxidx ]; %#ok<AGROW>
	kadxidx = [kadxidx   kaidxoff + segs(segnum).kadxidx]; %#ok<AGROW>
	
	% amend index sets and shapes
	dxrows   = [dxrows  ; max([0 ; dxrows ]) + segs(segnum).dxrows ]; %#ok<AGROW>
	dxcols   = [dxcols  ; max([0 ; dxcols ]) + segs(segnum).dxcols ]; %#ok<AGROW>
  mrows    = [mrows   ; max([0 ; mrows  ]) + segs(segnum).mrows  ]; %#ok<AGROW>
  mcols    = [mcols   ; max([0 ; mcols  ]) + segs(segnum).mcols  ]; %#ok<AGROW>
  midx     = [midx    ; max([0 ; midx   ]) + segs(segnum).midx   ]; %#ok<AGROW>
  dmrows1  = [dmrows1 ; max([0 ; dmrows1]) + segs(segnum).dmrows1]; %#ok<AGROW>
  dmcols1  = [dmcols1 ; max([0 ; dmcols1]) + segs(segnum).dmcols1]; %#ok<AGROW>
  dmrows2  = [dmrows2 ; max([0 ; dmrows2]) + segs(segnum).dmrows2]; %#ok<AGROW>
  dmcols2  = [dmcols2 ; max([0 ; dmcols2]) + segs(segnum).dmcols2]; %#ok<AGROW>
  dmidx    = [dmidx   ; max([0 ; dmidx  ]) + segs(segnum).dmidx  ]; %#ok<AGROW>
  mbceye   = [mbceye  ; segs(segnum).mbceye ]; %#ok<AGROW>
	
	xshape(2)  = xshape(2)  + segs(segnum).xshape(2) ;
	dxshape(2) = dxshape(2) + segs(segnum).dxshape(2);
	x0idx      = [ x0idx   ; varidxoff + segs(segnum).x0idx    ]; %#ok<AGROW>
	x1idx      = [ x1idx   ; varidxoff + segs(segnum).x1idx    ]; %#ok<AGROW>
	tint       = [ tint    ; segs(segnum).tint                 ]; %#ok<AGROW>
	tintxidx   = [ tintxidx  segnum*ones(segs(segnum).xshape)  ]; %#ok<AGROW>
	tintdxidx  = [ tintdxidx segnum*ones(segs(segnum).dxshape) ]; %#ok<AGROW>
	
	varidxoff = varidxoff + segs(segnum).varnum;
	kaidxoff  = kaidxoff  + segs(segnum).kanum;
	
	% combine initial solutions
	x0 = [ x0 ; segs(segnum).x0 ]; %#ok<AGROW>
end

% store updated segs list
var1.segs = segs;

% store variables in properties of class 'var1'
var1.fullsize  = fullsize;
var1.W         = W;
var1.Wp        = Wp;
var1.Phi       = Phi;
var1.ka        = ka;
var1.iw        = iw;
var1.kaxidx    = kaxidx;
var1.kadxidx   = kadxidx;
var1.dxrows    = dxrows;
var1.dxcols    = dxcols;
var1.xshape    = xshape;
var1.dxshape   = dxshape;
var1.mrows     = mrows;
var1.mcols     = mcols;
var1.midx      = midx;
var1.dmidx     = dmidx;
var1.dmrows1   = dmrows1;
var1.dmcols1   = dmcols1;
var1.dmrows2   = dmrows2;
var1.dmcols2   = dmcols2;
var1.mbceye    = mbceye;
var1.x0idx     = x0idx;
var1.x1idx     = x1idx;
var1.tint      = tint;
var1.tintxidx  = tintxidx;
var1.tintdxidx = tintdxidx;

var1.x0shape   = [dim*dim segnum];
var1.x1shape   = [dim*dim segnum];
var1.tintshape = [      1 segnum];

var1.x_idx     = 1:numel(x0);

coll.var1      = var1;
