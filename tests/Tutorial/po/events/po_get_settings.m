function data = po_get_settings(prob, tbid, data)

defaults.bifus = true;
defaults.NSad  = false;
data.po = coco_merge(defaults, coco_get(prob, tbid));
assert(islogical(data.po.bifus), ...
  '%s: input for ''bifus'' option is not boolean', tbid);
assert(islogical(data.po.NSad), ...
  '%s: input for ''NSad'' option is not boolean', tbid);

end