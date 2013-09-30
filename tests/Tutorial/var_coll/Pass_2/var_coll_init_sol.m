function M0 = var_coll_init_sol(prob, data)

[fdata u0] = coco_get_func_data(prob, data.coll_id, 'data', 'u0');

x = u0(fdata.xbp_idx);
T = u0(fdata.T_idx);
p = u0(fdata.p_idx);

xx = reshape(fdata.W*x, fdata.x_shp);
pp = repmat(p, fdata.p_rep);

if isempty(fdata.dfdxhan)
  dxode = coco_ezDFDX('f(x,p)v', fdata.fhan, xx, pp);
else
  dxode = fdata.dfdxhan(xx, pp);
end
dxode = sparse(fdata.dxrows, fdata.dxcols, dxode(:));
dxode = (0.5*T/fdata.coll.NTST)*dxode*fdata.W-fdata.Wp;

M0 = [data.R; dxode; fdata.Q]\data.R';

end