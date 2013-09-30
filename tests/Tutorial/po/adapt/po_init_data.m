function data = po_init_data(prob, tbid, data)

stbid      = coco_get_id(tbid, 'seg.coll');
[fdata u0] = coco_get_func_data(prob, stbid, 'data', 'u0');

dim  = fdata.int.dim;
NTST = fdata.coll.NTST;
NCOL = fdata.coll.NCOL;
rows = [1:dim 1:dim];
cols = [fdata.maps.x0_idx fdata.maps.x1_idx];
vals = [ones(1,dim) -ones(1,dim)];
J    = sparse(rows, cols, vals, dim, dim*NTST*(NCOL+1));

data.x0_idx = fdata.maps.x0_idx;
data.x1_idx = fdata.maps.x1_idx;
data.intfac = fdata.maps.Wp'*fdata.mesh.wts2*fdata.maps.W;
data.xp0    = u0(fdata.maps.xbp_idx)'*data.intfac;
data.J      = [J; data.xp0];

end