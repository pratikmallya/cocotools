function prob = doedel_isol2het(prob, segs, algs, eps0, th0, vec0, lam0)

prob = coll_isol2seg(prob, 'doedel1', @doedel, @doedel_DFDX, ...
  segs(1).t0, segs(1).x0, segs(1).p0);
prob = coll_isol2seg(prob, 'doedel2', @doedel, @doedel_DFDX, ...
  segs(2).t0, segs(2).x0, segs(2).p0);

prob = alg_isol2eqn(prob, 'doedel3', @doedel, @doedel_DFDX, ...
  algs(1).x0, algs(1).p0);
prob = alg_isol2eqn(prob, 'doedel4', @doedel, @doedel_DFDX, ...
  algs(2).x0, algs(2).p0);

prob = doedel_close_het(prob, eps0, th0, vec0, lam0);

end