function opts = coll_create(opts, data, x0, dx0)

tbid = data.tbid;
data_ptr = coco_ptr(data);
switch lower(data.coll.mesh)
  case {'uniform' 'frozen'}
    add_func_args = {tbid, @coll_F, @coll_DFDX, data_ptr, ...
      'zero', 'x0', x0};
  case 'moving'
    add_func_args = {tbid, @coll_F, @coll_DFDX, data_ptr, ...
      'zero', 'x0', x0, 'ReMesh', @coll_remesh };
  case 'co-moving'
    add_func_args = {tbid, @coll_F2, @coll_DF2DX, data_ptr, ...
      'zero', 'x0', x0, 'ReMesh', @coll_remesh2}; %
    opts = coco_add_slot(opts, tbid, @coll2_update, data_ptr, 'update');
    opts = coco_add_slot(opts, tbid, @coll2_update_h, data_ptr, 'update_h');
end
if ~isempty(dx0)
  add_func_args = [ add_func_args , { 't0', [dx0; zeros(numel(p0),1)] } ];
end
opts = coco_add_func(opts, add_func_args{:});
opts = coco_add_chart_data(opts, tbid, struct(), struct());
opts = coco_add_slot(opts, tbid, @coco_save_data, data_ptr, 'save_full');

xidx     = coco_get_func_data(opts, tbid, 'xidx');
err_xidx = xidx(data.maps.xbpidx);
fid      = coco_get_id(tbid, 'err');
fidTF    = coco_get_id(tbid, 'err_TF');
fidN     = coco_get_id(tbid, 'NTST');
add_func_args = {fid, @coll_err, data_ptr, ...
  'regular', {fid fidTF fidN}, 'xidx', err_xidx, 'PassChart'};
if any(strcmpi(data.coll.mesh, {'moving' 'co-moving'}))
  add_func_args = [ add_func_args , { 'ReMesh', @coll_err_remesh } ];
end
opts = coco_add_func(opts, add_func_args{:});

opts = coco_add_event(opts, 'MXCL', 'MX', fidTF, '>', 1);

end

function [data_ptr y] = coll_F(opts, data_ptr, xp) %#ok<INUSL>

data = data_ptr.data;
maps = data.maps;
mesh = data.mesh;

x   = xp(maps.x_idx);
p   = xp(maps.p_idx);
xbp = x (maps.xbpidx);
T   = x (maps.Tidx);

xx  = reshape(maps.W  * xbp, maps.xx_shape);
pp  = repmat(p, maps.pp_shape);

fode  = mesh.fka .* data.fhan(xx, pp, data.mode);
fode  = (0.5 * T / maps.NTST) * fode(:) - maps.Wp * xbp;
fcont = maps.Q * xbp;

y = [ fode ; fcont ];

end

function [data_ptr J] = coll_DFDX(opts, data_ptr, xp) %#ok<INUSL>

data = data_ptr.data;
maps = data.maps;
mesh = data.mesh;

x   = xp(maps.x_idx);
p   = xp(maps.p_idx);
xbp = x (maps.xbpidx);
T   = x (maps.Tidx);

xx  = reshape(maps.W * xbp, maps.xx_shape);
pp  = repmat(p, maps.pp_shape);

if isempty(data.dfdxhan)
  dfode = coll_num_DFDX(data.fhan, xx, pp, data.mode);
else
  dfode = data.dfdxhan(xx, pp, data.mode);
end
dfode = sparse(maps.dxrows, maps.dxcols, mesh.dxka(:) .* dfode(:));
dfode = (0.5 * T / maps.NTST) * dfode * maps.W - maps.Wp;

[rows cols vals] = find(dfode);

fode = data.fhan(xx, pp, data.mode);
fode = (0.5 / maps.NTST) * (mesh.fka .* fode);

rows = [rows; maps.frows(:); maps.off+maps.Qrows(:)];
cols = [cols; maps.fcols(:); maps.Qcols(:)];
vals = [vals; fode(:); maps.Qvals(:)];

J1 = sparse(rows, cols, vals);

if isempty(data.dfdphan)
  dfode = coll_num_DFDP(data.fhan, xx, pp, 1:numel(p), data.mode);
else
  dfode = data.dfdphan(xx, pp, data.mode);
end
dfode = sparse(maps.dprows, maps.dpcols, mesh.dpka(:) .* dfode(:));
dfode = (0.5 * T / maps.NTST) * dfode;

