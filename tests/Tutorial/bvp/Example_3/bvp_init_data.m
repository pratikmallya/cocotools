function data = bvp_init_data(prob, tbid, data)

segtbid = coco_get_id(tbid, 'seg.coll');
fdata   = coco_get_func_data(prob, segtbid, 'data');

data.T_idx  = 1;
data.x0_idx = 1+(1:fdata.dim)';
data.x1_idx = 1+fdata.dim+(1:fdata.dim)';
data.p_idx  = 1+2*fdata.dim+(1:fdata.pdim)';

end