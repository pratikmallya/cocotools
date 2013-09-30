%!var_coll_add
function prob = var_coll_add(prob, segoid, dfdxdx, dfdxdp)

tbid = coco_get_id(segoid, 'var');
data.coll_id   = coco_get_id(segoid, 'coll');
data.dfdxdxhan = dfdxdx;
data.dfdxdphan = dfdxdp;

data = var_coll_init_data(prob, data);
M0   = var_coll_init_sol(prob, data);
uidx = coco_get_func_data(prob, data.coll_id, 'uidx');
prob = coco_add_func(prob, tbid, @var_coll_F, @var_coll_DFDU, ...
  data, 'zero', 'uidx', uidx, 'u0', M0);
prob = coco_add_slot(prob, tbid, @coco_save_data, data, 'save_full');

end %!end_var_coll_add
%!var_coll_F
function [data y] = var_coll_F(prob, data, u)

fdata = coco_get_func_data(prob, data.coll_id, 'data');

ubp = u(data.ubp_idx);
T   = u(fdata.T_idx);
x   = u(fdata.xbp_idx);
p   = u(fdata.p_idx);

Mbp = reshape(ubp, data.u_shp);
xx  = reshape(fdata.W*x, fdata.x_shp);
pp  = repmat(p, fdata.p_rep);

ode = fdata.dfdxhan(xx, pp);
ode = sparse(fdata.dxrows, fdata.dxcols, ode(:));
ode = (0.5*T/fdata.coll.NTST)*ode*fdata.W-fdata.Wp;
ode = ode*Mbp;
cnt = fdata.Q*Mbp;
bcd = data.R*Mbp-data.Id;

y = [ode(:); cnt(:); bcd(:)];

end %!end_var_coll_F
%!var_coll_DFDU
function [data J] = var_coll_DFDU(prob, data, u)

fdata = coco_get_func_data(prob, data.coll_id, 'data');

NTST = fdata.coll.NTST;

ubp = u(data.ubp_idx);
T   = u(fdata.T_idx);
x   = u(fdata.xbp_idx);
p   = u(fdata.p_idx);

Mbp = reshape(ubp, data.u_shp);
xx  = reshape(fdata.W*x, fdata.x_shp);
pp  = repmat(p, fdata.p_rep);

dfdx = fdata.dfdxhan(xx, pp);
dfdx = sparse(fdata.dxrows, fdata.dxcols, dfdx(:));

dfdxdx = data.dfdxdxhan(xx, pp);
dfdxdx = sparse(data.dxdxrows1, data.dxdxcols1, dfdxdx(:));
dxode  = dfdxdx*fdata.W;
dxode  = sparse(data.dxdxrows2, data.dxdxcols2, dxode(:))*fdata.W*Mbp;
dxode  = (0.5*T/NTST)*sparse(data.dxdxrows3, data.dxdxcols3, dxode(:));

dTode  = (0.5/NTST)*dfdx*fdata.W*Mbp;

dfdxdp = data.dfdxdphan(xx, pp);
dpode  = sparse(data.dxdprows, data.dxdpcols, dfdxdp(:));
dpode  = dpode*kron(speye(fdata.pdim), fdata.W*Mbp);
dpode  = (0.5*T/NTST)*reshape(dpode, data.dxdp_shp);

duode  = kron(data.Id, (0.5*T/NTST)*dfdx*fdata.W-fdata.Wp);

J = [dxode, dTode(:), dpode, duode; data.jac];

end %!end_var_coll_DFDU

% [data Jt] = coco_ezDFDX('f(o,d,x)', prob, data, @var_coll_F, u);