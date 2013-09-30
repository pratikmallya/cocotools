function coll = coll_get_settings(opts, tbid)

defaults.NTST = 10;
defaults.NCOL = 4;
defaults.h0   = 1;
defaults.mesh = 'co-moving';
coll = coco_merge(defaults, coco_get(opts, tbid));

if ~coco_exist('TOL', 'class_prop', opts, tbid, '-no-inherit-all')
  coll.TOL = sqrt(coll.TOL);
end

defaults.TOLINC = coll.TOL/5;
defaults.TOLDEC = coll.TOL/20;
defaults.NTSTMN = min(  5, coll.NTST);
defaults.NTSTMX = max(100, coll.NTST);
coll = coco_merge(defaults, coll);

end
