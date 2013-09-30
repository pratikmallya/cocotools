function data = msbvp_init_data(opts, tbid, data)

xnum = 0;
for i=1:data.nsegs
  stbid = coco_get_id(tbid, sprintf('seg%d.coll', i));
  fdata = coco_get_func_data(opts, stbid, 'data');
  xnum  = xnum+numel(fdata.x0_idx);
end

data.T_idx  = (1:data.nsegs)';
data.x0_idx = data.nsegs+(1:xnum)';
data.x1_idx = data.nsegs+xnum +(1:xnum)';
data.p_idx  = data.nsegs+2*xnum+(1:fdata.pdim)';

end