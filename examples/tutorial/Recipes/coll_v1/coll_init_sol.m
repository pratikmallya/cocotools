function sol = coll_init_sol(data, t0, x0, p0)
% 7.2.3  An embeddable generalized constructor
%
% SOL = COLL_INIT_SOL(DATA, T0, X0, P0)
%
% Initialize collocation toolbox solution structure.
%
%   See also: coll_v1

t0 = t0(:);
T0 = t0(end)-t0(1);
t0 = (t0-t0(1))/T0;
x0 = interp1(t0, x0, data.tbp)';

sol.u = [x0(:); T0; p0];

end