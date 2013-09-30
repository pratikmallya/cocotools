function prob = varcoll_isol2seg(prob, oid, dfdxdx, dfdxdp)

tbid = coco_get_id(oid, 'coll');
[data u0] = coco_get_func_data(prob, tbid, 'data', 'u0');
data.dfdxdxhan = dfdxdx;
data.dfdxdphan = dfdxdp;

data.varcoll.NBIT=10;
data = varcoll_init_data(data, u0);
sol  = data.M0(:);
prob = varcoll_close_seg(prob, tbid, data, sol);

end