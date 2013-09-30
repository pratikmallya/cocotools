function [JbcT Jbcx0 Jbcx1 Jbcp] = pwlin_bc_DFDX(T, x0, x1, p) %#ok<INUSD>

JbcT = zeros(6,2);
Jbcp = zeros(6,3);

Jbcx0 = [
  1 0 0 0
  0 1 0 0
  0 0 1 0
  0 0 0 1
  1 0 0 0
  0 0 1 0
  ];

Jbcx1 = - [
  0 0 1 0
  0 0 0 1
  1 0 0 0
  0 1 0 0
  0 0 0 0
  0 0 0 0
  ];
