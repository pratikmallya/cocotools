function data = hspo_get_settings(prob, tbid)

defaults.bifus = true;
defaults.NSad  = false;
data.hspo = coco_merge(defaults, coco_get(prob, tbid));
assert(islogical(data.hspo.bifus), ...
  '%s: input for ''bifus'' option is not boolean', tbid);
assert(islogical(data.hspo.NSad), ...
  '%s: input for ''NSad'' option is not boolean', tbid);

end