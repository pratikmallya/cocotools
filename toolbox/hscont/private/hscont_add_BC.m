function [opts coll xidx] = hscont_add_BC(opts, prefix)
% Construct hybrid boundary value problem.

%% get data of collocation system
coll_fid    = coco_get_id(prefix, 'coll');
[coll xidx] = coco_get_func_data(opts, coll_fid, 'data', 'xidx');

%% set up and initialise boundary conditions
%  bug: not the whole coll structure should be copied
%       precompute index sets used in hybrid_* functions for speed-up
data.coll    = coll;
data.seglist = coll.seglist;

fid  = coco_get_id(prefix, 'hybrid');
opts = coco_add_func(opts, fid, @hybrid_F, @hybrid_DFDX, data, ...
  'zero', 'xidx', xidx);

end

%%
function [data f] = hybrid_F(opts, data, xp)
%Compute hybrid coundary conditions.

x        = xp(data.coll.x_idx,1);
p        = xp(data.coll.p_idx,1);
[data f] = hybrid_bc_F(opts, data, x, p);
end

%%
function [data J] = hybrid_DFDX(opts, data, xp)
%Compute linearisation of hybrid coundary conditions.

%% initialisations
x = xp(data.coll.x_idx,1);
p = xp(data.coll.p_idx,1);

%  definition of some temporary variables
rows = [];
cols = [];
vals = [];

%% linearisation of boundary condition with respect to x
% for debugging:
% [opts Jbc] = coco_num_DFDX(opts, data.F, x, p);
[data Jbc] = hybrid_bc_DFDX(opts, data, x, p);
[r c v] = find(Jbc);
rows = [rows ; r];
cols = [cols ; c];
vals = [vals ; v];

%% linearisation of boundary condition with respect to parameters
% for debugging:
% [opts Jbc] = coco_num_DFDP(opts, data.F, x, p, 1:length(p));
[data Jbc] = hybrid_bc_DFDP(opts, data, x, p, 1:length(p));
[r c v] = find(Jbc);
rows = [rows ; r];
cols = [cols ; length(x)+c];
vals = [vals ; v];

%% merge matrices
% [data J1] = fdm_ezDFDX('f(o,d,x)', opts, data, @hybrid_F, xp);
J = sparse(rows, cols, vals, size(Jbc,1), length(xp));
end

%%
function [data fbc] = hybrid_bc_F(opts, data, x, p)
%Evaluate jump conditions of hybrid system.

% extract initial- and end-points all of segments
x0 = reshape(x(data.coll.x0idx), data.coll.x0shape);
x1 = reshape(x(data.coll.x1idx), data.coll.x1shape);

% jumps go from seg1 to seg2
% we run cyclically through all segments
seg1 = 1;
seg2 = 2;
fbc  = [];

% evaluate event surface condition and jump map for each segment
for segnum = 1:length(data.seglist)
  if isempty(data.seglist(segnum).event)
		% we ignore all segments with no event to allow for
		% generalised hybrid boundary value problems
    continue
	end
  
	% evaluate event surface condition f(x_seg1(1))=0
	fev        = data.seglist(segnum).event;
	fev        = str2func(fev);
	[data fev] = fev(opts, data, x1(:,seg1), p);
	
	% evaluate jump condition g(x_seg1(1)) = x_seg2(0)
	fdm        = data.seglist(segnum).dismap;
	fdm        = str2func(fdm);
	[data fdm] = fdm(opts, data, x1(:,seg1), p); %#ok<RHSFN>
	fdm        = fdm - x0(:,seg2);
	
	% combine all conditions
	fbc        = [ fbc ; fev ; fdm ]; %#ok<AGROW>
	
	% increment of segments monulo number of segments
	seg1 = seg2;
	seg2 = seg2 + 1;
	if seg2>size(x0,2)
		seg2 = 1;
	end
end

end

%%
function [data Jbc] = hybrid_bc_DFDX(opts, data, x, p)
%Compute linearisation of jump conditions.

% [opts Jbc] = coco_num_DFDX(opts, opts.bcond.F, x, p);
% Jbc = sparse(Jbc);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

x0   = reshape(x(data.coll.x0idx), data.coll.x0shape);
x1   = reshape(x(data.coll.x1idx), data.coll.x1shape);

seg1 = 1;
seg2 = 2;
roff = 0;
rows = [];
cols = [];
dfdx = [];

x0idx = reshape(data.coll.x0idx, data.coll.x0shape);
x1idx = reshape(data.coll.x1idx, data.coll.x1shape);
o     = ones(data.coll.x0shape(1), 1);

