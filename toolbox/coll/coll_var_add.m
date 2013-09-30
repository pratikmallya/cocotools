%!var_coll_add
function prob = var_coll_add(prob, segoid, mode)

tbid = coco_get_id(segoid, 'var');
data = var_coll_get_settings(prob, tbid);
data = var_coll_init_data(prob, data, segoid, mode);
uidx = coco_get_func_data(prob, data.tbid, 'uidx');
pid  = coco_get_id(tbid, {'cond' '||M||'});
data = coco_func_data(data);
prob = coco_add_func(prob, tbid, @var_seg, data, ...
  'regular', pid, 'uidx', uidx);
prob = coco_add_slot(prob, tbid, @var_seg_update, data, 'update');

end %!end_var_coll_add
%!var_coll_get_settings
function data = var_coll_get_settings(prob, tbid)

defaults.NBeta  =  5;
defaults.NBItMX = 10;
data.var = coco_merge(defaults, coco_get(prob, tbid));
NBeta = data.var.NBeta;
assert(numel(NBeta)==1 && isnumeric(NBeta) && mod(NBeta,1)==0, ...
  '%s: input for option ''NBeta'' is not an integer', tbid);
assert(NBeta>0, '%s: ''NBeta'' must be greater than 0', tbid);
NBItMX = data.var.NBItMX;
assert(numel(NBItMX)==1 && isnumeric(NBItMX) && mod(NBItMX,1)==0, ...
  '%s: input for option ''NBItMX'' is not an integer', tbid);
assert(NBItMX>0, '%s: ''NBItMX'' must be greater than 0', tbid);

end %!end_var_coll_get_settings
%!var_coll_init_data
function data = var_coll_init_data(prob, data, segoid, mode)

data.tbid = coco_get_id(segoid, 'coll');
data.mode = mode;
[fdata u] = coco_get_func_data(prob, data.tbid, 'data', 'u0');
data      = coco_merge(data, fdata, {'xbp_idx' 'T_idx' 'p_idx' 'dim' ...
  'W' 'Wp' 'x_shp' 'p_rep' 'fhan' 'dfdxhan' 'dxrows' 'dxcols' ...
  'off' 'Qrows' 'Qcols' 'Qvals'});
data.NTST = fdata.coll.NTST;

dim          = data.dim;
data.M0_idx  = data.xbp_idx(1:dim);
data.M1_idx  = data.xbp_idx(end-dim+(1:dim));

switch data.mode
  case '2I'
    wts      = kron(fdata.wts1, eye(dim));
    data.B1  = (0.5/fdata.coll.NTST)*(wts*fdata.W);
    data.rhs = [2*eye(dim); zeros(fdata.xbp_idx(end)-dim, dim)];
    data.la1 = 0.5;
    data.la2 = 0.5;
  case '3I'
    ze = sparse(dim, data.xbp_idx(end)-2*dim);
    data.B1  = [speye(dim) ze speye(dim)];
    data.rhs = [3*eye(dim); zeros(fdata.xbp_idx(end)-dim, dim)];
    data.la1 = 2/3;
    data.la2 = 1-data.la1; % don't use 1/3 [roundoff errors]
  otherwise
    error('%s: unknown mode', mfilename);
end
data.B2  = (0.5/fdata.coll.NTST)*fdata.W'*fdata.wts2*fdata.W;
data.M0  = repmat(eye(dim), [fdata.coll.NTST*(fdata.coll.NCOL+1) 1]);
data     = init_row(data, u);

end %!end_var_coll_init_data
%!init_row
function data = init_row(data, u)

x    = u(data.xbp_idx);
T    = u(data.T_idx);
p    = u(data.p_idx);
NTST = data.NTST;

xx = reshape(data.W*x, data.x_shp);
pp = repmat(p, data.p_rep);
if isempty(data.dfdxhan)
  dfode = coco_ezDFDX('f(x,p)v', data.fhan, xx, pp);
else
  dfode = data.dfdxhan(xx, pp);
end
dfode = sparse(data.dxrows, data.dxcols, dfode(:));
dfode = (0.5*T/NTST)*dfode*data.W-data.Wp;

[rows cols vals] = find(dfode);

rows = [rows(:); data.off+data.Qrows(:)];
cols = [cols(:); data.Qcols(:)];
vals = [vals(:); data.Qvals(:)];
J0   = sparse(rows, cols, vals);

M0   = data.M0;
M    = [data.B1+M0'*data.B2; J0]\data.rhs;
betas = linspace(0,1,data.var.NBeta+1);
for beta = betas(2:end)
  J1 = beta*J0;
  It = 1;
  while It<data.var.NBItMX && norm((M(:)-M0(:)))>0.1
    M0 = data.la1*M0 + data.la2*M;
    J  = [data.B1+M0'*data.B2; J1];
    M  = J\data.rhs;
    It = It+1;
  end
end
data.M0  = data.la1*M0 + data.la2*M;
data.row = data.B1+M'*data.B2;

end %!end_init_row
%!var_seg
function [data y] = var_seg(prob, data, u)

x    = u(data.xbp_idx);
T    = u(data.T_idx);
p    = u(data.p_idx);
NTST = data.NTST;

xx = reshape(data.W*x, data.x_shp);
pp = repmat(p, data.p_rep);
if isempty(data.dfdxhan)
  dfode = coco_ezDFDX('f(x,p)v', data.fhan, xx, pp);
else
  dfode = data.dfdxhan(xx, pp);
end
dfode = sparse(data.dxrows, data.dxcols, dfode(:));
dfode = (0.5*T/NTST)*dfode*data.W-data.Wp;

[rows cols vals] = find(dfode);

rows = [rows(:); data.off+data.Qrows(:)];
cols = [cols(:); data.Qcols(:)];
vals = [vals(:); data.Qvals(:)];
J    = sparse(rows, cols, vals);

J      = [data.row; J];
data.M = J\data.rhs;

y = [ condest(J); max(abs(data.M(:))) ];

end %!end_var_seg
%!var_seg_update
function data = var_seg_update(prob, data, cseg, varargin)

uidx = coco_get_func_data(prob, data.tbid, 'uidx');
u    = cseg.src_chart.x;
data = update_row(data, u(uidx));

end %!end_var_seg_update
%!update_row
function data = update_row(data, u)

x    = u(data.xbp_idx);
T    = u(data.T_idx);
p    = u(data.p_idx);
NTST = data.NTST;

xx = reshape(data.W*x, data.x_shp);
pp = repmat(p, data.p_rep);
if isempty(data.dfdxhan)
  dfode = coco_ezDFDX('f(x,p)v', data.fhan, xx, pp);
else
  dfode = data.dfdxhan(xx, pp);
end
dfode = sparse(data.dxrows, data.dxcols, dfode(:));
dfode = (0.5*T/NTST)*dfode*data.W-data.Wp;

[rows cols vals] = find(dfode);

rows = [rows(:); data.off+data.Qrows(:)];
cols = [cols(:); data.Qcols(:)];
vals = [vals(:); data.Qvals(:)];
J0   = sparse(rows, cols, vals);

M0   = data.M0;
M    = [data.B1+M0'*data.B2; J0]\data.rhs;
It   = 1;
while It<data.var.NBItMX && norm((M(:)-M0(:)))>0.1
  M0 = data.la1*M0 + data.la2*M;
  J  = [data.B1+M0'*data.B2; J0];
  M  = J\data.rhs;
  It = It+1;
end
data.M0  = data.la1*M0 + data.la2*M;
data.row = data.B1+M'*data.B2;

end %!end_update_row