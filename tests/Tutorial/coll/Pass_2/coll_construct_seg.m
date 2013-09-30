%!coll_create
function prob = coll_construct_seg(prob, tbid, data, sol)

prob = coco_add_func(prob, tbid, @coll_F, @coll_DFDU, data, 'zero', ...
  'u0', sol.u);
if ~isempty(data.pnames)
  fid  = coco_get_id(tbid, 'pars');
  uidx = coco_get_func_data(prob, tbid, 'uidx');
  prob = coco_add_pars(prob, fid, uidx(data.p_idx), data.pnames);
end
prob = coco_add_slot(prob, tbid, @coco_save_data, data, 'save_full');

end %!end_coll_create
%!coll_F
function [data y] = coll_F(prob, data, u)

x = u(data.xbp_idx);
T = u(data.T_idx);
p = u(data.p_idx);

xx = reshape(data.W*x, data.x_shp);
pp = repmat(p, data.p_rep);

ode = data.fhan(xx, pp);
ode = (0.5*T/data.coll.NTST)*ode(:)-data.Wp*x;
cnt = data.Q*x;

y = [ode; cnt];

end %!end_coll_F
%!coll_DFDX
function [data J] = coll_DFDU(prob, data, u)

x = u(data.xbp_idx);
T = u(data.T_idx);
p = u(data.p_idx);

xx = reshape(data.W*x, data.x_shp);
pp = repmat(p, data.p_rep);

if isempty(data.dfdxhan)
  dxode = coco_ezDFDX('f(x,p)v', data.fhan, xx, pp);
else
  dxode = data.dfdxhan(xx, pp);
end
dxode = sparse(data.dxrows, data.dxcols, dxode(:));
dxode = (0.5*T/data.coll.NTST)*dxode*data.W-data.Wp;

dTode = data.fhan(xx, pp);
dTode = (0.5/data.coll.NTST)*dTode(:);

if isempty(data.dfdphan)
  dpode = coco_ezDFDP('f(x,p)v', data.fhan, xx, pp);
else
  dpode = data.dfdphan(xx, pp);
end
dpode = sparse(data.dprows, data.dpcols, dpode(:));
dpode = (0.5*T/data.coll.NTST)*dpode;

J = [dxode dTode dpode; data.Q data.dTpcnt];

end %!end_coll_DFDX

% [data Jt] = fdm_ezDFDX('f(o,d,x)', prob, data, @coll_F, u);
% spy(abs(J-Jt) >1e-4)
% max(max(abs(J-Jt)))