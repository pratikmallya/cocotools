function Jbc = caty_bc_DFDX(T, x0, x1, p)

Jbc = zeros(3,6);
Jbc(1,1) = 1;
Jbc(2,2) = 1;
Jbc(3,4) = 1;
Jbc(3,6) = -1;

end