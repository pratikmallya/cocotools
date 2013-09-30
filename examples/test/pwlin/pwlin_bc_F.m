function fbc = pwlin_bc_F(T, x0, x1, p) %#ok<INUSD,INUSL>

fbc = [ x0(:,1)-x1(:,2) ; x0(:,2)-x1(:,1) ; x0(1,:)' ];
