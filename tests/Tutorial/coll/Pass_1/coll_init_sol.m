function sol = coll_init_sol(data, t0, x0, p0)

t0 = t0(:);
T0 = t0(end)-t0(1);
t0 = (t0-t0(1))/T0;
x0 = interp1(t0, x0, data.tbp)';

sol.u = [x0(:); T0; p0];

end