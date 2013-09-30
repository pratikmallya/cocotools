function J = dfvdxx(data, u, v)
% Compute derivative of fx(x,p)*v with respect to x.
x = u(data.x_idx);
p = u(data.p_idx);
if isempty(data.fx)
  h  = 1.0e-6*(1+norm(x));
  J0 = fdm_ezDFDX('f(x,p)', data.f, x-h*v, p);
  J1 = fdm_ezDFDX('f(x,p)', data.f, x+h*v, p);
else
  h  = 1.0e-8*(1+norm(x));
  J0 = data.fx(x-h*v, p);
  J1 = data.fx(x+h*v, p);
end
J = (0.5/h)*(J1-J0);
end
