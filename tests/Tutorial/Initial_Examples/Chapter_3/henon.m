function [data y] = henon(prob, data, u)
  y  = [u(5)-u(4)-1+u(1)*u(3)^2; u(6)-u(2)*u(3)];
end