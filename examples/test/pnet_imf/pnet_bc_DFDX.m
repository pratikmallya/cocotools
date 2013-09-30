function [JbcT Jbcx0 Jbcx1 Jbcp] = pnet_bc_DFDX(T, x0, x1, p) %#ok<INUSD>

JbcT  =  [
   0
   0
   0
  -1
  ];

Jbcx0 =  [
  1 0 0
  0 1 0
  0 0 1
  0 0 0
  ];

Jbcx1 = -[
  1 0 0
  0 1 0
  0 0 0
  0 0 0
  ];

Jbcp  =  [
  0 0 0
  0 0 0
  0 0 0
  0 0 1
  ];
