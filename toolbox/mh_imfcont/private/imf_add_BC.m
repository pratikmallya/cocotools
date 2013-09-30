function [opts pidx] = imf_add_BC(opts, prefix)
%Add boundary condition for flow box covering.

%% get data of collocation system
coll_fid       = coco_get_id(prefix, 'coll');
[coll xidx x0] = coco_get_func_data(opts, coll_fid, 'data', 'xidx', 'x0');
x0             = x0(coll.x_idx);
pidx           = xidx(coll.p_idx);

%% copy some fields from coll to data
data.W      = coll.W;
data.Wp     = coll.Wp;
data.ka     = coll.ka;
data.kaxidx = coll.kaxidx;
data.xshape = coll.xshape;
data.xidx   = xidx(coll.x_idx);

%% compute index sets for accessing base points of orbits
data.points = imf_create_pdata(coll);

%% initialise periodic continuity condition
x0idx = reshape(coll.x0idx, coll.x0shape);
x1idx = reshape(coll.x1idx, coll.x1shape);
x1idx = x1idx(:,[end 1:end-1]);

[n segnum] = size(x0idx);

rows = [1:n*segnum 1:n*segnum];
cols = [x0idx(:) ; x1idx(:)];
vals = [ones(1,n*segnum) -ones(1,n*segnum)];
off  = n*segnum;

%% initialise time-of-flight conditions
%  we keep the ratios constant here
idx     = coll.tintidx;
T       = x0(idx);
[TT ii] = max(T);
T(ii)   = [];
idx(ii) = [];
ga      = -T./TT;
nrows   = length(T);
ii      = repmat(coll.tintidx(ii), [nrows 1]);

rows = [rows  off+[1:nrows 1:nrows]];
cols = [cols ; idx ; ii ];
vals = [vals ones(1,nrows) ga'];
off  = off + nrows;

%% create matrix encoding boundary condition
data.Phi = sparse(rows, cols, vals, off, coll.fullsize);

%% initialise phase condition
xx       = data.W  * x0;
xxp      = data.Wp * x0;
ka       = reshape(data.ka(data.kaxidx), [prod(data.xshape) 1]);
xxp      = ka .* xxp;
xxp      = xxp/norm(xxp);

data.x0  = xx;
data.x0p = xxp';

%% add interpolation boundary conditions
fid     = coco_get_id(prefix, 'bcnd_interp');
opts    = coco_add_func(opts, fid, @imf_bc_F, @imf_bc_DFDX, ...
  data, 'zero', 'xidx', data.xidx);

%% add phase conditions
fid     = coco_get_id(prefix, 'bcnd_phase');
opts    = coco_add_func(opts, fid, @imf_phase_F, @imf_phase_DFDX, ...
  data, 'zero', 'xidx', data.xidx);

%% add call back function to update event
fid  = coco_get_id(prefix, 'bcnd_phase_update');
data.fid = fid;
opts = coco_add_slot(opts, fid, @imf_bc_update, ...
  data, 'covering_update');

end

%%
function point_data = imf_create_pdata(coll)
%  Compute index sets of base points.

segs = coll.segs;

xbp_idx   = [];
xbp_shape = [coll.dim 0];

for segnum = 1:numel(segs)
	alidx    = segs(segnum).varidxoff + segs(segnum).alidx;
	alshape  = segs(segnum).alshape;
	alidx    = reshape(alidx, alshape);
	al0idx   = alidx(1:end-segs(segnum).dim, :);
	alshape  = [segs(segnum).dim segs(segnum).NCOL*segs(segnum).NTST];
	al0idx   = [reshape(al0idx, alshape) alidx(end-segs(segnum).dim+1:end)'];
	alshape(2) = alshape(2)+1;

    t0shape = [segs(segnum).NCOL+1 segs(segnum).NTST];
    t0idx   = 1:(segs(segnum).NCOL+1)*(segs(segnum).NTST);
	teidx   = t0idx(end);
	t0idx   = reshape(t0idx, t0shape);
	t0idx   = t0idx(1:end-1,:);
	tbpidx  = [t0idx(:)' teidx];
	
	xbp_idx      = [xbp_idx al0idx]; %#ok<AGROW>
    xbp_shape(2) = xbp_shape(2) + alshape(2);
    
    point_data.segs(segnum).xbp_idx   = al0idx;
    point_data.segs(segnum).xbp_shape = alshape;
    point_data.segs(segnum).tbp_idx   = tbpidx;
end

point_data.xbp_idx   = xbp_idx;
point_data.xbp_shape = xbp_shape;

end

%%
function [data fbc] = imf_bc_F(opts, data, x) %#ok<INUSL>
%Evaluate periodic boundary condition.

fbc = data.Phi * x;

end

%%
function [data Jbc] = imf_bc_DFDX(opts, data, x) %#ok<INUSL,INUSD>
%Compute linearisation of periodic boundary condition.

Jbc = data.Phi;

end

%%
function [data fbc] = imf_phase_F(opts, data, x) %#ok<INUSL>
%Evaluate integral phase condition.

fbc = data.x0p * (data.W * x - data.x0);

end

%%
function [data Jbc] = imf_phase_DFDX(opts, data, x) %#ok<INUSL,INUSD>
%Compute linearisation of integral phase condition.

Jbc = data.x0p * data.W;

end

%%
function data = imf_bc_update(opts, data, cmd, varargin) %#ok<INUSL>
%Update previous-point information for phase condition.

switch cmd
  case 'update'
    x   = varargin{1};
    x   = x(data.xidx);
    x0  = data.W  * x;
    x0p = data.Wp * x;
    ka  = reshape(data.ka(data.kaxidx), [prod(data.xshape) 1]);
    x0p = ka .* x0p;
    x0p = x0p/norm(x0p);
    
    data.x0  = x0;
    data.x0p = x0p';
    
  otherwise
end

end
