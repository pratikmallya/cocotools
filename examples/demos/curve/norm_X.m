function [data y] = norm_X(opts, data, u) %#ok<INUSL>
if isempty(u)
  y = 0;
else
  y = norm(u(data.x_idx));
end
end
