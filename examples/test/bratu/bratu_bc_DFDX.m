function [JbcT Jbcx0 Jbcx1 Jbcp] = bratu_bc_DFDX(T, x0, x1, p) %#ok<INUSD>

JbcT  = [   1 ;   0 ;   0 ];
Jbcx0 = [ 0 0 ; 1 0 ; 0 0 ];
Jbcx1 = [ 0 0 ; 0 0 ; 1 0 ];
Jbcp  = [   0 ;   0 ;   0 ];
