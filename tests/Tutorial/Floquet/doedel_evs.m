function [data y] = doedel_evs(opts, data, xp) %#ok<INUSL>

par = xp(1:2,:);
eqs = xp(3:4,:);
vec = xp(end-3:end-1,:);
lam = xp(end,:);

jac = data.jac(eqs, par, 2);

y = [jac*vec - lam*vec; vec'*vec - 1];

end

