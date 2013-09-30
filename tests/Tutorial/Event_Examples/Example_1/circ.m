function [data y] = circ(prob, data, u)
  y = u(1)^2+(u(2)-1)^2-1;
end