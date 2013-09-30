function [data J] = finitediff_DFDX(opts, data, xp)

u = xp(data.u_idx);
p = xp(data.p_idx)';

dfdx = data.f_DX(u(1:2:2*data.dim+3),u(2:2:2*data.dim+4),...
    (0:data.dim+1)'/(data.dim+1),repmat(p, [data.dim+2, 1]));
dfdx = reshape(dfdx', [4*data.dim+8, 1]);
r = reshape((1:2*data.dim+4)', [2 data.dim+2]);
r = repmat(r, [2 1]);
r = reshape(r, [4*data.dim+8, 1]);
c = repmat(1:2*data.dim+4, [2, 1]);
c = reshape(c, [4*data.dim+8, 1]);
dfdx = sparse(r, c, dfdx, 2*data.dim+4, 2*data.dim+4);
dfdp = data.f_DP(u(1:2:2*data.dim+3),u(2:2:2*data.dim+4),...
    (0:data.dim+1)'/(data.dim+1),repmat(p, [data.dim+2, 1]));
dfdp = reshape(dfdp', [12*data.dim+24, 1]);
r = reshape((1:2*data.dim+4)', [2 data.dim+2]);
r = repmat(r, [6 1]);
r = reshape(r, [12*data.dim+24, 1]);
c = repmat(1:6, [2, 1]);
c = reshape(c, [12 1]);
c = repmat(c, [data.dim+2, 1]);
dfdp = sparse(r, c, dfdp, 2*data.dim+4, 6);

J = [1 zeros(1,2*data.dim+3) 0 0 -1 0 0 0;...
    0 1 zeros(1,2*data.dim+2) 0 0 p(6)/p(3)^2 0 0 -1/p(3); ...
    zeros(1,2*data.dim+2) 1 0 0 0 -1 0 0 0;
    zeros(1,2*data.dim+3) 1 0 0 p(6)/p(3)^2 0 0 -1/p(3);
    data.A + data.h2 *...
    data.B * dfdx ...
    data.h2 * data.B * dfdp];

end