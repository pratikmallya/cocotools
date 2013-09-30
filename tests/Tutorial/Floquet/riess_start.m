function opts = riess_start(data, floqx0, segs0, p0, vec0, lam0, eps0)

opts = floquet_create([], data, floqx0);
opts = coll_start(opts, 'col1', @lorentz, segs0(1), p0);
opts = coll_start(opts, 'col2', @lorentz, segs0(2), p0);

opts = riess_create(opts, data, vec0, lam0, eps0);

end