function opts = coll_create(opts, data, x0, p0, dx0)

tbid = data.tbid;
data_ptr  = coco_ptr(data);
add_func_args = {tbid, @coll_F, @coll_DFDX, data_ptr, ...
  'zero', 'x0', [x0; p0]};
if ~isempty(dx0)
  add_func_args = [ add_func_args , { 't0', [dx0; zeros(numel(p0),1)] } ];
end
if strcmpi(data.coll.mesh, 'moving')
  add_func_args = [ add_func_args , { 'ReMesh', @coll_remesh } ];
end
opts = coco_add_func(opts, add_func_args{:});
opts = coco_add_chart_data(opts, tbid, struct(), struct());
opts = coco_add_slot(opts, tbid, @coco_save_data, data_ptr, 'save_full');

xidx     = coco_get_func_data(opts, tbid, 'xidx');
err_xidx = xidx(data.maps.xbpidx);
fid      = coco_get_id(tbid, 'err');
fidTF    = coco_get_id(tbid, 'err_TF');
add_func_args = {fid, @coll_err, data_ptr, ...
  'regular', {fid fidTF}, 'xidx', err_xidx, 'PassChart'};
if strcmpi(data.coll.mesh, 'moving')
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
  y  = [ y ; y/data.coll.TOL ];
  
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
  chart, old_x, old_V) %#ok<INUSL>

data = data_ptr.data;
maps = data.maps;
mesh = data.mesh;
coll = data.coll;

dim  = mesh.dim;
NCOL = mesh.NCOL;
NTST = mesh.NTST;

u = old_x(maps.xbpidx);
V = old_V(maps.xbpidx,:);

cp   = reshape(maps.Wc*u, [dim NTST]);
cp   = sqrt(sum(cp.^2,1));
cp   = nthroot(maps.wn*cp,NCOL);
cpmn = nthroot(0.125*coll.TOL, NCOL);

ka = mesh.ka;
F  = [0 cumsum(cpmn + cp,2)]; % this is wrong: correct is F  = [0 cumsum(cpmn*ka cp, 2)];
t  = [0 cumsum(ka,2)];
th = linspace(0,F(end),mesh.NTST+1);
tt = interp1(F,t,th, 'cubic');

mesh2 = coll_mesh(data.int, maps, tt);

xtr = maps.xtr;

tbpu = mesh.tbp(maps.tbp_uidx);
X  = reshape(u,maps.x_shape);
X  = X(:,maps.tbp_uidx);
u1 = interp1(tbpu',X',mesh2.tbp, 'cubic')';
u1 = u1(:);

V1 = zeros(size(V));
for i=1:size(V,2)
  V0 = V(:,i);
  X  = reshape(V0,maps.x_shape);
  X  = X(:,maps.tbp_uidx);
  V0 = interp1(tbpu',X',mesh2.tbp, 'cubic')';
  V1(:,i) = V0(:);
end

data.mesh     = mesh2;
data_ptr.data = data;

x0 = [ u1; old_x(maps.Tpidx)   ];
V0 = [ V1; old_V(maps.Tpidx,:) ];

opts = coco_change_func(opts, data_ptr, 'x0', x0, 'vecs', V0);

status = 'success';

end
