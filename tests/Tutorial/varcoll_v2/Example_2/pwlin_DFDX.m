function J = pwlin_DFDX(x, p, model)

x1 = x(1,:);
x2 = x(2,:);
r  = sqrt(x1.^2+x2.^2);
rx = x1./r;
ry = x2./r;
switch model.seg
  case 1
    J(1,1,:) = ones(size(r)) - r - x1.*rx;
    J(1,2,:) = -ones(size(r)) - x1.*ry;
    J(2,1,:) = ones(size(r)) - x2.*rx;
    J(2,2,:) = ones(size(r)) - r - x2.*ry;
  case 2
    al  = p(1,:);
    be  = p(2,:);
    ga  = p(3,:);
    al_x = al.*x1 - x2;
    al_y = al.*x2 + x1;
    J(1,1,:) = al.*be.*ones(size(r)) - al.*r - rx.*al_x;
    J(1,2,:) = -(be + ga).*ones(size(r)) + r - ry.*al_x;
    J(2,1,:) = (be + ga).*ones(size(r)) - r - rx.*al_y;
    J(2,2,:) = al.*be.*ones(size(r)) - al.*r - ry.*al_y;
end

end