function J = pwlin_bc_DFDX(x0, x1, p, model)

Jbcp = zeros(3,3);
Jbcx0 = [  1 0 ; 0  1 ; 0 0 ];
Jbcx1 = [ -1 0 ; 0 -1 ; 1 0 ];

J = [Jbcx0 Jbcx1 Jbcp];

end