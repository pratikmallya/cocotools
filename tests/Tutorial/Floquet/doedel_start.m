function opts = doedel_start(opts, segs, p0, eps0, th0, eqs10, eqs20, vec0, lam0)

opts = coll_start(opts, 'col1', @doedel, segs(1), p0);
opts = coll_start(opts, 'col2', @doedel, segs(2), p0);

doedelf = @(x, p) doedel(x, p, []);
opts = alg_isol2sol(opts, 'alg1', doedelf, eqs10, p0);
opts = alg_isol2sol(opts, 'alg2', doedelf, eqs20, p0);

opts = doedel_create(opts, eps0, th0, vec0, lam0);

end