function fbc = caty_bc(T, x0, x1, p)
fbc = [T-1; x0(1)-1; x1(1)-p];
end