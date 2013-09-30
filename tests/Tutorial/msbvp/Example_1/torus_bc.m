function fbc = torus_bc(data, T, x0, x1, p)
  fbc = [T-p(4); data.F*x1-data.RF*x0; x0(2); x0(4)-x0(1)];
end