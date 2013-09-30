%!msbvp_create
function prob = msbvp_close_segs(prob, tbid, data)

if ~isempty(data.bc_update)
  data.tbid = tbid;
  data = coco_func_data(data);
  prob = coco_add_slot(prob, tbid, @msbvp_bc_update, data, 'update');
end
T_idx  = zeros(data.nsegs,1);
x0_idx = [];
x1_idx = [];
s_idx  = cell(1, data.nsegs);
for i=1:data.nsegs
  fid      = coco_get_id(tbid,sprintf('seg%d.coll', i));
  [fdata uidx] = coco_get_func_data(prob, fid, 'data', 'uidx');
  T_idx(i) = uidx(fdata.T_idx);
  x0_idx   = [x0_idx; uidx(fdata.x0_idx)];
  x1_idx   = [x1_idx; uidx(fdata.x1_idx)];
  s_idx{i} = uidx(fdata.p_idx);
end
uidx = [T_idx; x0_idx; x1_idx; s_idx{1}];
if isempty(data.dfbcdxhan)
  prob = coco_add_func(prob, tbid, @msbvp_F, data, ...
    'zero', 'uidx', uidx);
else
  prob = coco_add_func(prob, tbid, @msbvp_F, @msbvp_DFDU, data, ...
    'zero', 'uidx', uidx);
end
for i=2:data.nsegs
  fid  = coco_get_id(tbid, sprintf('shared%d', i-1));
  prob = coco_add_glue(prob, fid, s_idx{1}, s_idx{i});
end
if ~isempty(data.pnames)
  fid  = coco_get_id(tbid, 'pars');
  prob = coco_add_pars(prob, fid, s_idx{1}, data.pnames);
end
prob = coco_add_slot(prob, tbid, @coco_save_data, data, 'save_full');

end %!end_msbvp_create
%!msbvp_F
function [data y] = msbvp_F(prob, data, u)

T  = u(data.T_idx);
x0 = u(data.x0_idx);
x1 = u(data.x1_idx);
p  = u(data.p_idx);

y  = data.fbchan(data.bc_data, T, x0, x1, p);

end %!end_msbvp_F
%!msbvp_DFDU
function [data J] = msbvp_DFDU(prob, data, u)

T  = u(data.T_idx);
x0 = u(data.x0_idx);
x1 = u(data.x1_idx);
p  = u(data.p_idx);

J  = data.dfbcdxhan(data.bc_data, T, x0, x1, p);

end %!end_msbvp_DFDU
%!msbvp_update
function data = msbvp_bc_update(prob, data, cseg, varargin)

uidx = coco_get_func_data(prob, data.tbid, 'uidx');
u    = cseg.src_chart.x(uidx);
T    = u(data.T_idx);
x0   = u(data.x0_idx);
x1   = u(data.x1_idx);
p    = u(data.p_idx);
data.bc_data = data.bc_update(data.bc_data, T, x0, x1, p);

end %!end_msbvp_update