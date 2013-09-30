function [opts t] = coverkd_tangent(opts, x)

%% compute Jacobian of extended system at u0
xfunc    = opts.(opts.cont.xfunc);
[opts J] = xfunc.DFDX(opts, x);

%% compute tangent vector as solution of DF/DS*t = [0...0 1]
b        = zeros(size(x,1), opts.cont.k);
b((end-opts.cont.k+1):end,:) = ...
  eye(opts.cont.k,opts.cont.k);
[opts t] = opts.xfunc.linsolve(opts, J, b);
t        = orth(t);
