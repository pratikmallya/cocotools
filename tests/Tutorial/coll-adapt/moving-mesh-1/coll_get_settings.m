function coll = coll_get_settings(opts, tbid)

defaults.NTST = 10;
defaults.NCOL = 4;
defaults.mesh = 'moving';
coll = coco_merge(defaults, coco_get(opts, tbid));

if ~coco_exist('TOL', 'class_prop', opts, tbid, '-no-inherit-all')
  coll.TOL = coll.TOL^(2/3);
end

end
