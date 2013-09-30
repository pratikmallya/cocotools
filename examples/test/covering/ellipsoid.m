function [data y] = ellipsoid(prob, data, u)
if u(2)>0.5 && isfield(data, 'MX')
  y = (u(2)-1)^2;
else
  y = (2*(u(1)-1))^2+u(2)^2+u(3)^2-1;
end
end