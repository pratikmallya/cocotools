function [data y] = circle(prob, data, u)
if u(1)<1 && isfield(data, 'MX')
  y = u(1)^2;
else
  y = (u(1)-1)^2+u(2)^2-1;
end
end