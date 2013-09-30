function [data y] = lemniscate(opts, data, u)
y = (u(1)^2+u(2)^2)^2+u(2)^2-u(1)^2;
end
