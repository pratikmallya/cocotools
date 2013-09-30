function [data y] = testode_bc(opts, data, u) %#ok<INUSL>

y = u(2) - u(1) - (1-1/exp(u(3)));

end