for segnum = 1:length(data.seglist)
  if isempty(data.seglist(segnum).event)
    continue
  end
  
	fev        = data.seglist(segnum).event;
	fev        = str2func(fev);
	[data fev] = fdm_ezDFDX('f(o,d,x,p)v', opts, data, fev, x1(:,seg1), p);
  rows       = [ rows ; roff + o ]; %#ok<AGROW>
  cols       = [ cols ; x1idx(:,seg1) ]; %#ok<AGROW>
  dfdx       = [ dfdx ; reshape(fev, [numel(fev) 1]) ]; %#ok<AGROW>
  roff       = roff + 1;
	
	fdm        = data.seglist(segnum).dismap;
	fdm        = str2func(fdm);
	[data fdm] = fdm_ezDFDX('f(o,d,x,p)v', opts, data, fdm, x1(:,seg1), p);
  r          = kron((1:data.coll.x1shape(1))', o');
  rows       = [ rows ; roff + reshape(r, [numel(r) 1]) ]; %#ok<AGROW>
  c          = kron(o, x1idx(:,seg1)');
  cols       = [ cols ; reshape(c, [numel(c) 1]) ]; %#ok<AGROW>
  dfdx       = [ dfdx ; reshape(fdm, [numel(fdm) 1]) ]; %#ok<AGROW>
  rows       = [ rows ; roff + (1:data.coll.x1shape(1))' ]; %#ok<AGROW>
  cols       = [ cols ; x0idx(:,seg2) ]; %#ok<AGROW>
  dfdx       = [ dfdx ; -o ]; %#ok<AGROW>
  roff       = roff + data.coll.x1shape(1);
	
	seg1 = seg2;
	seg2 = seg2 + 1;
	if seg2>size(x0,2)
		seg2 = 1;
	end
end

Jbc = sparse(rows, cols, dfdx);

end

%%
function [data Jbc] = hybrid_bc_DFDP(opts, data, x, p, pars)
%Compute parameter derivatives of jump conditions.

% Jbc = sparse( prod(opts.coll.x0shape)+opts.coll.x0shape(2), length(pars) );
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

x0   = reshape(x(data.coll.x0idx), data.coll.x0shape);
x1   = reshape(x(data.coll.x1idx), data.coll.x1shape);

seg1 = 1;
seg2 = 2;
roff = 0;
rows = [];
cols = [];
dfdp = [];

o     = ones(numel(pars), 1);
pcols = (1:numel(pars))';

for segnum = 1:length(data.seglist)
  if isempty(data.seglist(segnum).event)
    continue
  end
  
	fev        = data.seglist(segnum).event;
	fev        = str2func(fev);
	[data fev] = fdm_ezDFDP('f(o,d,x,p)v', opts, data, fev, x1(:,seg1), p, pars);
  rows       = [ rows ; roff + o ]; %#ok<AGROW>
  cols       = [ cols ; pcols ]; %#ok<AGROW>
  dfdp       = [ dfdp ; reshape(fev, [numel(fev) 1]) ]; %#ok<AGROW>
  roff       = roff + 1;
	
	fdm        = data.seglist(segnum).dismap;
	fdm        = str2func(fdm);
	[data fdm] = fdm_ezDFDP('f(o,d,x,p)v', opts, data, fdm, x1(:,seg1), p, pars);
  r          = kron((1:data.coll.x1shape(1))', o');
  rows       = [ rows ; roff + reshape(r, [numel(r) 1]) ]; %#ok<AGROW>
  c          = kron(ones(1,data.coll.x1shape(1)), pcols)';
  cols       = [ cols ; reshape(c, [numel(c) 1]) ]; %#ok<AGROW>
  dfdp       = [ dfdp ; reshape(fdm, [numel(fdm) 1]) ]; %#ok<AGROW>
  roff       = roff + data.coll.x1shape(1);
	
	seg1 = seg2;
	seg2 = seg2 + 1;
	if seg2>size(x0,2)
		seg2 = 1;
	end
end

Jbc = sparse(rows, cols, dfdp);

end

%%
function data = hybrid_bc_update(opts, data, varargin) %#ok<DEFNU>
%Update previous-point information for phase condition.

if ~isfield(opts.cont, 'ptlist') || isempty(opts.cont.ptlist)
	return
end

chart = opts.cont.ptlist{1};
x     = chart.x(data.xidx,1); %#ok<NASGU>

% Do something with x.
% See periodic_bc_update in pocont for an example.

end
