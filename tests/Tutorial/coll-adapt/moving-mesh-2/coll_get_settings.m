function coll = coll_get_settings(opts, tbid)

defaults.NTST = 10;
defaults.NCOL = 4;
defaults.mesh = 'moving';
coll = coco_merge(defaults, coco_get(opts, tbid));

if isempty( coco_get(opts, '-no-inherit-all', tbid, 'TOL') )
  coll.TOL = coll.TOL^(2/3);
end

defaults.TOLINC = coll.TOL/5;
defaults.TOLDEC = coll.TOL/20;
defaults.NTSTMN = min( 5, coll.NTST);
defaults.NTSTMX = max(50, coll.NTST);
coll = coco_merge(defaults, coll);

end
