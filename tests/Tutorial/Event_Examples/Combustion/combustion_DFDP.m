function dfdp = combustion_DFDP(u, p)
% We are solving the problem u''+f(u,p1,p2)=0 with boundary conditions
% u(0)=u(1)=0. This function evaluates the partial of f with respect to p1
% and p2. The function is vectorized.

dfdp = [ exp(u ./ (1 + p(:,2) .* u)) p(:,1) .* ...
    exp(u ./ (1 + p(:,2) .* u)) .*...
    (- u.^2 ./ (1 + p(:,2) .* u).^2)];

end

