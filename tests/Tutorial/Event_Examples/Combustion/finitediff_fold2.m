function [data_ptr y] = finitediff_fold2(opts, data_ptr, xp)
% We are solving the problem u''+f(u,p1,p2)=0 with boundary conditions
% u(0)=u(1)=0. This function contains additional zero functions that
% impose the existence of a null vector of the jacobian
% of the residual of the discretized boundary value problem with respect to
% the components of the discretized spatial function, such that the
% dot product with the vector c equals 1. This is used as an
% additional constraint for locating and continuing limit points.

data = data_ptr.data;

sigma = xp(data.sigma_idx);
[data JJ] = data.dfdx(opts, data, xp);

y = [JJ(1:data.dim+2,1:data.dim+2)*sigma; data.c'*sigma-1];

data_ptr.data = data;

end