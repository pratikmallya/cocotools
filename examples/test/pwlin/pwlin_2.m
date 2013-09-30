function [y]=pwlin_2(x,p)
% p = [al be ga]

xx  = x(1,:);
yy  = x(2,:);
al  = p(1,:);
be  = p(2,:);
ga  = p(3,:);

r   = sqrt(xx.^2+yy.^2);
th  = atan2(yy,xx);

rp  = al.*(be-r).*r;
thp = ga+(be-r);

y(1,:) = rp.*cos(th) - r.*sin(th).*thp;
y(2,:) = rp.*sin(th) + r.*cos(th).*thp;
