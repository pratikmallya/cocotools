function data = alg_get_settings(prob, tbid, data)

defaults.norm = false;
defaults.FO   = 'regular';
defaults.HB   = true;
defaults.NSad = false;
data.alg = coco_merge(defaults, coco_get(prob, tbid));
assert(islogical(data.alg.norm), ...
  '%s: input for ''norm'' option is not boolean', tbid);
assert(ischar(data.alg.FO), ...
  '%s: input for ''FO'' option is not a string', tbid);
assert(islogical(data.alg.HB), ...
  '%s: input for ''HB'' option is not boolean', tbid);
assert(islogical(data.alg.NSad), ...
  '%s: input for ''NSad'' option is not boolean', tbid);

end