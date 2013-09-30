function fbc = per_bc(data, T, x0, x1, p)
  fbc = [x0-x1; data.f0*(x0-data.x0)];
end