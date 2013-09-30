function [data J] = catenary_bc_DFDX(opts, data, u) %#ok<INUSD,INUSL>

J = [
  1 0  0
  0 1 -1
  ];

end
