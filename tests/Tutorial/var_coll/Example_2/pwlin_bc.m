function fbc = pwlin_bc(x0, x1, p, model)

fbc = [x0 - x1 ; x1(1,:)];

end