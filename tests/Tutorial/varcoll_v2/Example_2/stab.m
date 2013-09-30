function evs = stab(nseg, rrun, rlab)

P = eye(2);
for i=1:nseg
  [data chart] = ...
    coco_read_solution(sprintf('hspo.seg%d.coll',i), rrun, rlab);
  x1 = chart.x(data.x1_idx);
  p  = chart.x(data.p_idx);
  fs = pwlin(x1, p, data.model);
  J  = pwlin_bc_DFDX(x1, x1, p, data.model);
  hx = J(data.dim+1, data.dim+1:data.dim+2);
  gx = -J(1:data.dim, data.dim+1:data.dim+2);
  
  prob    = coco_prob();
  varprob = var_sol2var(prob, sprintf('hspo.seg%d', i), rrun, rlab);
  varprob = coco_set(varprob, 'cont', 'ItMX', 2000);
  bd      = coco(varprob, sprintf('var%d', i), [], 1, 'beta', [0 1]);
  labs    = coco_bd_labs(bd, 'EP');
  
  [data chart] = ...
    coco_read_solution(sprintf('hspo.seg%d.var',i), ...
    sprintf('var%d', i), labs(end));
  mat = reshape(chart.x(data.x_idx), ...
    [numel(data.x_idx)/data.dim data.dim]);
  m0  = mat(1:data.dim, 1:data.dim);
  m1  = mat(end-data.dim+1:end, 1:data.dim);
  
  P = (gx*(eye(2)-(fs*hx)/(hx*fs))*m1/m0)*P;
end

evs = eig(P);

end