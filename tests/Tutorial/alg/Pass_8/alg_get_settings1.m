function data = alg_get_settings(prob, tbid, data)

data.alg.norm = coco_get(prob, tbid, 'norm');
if isempty(data.alg.norm)
  data.alg.norm = false;
end
assert(islogical(data.alg.norm), ...
  '%s: input for ''norm'' option is not boolean', tbid);

end