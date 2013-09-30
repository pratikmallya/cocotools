function [data y] = catenary_bc(opts, data, u) %#ok<INUSL>
y = [
  u(1)-1
  u(2)-u(3)
  ];
end