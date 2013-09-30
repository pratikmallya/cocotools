function [data y] = empty(opts, data, u) %#ok<INUSL>
y(1,1) = u(1)^2+u(2)^2 + 1;
end
