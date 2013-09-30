function [data y] = per_bc(opts, data, u)

y = [u(1:2)-u(4:5); u(6)-u(3)-2*pi; u(1)];

end
