function J = pwlin_DFDX(x, p, mode)

x1 = x(1,:);
x2 = x(2,:);
r  = sqrt(x1.^2+x2.^2);
rx = x1./r;
ry = x2./r;

m = size(r,2);
switch mode
  case 'left'
    J(1,1,:) = ones(1,m) - r - x1.*rx;
    J(1,2,:) = -ones(1,m) - x1.*ry;
    J(2,1,:) = ones(1,m) - x2.*rx;
    J(2,2,:) = ones(1,m) - r - x2.*ry;
  case 'right'
    al  = p(1,:);
    be  = p(2,:);
    ga  = p(3,:);
    al_x = al.*x1 - x2;
    al_y = al.*x2 + x1;
    
    J(1,1,:) = al.*be.*ones(1,m) - al.*r - rx.*al_x;
    J(1,2,:) = -(be + ga).*ones(1,m) + r - ry.*al_x;
    J(2,1,:) = (be + ga).*ones(1,m) - r - rx.*al_y;
    J(2,2,:) = al.*be.*ones(1,m) - al.*r - ry.*al_y;
end

end