function mh_imf = imf_get_settings(opts, prefix)

fid    = coco_get_id(prefix, 'mh_imf');
mh_imf = coco_get(opts, fid);

defaults.collocation = 'coll';

mh_imf = coco_set(defaults, mh_imf);

end
