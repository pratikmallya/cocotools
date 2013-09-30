function [data_ptr y] = finitediff_fold4(opts, data_ptr, xp)
% We are solving the problem u''+f(u,p1,p2)=0 with boundary conditions
% u(0)=u(1)=0. This function contains additional zero functions that
% impose a rank deficit of 1 for the jacobian of the residual of the
% discretized boundary value problem with respect to the components of the
% spatial function. This is used as an additional constraint for locating
% and continuing limit points.

data = data_ptr.data;

[fdata JJ] = data.dfdx(opts, data, xp);
M = [JJ(1:data.dim+2,1:data.dim+2) data.b ; data.c' 0];

if condest(M)<1e17
    
    V = M \ [zeros(data.dim+2,1); 1];
    y = V(end);
    
else
    print('error')
    y=1;
end

data_ptr.data = data;

end