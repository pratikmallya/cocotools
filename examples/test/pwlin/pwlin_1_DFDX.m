function [J]=pwlin_1_DFDX(x,p) %#ok<INUSD>
% p = [al be ga]

xx = x(1,:);
yy = x(2,:);

r   = sqrt(xx.^2+yy.^2);
r_x = xx./r;
r_y = yy./r;

th   = atan2(yy,xx);
at_z = 1./(1+(yy./xx).^2);
th_x = -at_z.*(yy./xx.^2);
th_y = at_z./xx;

rp   = (1-r).*r;
rp_x = (1-r).*r_x - r_x.*r;
rp_y = (1-r).*r_y - r_y.*r;

thp   = ones (size(r));
thp_x = zeros(size(r));
thp_y = zeros(size(r));

J(1,1,:) = rp_x.*cos(th) - rp.*sin(th).*th_x ...
  - r_x.*sin(th).*thp - r.*cos(th).*thp.*th_x - r.*sin(th).*thp_x;
J(1,2,:) = rp_y.*cos(th) - rp.*sin(th).*th_y ...
  - r_y.*sin(th).*thp - r.*cos(th).*thp.*th_y - r.*sin(th).*thp_y;
J(2,1,:) = rp_x.*sin(th) + rp.*cos(th).*th_x ...
  + r_x.*cos(th).*thp - r.*sin(th).*thp.*th_x + r.*cos(th).*thp_x;
J(2,2,:) = rp_y.*sin(th) + rp.*cos(th).*th_y ...
  + r_y.*cos(th).*thp - r.*sin(th).*thp.*th_y + r.*cos(th).*thp_y;
