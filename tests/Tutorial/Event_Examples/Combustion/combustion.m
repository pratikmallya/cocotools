function f = combustion(u, p)
% We are solving the problem u''+f(u,p1,p2)=0 with boundary conditions
% u(0)=u(1)=0. This function evaluates f. The function is vectorized.

f = p(:,1) .* exp(u ./ (1 + p(:,2) .* u));

end

