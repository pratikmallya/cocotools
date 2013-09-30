function [data y] = finitediff_fold1(opts, data, xp)
% We are solving the problem u''+f(u,p1,p2)=0 with boundary conditions
% u(0)=u(1)=0. This function evaluates the determinant of the jacobian
% of the residual of the discretized boundary value problem with respect to
% the components of the discretized spatial function. This is used as a
% test function for limit points.

[data JJ] = data.dfdx(opts, data, xp);

y = det(JJ(1:data.dim+2,1:data.dim+2));

end