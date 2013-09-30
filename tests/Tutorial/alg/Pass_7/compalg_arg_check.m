function compalg_arg_check(prob, tbid, data)

assert(data.neqs~=0, '%s: insufficient number of equations', tbid);
pnum = [];
for i=1:data.neqs
  fid   = coco_get_id(tbid,sprintf('eqn%d.alg', i));
  fdata = coco_get_func_data(prob, fid, 'data');
  assert(isempty(fdata.pnames), ...
    '%s: parameter labels must not be passed to alg', tbid);
  assert(isempty(pnum) || pnum==numel(fdata.p_idx), '%s: %s', ...
    tbid, 'number of parameters must be equal for all equations');
  pnum = numel(fdata.p_idx);
end
assert(pnum==numel(data.pnames) || isempty(data.pnames), ...
  '%s: incompatible number of elements for ''pnames''', ...
  tbid);

end