if numel(p)>0
  dfcont = sparse(size(maps.Q,1), numel(p));
else
  dfcont = [];
end

J2 = [dfode; dfcont];
J = sparse([J1 J2]);

end

function [data_ptr y] = coll_F2(opts, data_ptr, xp) %#ok<INUSL>

data = data_ptr.data;
maps = data.maps;

x  = xp(maps.x_idx);
p  = xp(maps.p_idx);
ka = xp(maps.ka_idx);
la = xp(maps.la_idx);

xbp = x(maps.xbpidx);
T   = x(maps.Tidx);

xx  = reshape(maps.W  * xbp, maps.xx_shape);
pp  = repmat(p, maps.pp_shape);

fode  = ka(maps.fka_idx) .* data.fhan(xx, pp, data.mode);
fode  = (0.5 * T / maps.NTST) * fode(:) - maps.Wp * xbp;
fcont = maps.Q * xbp;

u   = reshape(xbp, [maps.dim maps.NCOL+1 maps.NTST]);
fka = u(:,1:end-1,:)-u(:,2:end,:);
fka = squeeze(sum(sqrt(sum(fka.*fka,1)),2));
fka = fka - data.mean_fka;
fka = [ (ka - la*data.ka') + data.h*fka ; sum(ka)-maps.NTST ];

y = [ fode ; fcont ; fka ];

end

function [data_ptr J] = coll_DF2DX(opts, data_ptr, xp) %#ok<INUSL>

data = data_ptr.data;
maps = data.maps;
mesh = data.mesh;

x   = xp(maps.x_idx);
p   = xp(maps.p_idx);
ka  = xp(maps.ka_idx);

xbp = x (maps.xbpidx);
T   = x (maps.Tidx);

xx  = reshape(maps.W * xbp, maps.xx_shape);
pp  = repmat(p, maps.pp_shape);

if isempty(data.dfdxhan)
  dfode = coll_num_DFDX(data.fhan, xx, pp, data.mode);
else
  dfode = data.dfdxhan(xx, pp, data.mode);
end
dfode = sparse(maps.dxrows, maps.dxcols, ka(maps.dxka_idx(:)) .* dfode(:));
dfode = (0.5 * T / maps.NTST) * dfode * maps.W - maps.Wp;

[rows cols vals] = find(dfode);

fode   = data.fhan(xx, pp, data.mode);
fodeT  = (0.5 / maps.NTST) * (ka(maps.fka_idx) .* fode);
fodeka = (0.5 * T / maps.NTST) * fode;

rows = [rows; maps.frows(:); maps.off+maps.Qrows(:); maps.frows(:)];
cols = [cols; maps.fcols(:); maps.Qcols(:) ; maps.ka_idx(maps.fka_idx(:))'];
vals = [vals; fodeT(:); maps.Qvals(:); fodeka(:)];

if isempty(data.dfdphan)
  dfode = coll_num_DFDP(data.fhan, xx, pp, 1:numel(p), data.mode);
else
  dfode = data.dfdphan(xx, pp, data.mode);
end
dfode = (0.5 * T / maps.NTST) * (ka(maps.dpka_idx(:)) .* dfode(:));
rows = [rows(:) ; maps.dprows];
cols = [cols(:) ; maps.dpcols];
vals = [vals(:) ; dfode];

J1 = [sparse(rows, cols, vals) sparse(max(rows),1)];

u    = reshape(xbp, [maps.dim maps.NCOL+1 maps.NTST]);
du   = u(:,1:end-1,:)-u(:,2:end,:);
dsq  = 1./sqrt(sum(du.*du,1));
dsq  = du.*repmat(dsq, [mesh.dim 1 1]);

df1  = dsq(:,1,:);
df2  = -dsq(:,1:end-1,:)+dsq(:,2:end,:);
df3  = -dsq(:,end,:);
df   = data.h*cat(2,df1,df2,df3);

rows = reshape(1:mesh.NTST, [1 1 mesh.NTST]);
rows = repmat(rows, [mesh.dim mesh.NCOL+1 1]);
cols = reshape(maps.xbpidx, [mesh.dim mesh.NCOL+1 mesh.NTST]);
vals = df;

rows = [rows(:) ; (1:mesh.NTST)'];
cols = [cols(:) ; maps.ka_idx'   ];
vals = [vals(:) ; ones(mesh.NTST,1)];

rows = [rows(:) ; (1:mesh.NTST)'];
cols = [cols(:) ; maps.la_idx*ones(mesh.NTST,1)];
vals = [vals(:) ; -data.ka'];

rows = [rows(:) ; (maps.NTST+1)*ones(mesh.NTST,1)];
cols = [cols(:) ; maps.ka_idx'];
vals = [vals(:) ; ones(mesh.NTST,1)];

J3 = sparse(rows, cols, vals);

J = sparse([J1 ; J3]);

% [data_ptr J2] = fdm_ezDFDX('f(o,d,x)', opts, data_ptr, @coll_F2, xp);
% J1 = full(J);
% spy(abs(J1-J2)>1e-4)
% max(max(abs(J1-J2)))

end

function [data_ptr chart y] = coll_err(opts, data_ptr, chart, xp) %#ok<INUSL>

data  = data_ptr.data;
cdata = coco_get_chart_data(chart, data.tbid);
if isfield(cdata, 'err')
  y = cdata.err;
else
  maps = data.maps;
  
  cp = reshape(maps.Wc*xp, [maps.dim maps.NTST]);
  cp = sqrt(sum(cp.^2,1));
  y  = maps.wn * max(cp);
  y  = [ y ; y/data.coll.TOL ; data.mesh.NTST ];
  
  cdata.err = y;
  chart = coco_set_chart_data(chart, data.tbid, cdata);
end

end

function [opts status xtr] = coll_err_remesh(opts, data_ptr, ...
  chart, old_x, old_V) %#ok<INUSD>

data     = data_ptr.data;
xtr      = [];
xidx     = coco_get_func_data(opts, data.tbid, 'xidx');
err_xidx = xidx(data.maps.xbpidx);
opts     = coco_change_func(opts, data_ptr, 'xidx', err_xidx);
status   = 'success';

end

function [opts status xtr] = coll_remesh(opts, data_ptr, ...
  chart, old_x, old_V)

data = data_ptr.data;
maps = data.maps;
mesh = data.mesh;
coll = data.coll;

cdata = coco_get_chart_data(chart, data.tbid);
err   = cdata.err(1);

dim  = mesh.dim;
pdim = mesh.pdim;
NCOL = mesh.NCOL;
NTST = mesh.NTST;

u = old_x(maps.xbpidx);
V = old_V(maps.xbpidx,:);

cp   = reshape(maps.Wc*u, [dim NTST]);
cp   = sqrt(sum(cp.^2,1));
cp   = nthroot(maps.wn*cp,NCOL);
cpmn = nthroot(0.5*(coll.TOLINC+coll.TOLDEC), NCOL);

ka = mesh.ka;
F  = [0 cumsum(cpmn + cp,2)];
t  = [0 cumsum(ka,2)];

xtr   = maps.xtr;
NTSTi = min(ceil(NTST*1.1+1),   coll.NTSTMX);
NTSTd = max(ceil(NTST/1.025-1), coll.NTSTMN);
if err>coll.TOLINC && NTST~=NTSTi
  maps2 = coll_maps(data.int, NTSTi, pdim);
elseif err<coll.TOLDEC && NTST~=NTSTd
  maps2 = coll_maps(data.int, NTSTd, pdim);
else
  maps2 = maps;
end
xtr(maps.xtrend) = maps2.xtr(maps2.xtrend);
th = linspace(0,F(end),maps2.NTST+1);
tt = interp1(F,t*(maps2.NTST/t(end)),th,'cubic');
mesh2 = coll_mesh(data.int, maps2, tt);

tbpu = mesh.tbp(maps.tbp_uidx);
X  = reshape(u,maps.x_shape);
X  = X(:,maps.tbp_uidx);
u1 = interp1(tbpu',X',mesh2.tbp, 'cubic')';
u1 = u1(:);

V1 = zeros(numel(mesh2.tbp)*dim,size(V,2));
for i=1:size(V,2)
  V0 = V(:,i);
  X  = reshape(V0,maps.x_shape);
  X  = X(:,maps.tbp_uidx);
  V0 = interp1(tbpu',X',mesh2.tbp, 'cubic')';
  V1(:,i) = V0(:);
end

data.maps     = maps2;
data.mesh     = mesh2;
data_ptr.data = data;

x0 = [ u1; old_x(maps.Tpidx)   ];
V0 = [ V1; old_V(maps.Tpidx,:) ];

opts = coco_change_func(opts, data_ptr, 'x0', x0, 'vecs', V0);

status = 'success';

end

function [opts status xtr] = coll_remesh2(opts, data_ptr, ...
  chart, old_x, old_V)

data = data_ptr.data;
maps = data.maps;
mesh = data.mesh;
coll = data.coll;

dim  = mesh.dim;
pdim = mesh.pdim;
NTST = mesh.NTST;

cdata = coco_get_chart_data(chart, data.tbid);
err   = cdata.err(1);

xtr   = maps.xtr;
NTSTi = min(ceil(NTST*1.1+1),   coll.NTSTMX);
NTSTd = max(ceil(NTST/1.025-1), coll.NTSTMN);
if err>coll.TOLINC && NTST~=NTSTi
  maps2 = coll_maps(data.int, NTSTi, pdim);
elseif err<coll.TOLDEC && NTST~=NTSTd
  maps2 = coll_maps(data.int, NTSTd, pdim);
else
  opts = coco_change_func(opts, data_ptr, 'x0', old_x, 'vecs', old_V);
  status = 'success';
  return
end
xtr(maps.xtrend) = maps2.xtr(maps2.xtrend);

ka         = old_x(maps.ka_idx);
tmi        = [0 cumsum(ka,1)'];
t          = linspace(0,tmi(end),maps.NTST+1);
th         = linspace(0,tmi(end),maps2.NTST+1);
tt         = interp1(t,tmi*(maps2.NTST/tmi(end)),th,'cubic');
[mesh2 ka] = coll_mesh(data.int, maps2, tt);

u    = old_x(maps.xbpidx);
V    = old_V(maps.xbpidx,:);
ka_V = old_V(maps.ka_idx,:);

tbpu = mesh.tbp(maps.tbp_uidx);
X  = reshape(u,maps.x_shape);
X  = X(:,maps.tbp_uidx);
u1 = interp1(tbpu',X',mesh2.tbp, 'cubic')';
u1 = u1(:);
data.ka = diff(interp1(tmi,[0 cumsum(data.ka)],th,'cubic'));

V1 = zeros(numel(mesh2.tbp)*dim,size(V,2));
V2 = zeros(numel(th)-1,size(V,2));
for i=1:size(V,2)
  V0 = V(:,i);
  X  = reshape(V0,maps.x_shape);
  X  = X(:,maps.tbp_uidx);
  V0 = interp1(tbpu',X',mesh2.tbp, 'cubic')';
  V1(:,i) = V0(:);
  V0 = ka_V(:,i);
  V0 = interp1(tmi,[0 cumsum(V0)'],th,'cubic');
  V2(:,i) = diff(V0(:));
end

data.maps     = maps2;
data.mesh     = mesh2;
data_ptr.data = data;

x0 = [ u1 ; old_x(maps.Tpidx)   ; ka' ; old_x(maps.la_idx)   ];
V0 = [ V1 ; old_V(maps.Tpidx,:) ; V2  ; old_V(maps.la_idx,:) ];

opts = coco_change_func(opts, data_ptr, 'x0', x0, 'vecs', V0);

status = 'success';

end

function data_ptr = coll2_update(opts, data_ptr, cseg, varargin)

data = data_ptr.data;

maps = data.maps;

prcond      = cseg.prcond;
data.h_cont = prcond.h;
data.h      = data.coll.h0;

base_chart = cseg.src_chart;
xidx       = coco_get_func_data(opts, data.tbid, 'xidx');
xp         = base_chart.x(xidx);
data.ka    = xp(maps.ka_idx)';
tmi        = [0 cumsum(data.ka)];
data.mesh  = coll_mesh(data.int, data.maps, tmi);

u   = reshape(xp(maps.xbpidx), [maps.dim maps.NCOL+1 maps.NTST]);
fka = u(:,1:end-1,:)-u(:,2:end,:);
fka = squeeze(sum(sqrt(sum(fka.*fka,1)),2));
data.mean_fka = mean(fka);

data_ptr.data = data;

end

function data_ptr = coll2_update_h(opts, data_ptr, h, varargin) %#ok<INUSL>

data = data_ptr.data;

data.h = data.coll.h0*h/data.h_cont;
    
data_ptr.data = data;

end
