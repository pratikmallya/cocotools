function J = dfvdxp(data, u, v)
% Compute derivative of fx(x,p)*v with respect to p.
x = u(data.x_idx);
p = u(data.p_idx);
if isempty(data.fx)
  for i=1:numel(p)
    h      = 1.0e-6*(1+abs(p(i)));
    pp     = p;
    pp(i)  = pp(i)-h;
    J0     = fdm_ezDFDX('f(x,p)', data.f, x, pp);
    pp     = p;
    pp(i)  = pp(i)+h;
    J1     = fdm_ezDFDX('f(x,p)', data.f, x, pp);
    J(:,i) = (0.5/h)*(J1-J0)*v; %#ok<AGROW>
  end
else
  for i=1:numel(p)
    h      = 1.0e-6*(1+abs(p(i)));
    pp     = p;
    pp(i)  = pp(i)-h;
    J0     = data.fx(x, pp);
    pp     = p;
    pp(i)  = pp(i)+h;
    J1     = data.fx(x, pp);
    J(:,i) = (0.5/h)*(J1-J0)*v; %#ok<AGROW>
  end
end
end
