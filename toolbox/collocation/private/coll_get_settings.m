function coll = coll_get_settings(opts, prefix)

fid  = coco_get_id(prefix, 'coll');
coll = coco_get(opts, fid);

defaults.vareqn = 'off';
defaults.NTST   = 10;
defaults.NCOL   = 4;
defaults.bpdist = 'linspace';

defaults.cont.NSV      = 1000;
defaults.cont.ItMX     = [1000 0];
defaults.cont.LogLevel = 1;

coll = coco_set(defaults, coll);
end
