function J = fp_jacobian(data, u)
%Call: J = jacobian(data,u)
% Coco function for mappings

x = u(data.x_idx);
p = u(data.p_idx);
if isempty(data.fx)
  J = fdm_ezDFDX('f(x,p)', data.f, x, p);
  for j=2:data.k
    x = data.f(x,p);
    J = fdm_ezDFDX('f(x,p)', data.f, x, p)*J;
  end
else
  J = data.fx(x, p);
  for j=2:data.k
    x = data.f(x,p);
    J = data.fx(x, p)*J;
  end
end

end
