function [J]=pwlin_2_DFDX(x,p)
% p = [al be ga]

xx  = x(1,:);
yy  = x(2,:);
al  = p(1,:);
be  = p(2,:);
ga  = p(3,:);

r   = sqrt(xx.^2+yy.^2);
r_x = xx./r;
r_y = yy./r;

th   = atan2(yy,xx);
at_z = 1./(1+(yy./xx).^2);
th_x = -at_z.*(yy./xx.^2);
th_y = at_z./xx;

rp   = al.*(be-r).*r;
rp_x = al.*(be-r).*r_x - al.*r_x.*r;
rp_y = al.*(be-r).*r_y - al.*r_y.*r;

thp   = ga+(be-r);
thp_x = -r_x;
thp_y = -r_y;

J(1,1,:) = rp_x.*cos(th) - rp.*sin(th).*th_x ...
  - r_x.*sin(th).*thp - r.*cos(th).*thp.*th_x - r.*sin(th).*thp_x;
J(1,2,:) = rp_y.*cos(th) - rp.*sin(th).*th_y ...
  - r_y.*sin(th).*thp - r.*cos(th).*thp.*th_y - r.*sin(th).*thp_y;
J(2,1,:) = rp_x.*sin(th) + rp.*cos(th).*th_x ...
  + r_x.*cos(th).*thp - r.*sin(th).*thp.*th_x + r.*cos(th).*thp_x;
J(2,2,:) = rp_y.*sin(th) + rp.*cos(th).*th_y ...
  + r_y.*cos(th).*thp - r.*sin(th).*thp.*th_y + r.*cos(th).*thp_y;
