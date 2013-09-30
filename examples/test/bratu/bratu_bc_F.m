function fbc = bratu_bc_F(T, x0, x1, p) %#ok<INUSD>

fbc = [ T-1; x0(1,:) ; x1(1,:) ];
