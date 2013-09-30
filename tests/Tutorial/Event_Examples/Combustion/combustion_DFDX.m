function dfdx = combustion_DFDX(u, p)
% We are solving the problem u''+f(u,p1,p2)=0 with boundary conditions
% u(0)=u(1)=0. This function evaluates the partial of f with respect to u.
% The function is vectorized.

dfdx = p(:,1) .* exp(u ./ (1 + p(:,2) .* u)) ...
    .* (1./(1 + p(:,2) .* u) - p(:,2) .* u ./ (1 + p(:,2) .* u).^2);

end

