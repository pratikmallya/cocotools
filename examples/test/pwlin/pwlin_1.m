function [y]=pwlin_1(x,p) %#ok<INUSD>
% p = [al be ga]

xx  = x(1,:);
yy  = x(2,:);

r   = sqrt(xx.^2+yy.^2);
th  = atan2(yy,xx);

rp  = (1-r).*r;
thp = ones(size(r));

y(1,:) = rp.*cos(th) - r.*sin(th).*thp;
y(2,:) = rp.*sin(th) + r.*cos(th).*thp;
