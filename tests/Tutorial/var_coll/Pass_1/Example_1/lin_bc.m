function fbc = lin_bc(T, x0, x1, p)
  fbc = [x1(1:2)-x0(1:2); x1(3)-x0(3)-2*pi; x0(1)];
end