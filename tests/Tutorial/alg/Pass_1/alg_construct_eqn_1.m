function prob = alg_construct_eqn(fhan, x0, pnames, p0)

xdim = numel(x0);
pdim = numel(p0);

prob = coco_prob();
prob = coco_add_func(prob, 'alg', fhan, [], 'zero', ...
  'u0', [x0(:); p0(:)]);
prob = coco_add_pars(prob, 'pars', xdim+(1:pdim), pnames);

end