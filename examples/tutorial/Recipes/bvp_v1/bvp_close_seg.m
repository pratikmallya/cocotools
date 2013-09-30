%!bvp_create
function prob = bvp_close_seg(prob, tbid, data)

segtbid  = coco_get_id(tbid, 'seg.coll');
[fdata uidx] = coco_get_func_data(prob, segtbid, 'data', 'uidx');
uidx = uidx([fdata.T_idx; fdata.x0_idx; fdata.x1_idx; fdata.p_idx]);
if isempty(data.dfdxhan)
  prob = coco_add_func(prob, tbid, @bvp_F, data, 'zero', 'uidx', uidx);
else
  prob = coco_add_func(prob, tbid, @bvp_F, @bvp_DFDU, data, 'zero', ...
    'uidx', uidx);
end
prob = coco_add_slot(prob, tbid, @coco_save_data, data, 'save_full');

end %!end_bvp_create 
%!bvp_F
function [data y] = bvp_F(prob, data, u)

T  = u(data.T_idx);
x0 = u(data.x0_idx);
x1 = u(data.x1_idx);
p  = u(data.p_idx);

y  = data.fhan(T, x0, x1, p);

end %!end_bvp_F
%!bvp_DFDU
function [data J] = bvp_DFDU(prob, data, u)

T  = u(data.T_idx);
x0 = u(data.x0_idx);
x1 = u(data.x1_idx);
p  = u(data.p_idx);

J  = data.dfdxhan(T, x0, x1, p);

end %!end_bvp_DFDU