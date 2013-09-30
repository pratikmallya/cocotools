function data = alg_get_settings(prob, tbid, data)

defaults.norm = false;
defaults.FO   = true;
defaults.FOTF = 'fold1a' ;
data.alg = coco_merge(defaults, coco_get(prob, tbid));
assert(islogical(data.alg.norm), ...
  '%s: input for ''norm'' option is not boolean', tbid);
assert(islogical(data.alg.FO), ...
  '%s: input for ''FO'' option is not boolean', tbid);
assert(any(strcmpi(data.alg.FOTF, ...
  {'fold1a', 'fold1b', 'fold1c', 'fold2_reg', 'fold2_act'})), ...
'%s: unrecognized input for ''FOTF'' option', tbid);

end