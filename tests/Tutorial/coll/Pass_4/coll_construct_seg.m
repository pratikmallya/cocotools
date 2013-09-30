%!coll_create
function prob = coll_construct_seg(prob, tbid, data, sol)

data.tbid = tbid;
data = coco_func_data(data);
prob = coco_add_func(prob, tbid, @coll_F, @coll_DFDU, data, 'zero', ...
  'u0', sol.u, 'remesh', @coll_remesh);
uidx = coco_get_func_data(prob, tbid, 'uidx');
if ~isempty(data.pnames)
  fid  = coco_get_id(tbid, 'pars');
  prob = coco_add_pars(prob, fid, uidx(data.maps.p_idx), data.pnames);
end
prob = coco_add_slot(prob, tbid, @coco_save_data, data, 'save_full');
efid = coco_get_id(tbid, {'err' 'err_TF'});
prob = coco_add_chart_data(prob, tbid, struct(), struct());
prob = coco_add_func(prob, efid{1}, @coll_err, data, ...
  'regular', efid, 'uidx', uidx(data.maps.xbp_idx), ...
  'remesh', @coll_err_remesh, 'passChart');
prob = coco_add_event(prob, 'MXCL', 'MX', efid{2}, '>', 1);

end %!end_coll_create
%!coll_F
function [data y] = coll_F(prob, data, u)

maps = data.maps;
mesh = data.mesh;

x = u(maps.xbp_idx);
T = u(maps.T_idx);
p = u(maps.p_idx);

xx = reshape(maps.W*x, maps.x_shp);
pp = repmat(p, maps.p_rep);

ode = mesh.fka.*data.fhan(xx, pp);
ode = (0.5*T/maps.NTST)*ode(:)-maps.Wp*x;
cnt = maps.Q*x;

y = [ode; cnt];

end %!end_coll_F
%!coll_DFDU
function [data J] = coll_DFDU(prob, data, u)

maps = data.maps;
mesh = data.mesh;

x = u(maps.xbp_idx);
T = u(maps.T_idx);
p = u(maps.p_idx);

xx = reshape(maps.W*x, maps.x_shp);
pp = repmat(p, maps.p_rep);

if isempty(data.dfdxhan)
  dxode = coco_ezDFDX('f(x,p)v', data.fhan, xx, pp);
else
  dxode = data.dfdxhan(xx, pp);
end
dxode = mesh.dxka.*dxode;
dxode = sparse(maps.dxrows, maps.dxcols, dxode(:));
dxode = (0.5*T/maps.NTST)*dxode*maps.W-maps.Wp;

dTode = mesh.fka.*data.fhan(xx, pp);
dTode = (0.5/maps.NTST)*dTode(:);

if isempty(data.dfdphan)
  dpode = coco_ezDFDP('f(x,p)v', data.fhan, xx, pp);
else
  dpode = data.dfdphan(xx, pp);
end
dpode = mesh.dpka.*dpode;
dpode = sparse(maps.dprows, maps.dpcols, dpode(:));
dpode = (0.5*T/maps.NTST)*dpode;

J = [dxode dTode dpode; maps.Q sparse(maps.Qnum,1+maps.pdim)];

end %!end_coll_DFDU
%!coll_remesh
function [prob stat xtr] = coll_remesh(prob, data, chart, ub, Vb)

int  = data.int;
maps = data.maps;
mesh = data.mesh;
coll = data.coll;

xtr  = maps.xtr;

u = ub(maps.xbp_idx);
V = Vb(maps.xbp_idx,:);

cp   = reshape(maps.Wm*u, [int.dim maps.NTST]);
cp   = sqrt(sum(cp.^2,1));
cp   = nthroot(cp, int.NCOL);
cpmn = nthroot(0.125*coll.TOL/maps.wn, int.NCOL);

ka = mesh.ka;
s  = data.coll.SAD;
F  = [0 cumsum((1-s)*cpmn*ka + s*cp, 2)];
t  = [0 cumsum(ka, 2)];
th = linspace(0, F(end), maps.NTST+1);
tt = interp1(F, t, th, 'cubic');

mesh2 = coll_mesh(int, maps, tt);

tbp = mesh.tbp(maps.tbp_idx);
xbp = reshape(u, maps.xbp_shp);
xbp = xbp(:, maps.tbp_idx);
x0  = interp1(tbp', xbp', mesh2.tbp, 'cubic')';
x1  = x0(:);

V1 = zeros(size(V));
for i=1:size(V,2)
  vbp = reshape(V(:,i), maps.xbp_shp);
  vbp = vbp(:, maps.tbp_idx);
  v0  = interp1(tbp', vbp', mesh2.tbp, 'cubic')';
  V1(:,i) = v0(:);
end

data.mesh = mesh2;

ua = [x1; ub(maps.Tp_idx)];
Va = [V1; Vb(maps.Tp_idx,:)];

prob = coco_change_func(prob, data, 'x0', ua, 'vecs', Va);

stat = 'success';

end %!end_coll_remesh
%!coll_err
function [data chart y] = coll_err(prob, data, chart, u)

cdata = coco_get_chart_data(chart, data.tbid);
if isfield(cdata, 'err')
  y = cdata.err;
else
  int  = data.int;
  maps = data.maps;
  
  cp = reshape(maps.Wm*u, [int.dim maps.NTST]);
  y  = maps.wn*max(sqrt(sum(cp.^2,1)));
  y  = [y; y/data.coll.TOL];
  cdata.err = y;
  chart = coco_set_chart_data(chart, data.tbid, cdata);
end

end %!end_coll_err
%!coll_err_remesh
function [prob stat xtr] = coll_err_remesh(prob, data, chart, ub, Vb)

maps = data.maps;

xtr  = [];
uidx = coco_get_func_data(prob, data.tbid, 'uidx');
prob = coco_change_func(prob, data, 'uidx', uidx(maps.xbp_idx));
stat = 'success';

end %!end_coll_err_remesh