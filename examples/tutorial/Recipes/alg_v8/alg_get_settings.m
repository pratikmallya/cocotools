function data = alg_get_settings(prob, tbid, data)

defaults.norm = false;
data.alg = coco_merge(defaults, coco_get(prob, tbid));
assert(islogical(data.alg.norm), ...
  '%s: input for ''norm'' option is not boolean', tbid);

end