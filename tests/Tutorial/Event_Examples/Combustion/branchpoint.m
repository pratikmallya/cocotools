function [data_ptr y] = branchpoint(opts, data_ptr, xp)
% We are solving the problem u''+f(u,p1,p2)=0 with boundary conditions
% u(0)=u(1)=0. This function evaluates the branchpoint conditions.

data = data_ptr.data;

[data Jp] = data.dfdp([], data, xp);

y = data.b' * Jp;

data_ptr.data = data;

end