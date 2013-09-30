function data = alg_get_settings(prob, tbid, data)

defaults.norm = false;
defaults.FO   = 'regular';
data.alg = coco_merge(defaults, coco_get(prob, tbid));
assert(islogical(data.alg.norm), ...
  '%s: input for ''norm'' option is not boolean', tbid);
assert(ischar(data.alg.FO), ...
  '%s: input for ''FO'' option is not a string', tbid);

end