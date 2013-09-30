function [data y] = finitediff(opts, data, xp)

u = xp(data.u_idx);
p = xp(data.p_idx)';

f = data.f(u(1:2:2*data.dim+3),u(2:2:2*data.dim+4),...
    (0:data.dim+1)'/(data.dim+1),repmat(p, [data.dim+2, 1]));
f = reshape(f', [2*data.dim+4, 1]);

y = [u(1) - p(3); ...
    u(2) - p(6)/p(3); ...
    u(2*data.dim+3) - p(3); ...
    u(2*data.dim+4) - p(6)/p(3); ...
    data.A * u + data.h2 * data.B * f];

end