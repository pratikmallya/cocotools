function [data y] = circle(opts, data, u)
if isfield(data, 'pt') && ...
  isfield(opts, 'cseg') && ...
  isfield(opts.cseg.base_chart, 'pt') && data.pt == opts.cseg.base_chart.pt
  y = u(1)^2 + u(2)^2 + 1;
else
  y = (u(1)-1)^2 + u(2)^2 - 1;
end
end
