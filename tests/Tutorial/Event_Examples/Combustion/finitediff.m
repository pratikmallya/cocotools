function [data y] = finitediff(opts, data, xp)
% We are solving the problem u''+f(u,p1,p2)=0 with boundary conditions
% u(0)=u(1)=0. This function evaluates the residual of the discretized
% boundary value problem.

u = xp(data.u_idx);
p = xp(data.p_idx)';

y = [u(1); u(data.dim+2); ...
    data.A * u + data.h2 *...
    data.B * data.f(u, repmat(p, [data.dim+2, 1]))];

end