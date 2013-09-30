function [data J] = finitediff_DFDP(opts, data, xp)
% We are solving the problem u''+f(u,p1,p2)=0 with boundary conditions
% u(0)=u(1)=0. This function evaluates the jacobian of the residual of the
% discretized boundary value problem with respect to p1 and p2.

u = xp(data.u_idx);
p = xp(data.p_idx)';

J = [zeros(2,2);...
    data.h2 * data.B * data.f_DP(u, repmat(p, [data.dim+2, 1]))];

end