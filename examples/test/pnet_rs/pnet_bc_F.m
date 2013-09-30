function fbc = pnet_bc_F(T, x0, x1, p)

fbc = [
  x0(1:2,:)-x1(1:2,:)
  x0(3,:)
  p(3,:)-T
  ];
