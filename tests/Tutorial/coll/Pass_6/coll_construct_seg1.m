function prob = coll_construct_seg(prob, tbid, data, sol)

data.tbid = tbid;
data = coco_func_data(data);
prob = coco_add_func(prob, tbid, @coll_F, @coll_DFDU, data, 'zero', ...
  'u0', sol.u);
uidx = coco_get_func_data(prob, tbid, 'uidx');
if ~isempty(data.pnames)
  fid  = coco_get_id(tbid, 'pars');
  prob = coco_add_pars(prob, fid, uidx(data.maps.p_idx), data.pnames);
end
prob = coco_add_slot(prob, tbid, @coco_save_data, data, 'save_full');
efid = coco_get_id(tbid, 'err');
Nfid = coco_get_id(tbid, 'NTST');
prob = coco_add_chart_data(prob, tbid, struct(), struct());
prob = coco_add_func(prob, efid, @coll_err, data, ...
  'regular', {efid Nfid}, 'uidx', uidx(data.maps.xbp_idx), 'passChart');
prob = coco_add_event(prob, 'MXCL', 'MX', efid, '>', data.coll.TOL);
prob = coco_add_slot(prob, tbid, @coll_update, data, 'update');
prob = coco_add_slot(prob, tbid, @coll_update_h, data, 'update_h');

end

function [data y] = coll_F(prob, data, u)

maps = data.maps;

x  = u(maps.xbp_idx);
T  = u(maps.T_idx);
p  = u(maps.p_idx);
ka = u(maps.ka_idx);
la = u(maps.la_idx);

fka = ka(maps.fka_idx);
xx  = reshape(maps.W*x, maps.x_shp);
pp  = repmat(p, maps.p_rep);

ode = fka.*data.fhan(xx, pp);
ode = (0.5*T/maps.NTST)*ode(:)-maps.Wp*x;
cnt = maps.Q*x;

v   = reshape(x, maps.v_shp);
msh = v(:,1:end-1,:)-v(:,2:end,:);
msh = squeeze(sum(sqrt(sum(msh.*msh,1)),2));
msh = [ka-la*data.ka+data.h*(msh-data.mean_msh); sum(ka)-maps.NTST];

y = [ode; cnt; msh];

end

function [data J] = coll_DFDU(prob, data, u)

maps = data.maps;
int  = data.int;

x  = u(maps.xbp_idx);
T  = u(maps.T_idx);
p  = u(maps.p_idx);
ka = u(maps.ka_idx);

fka  = ka(maps.fka_idx);
dxka = ka(maps.dxka_idx);
dpka = ka(maps.dpka_idx);

xx = reshape(maps.W*x, maps.x_shp);
pp = repmat(p, maps.p_rep);

if isempty(data.dfdxhan)
  dxode = coco_ezDFDX('f(x,p)v', data.fhan, xx, pp);
else
  dxode = data.dfdxhan(xx, pp);
end
dxode = dxka.*dxode;
dxode = sparse(maps.dxrows, maps.dxcols, dxode(:));
dxode = (0.5*T/maps.NTST)*dxode*maps.W-maps.Wp;

ode   = data.fhan(xx, pp);
dTode  = fka.*ode;
dTode  = (0.5/maps.NTST)*dTode(:);
dkaode = (0.5*T/maps.NTST)*ode;
dkaode = sparse(maps.karows, maps.fka_idx, dkaode(:));

if isempty(data.dfdphan)
  dpode = coco_ezDFDP('f(x,p)v', data.fhan, xx, pp);
else
  dpode = data.dfdphan(xx, pp);
end
dpode = dpka.*dpode;
dpode = sparse(maps.dprows, maps.dpcols, dpode(:));
dpode = (0.5*T/maps.NTST)*dpode;

J1 = [dxode dTode dpode dkaode; ...
  maps.Q sparse(maps.Qnum, 1+maps.pdim+maps.NTST)];

v    = reshape(x, maps.v_shp);
du   = v(:,1:end-1,:)-v(:,2:end,:);
dsq  = 1./sqrt(sum(du.*du,1));
dsq  = du.*repmat(dsq, [int.dim 1 1]);

df1  = dsq(:,1,:);
df2  = -dsq(:,1:end-1,:)+dsq(:,2:end,:);
df3  = -dsq(:,end,:);
df   = data.h*cat(2,df1,df2,df3);

rows = reshape(1:maps.NTST, [1 1 maps.NTST]);
rows = repmat(rows, [int.dim int.NCOL+1 1]);
cols = reshape(maps.xbp_idx, maps.v_shp);
vals = df;

rows = [rows(:); (1:maps.NTST)'];
cols = [cols(:); maps.ka_idx];
vals = [vals(:); ones(maps.NTST,1)];

rows = [rows(:); (1:maps.NTST)'];
cols = [cols(:); maps.la_idx*ones(maps.NTST,1)];
vals = [vals(:); -data.ka];

rows = [rows(:); (maps.NTST+1)*ones(maps.NTST,1)];
cols = [cols(:); maps.ka_idx];
vals = [vals(:); ones(maps.NTST,1)];

J3 = sparse(rows, cols, vals);

J = sparse([J1 zeros(int.dim*(int.NCOL+1)*maps.NTST-int.dim,1); J3]);

% [data J2] = fdm_ezDFDX('f(o,d,x)', prob, data, @coll_F, u);
% spy(abs(J-J2) >1e-4)
% max(max(abs(J-J2)))

end

function [data chart y] = coll_err(prob, data, chart, u)

cdata = coco_get_chart_data(chart, data.tbid);
if isfield(cdata, 'err')
  y = cdata.err;
else
  int  = data.int;
  maps = data.maps;
  
  cp = reshape(maps.Wm*u, [int.dim maps.NTST]);
  y  = maps.wn*max(sqrt(sum(cp.^2,1)));
  y  = [y; maps.NTST];
  cdata.err = y;
  chart = coco_set_chart_data(chart, data.tbid, cdata);
end

end

function data = coll_update(prob, data, cseg, varargin)

maps = data.maps;
int  = data.int;

prcond      = cseg.prcond;
data.h_cont = prcond.h;
data.h      = data.coll.h0;

base_chart = cseg.src_chart;
uidx       = coco_get_func_data(prob, data.tbid, 'uidx');
u          = base_chart.x(uidx);
data.ka    = u(maps.ka_idx);
tmi        = [0 cumsum(data.ka')];
data.mesh  = coll_mesh(data.int, data.maps, tmi);

v   = reshape(u(maps.xbp_idx), [int.dim int.NCOL+1 maps.NTST]);
msh = v(:,1:end-1,:)-v(:,2:end,:);
msh = squeeze(sum(sqrt(sum(msh.*msh,1)),2));
data.mean_msh = mean(msh);

end

function data = coll_update_h(prob, data, h, varargin)

data.h = data.coll.h0*h/data.h_cont;

end