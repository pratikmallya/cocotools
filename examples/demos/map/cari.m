function [y]=caricature(x,p)
% p = [beta alpha]

r   = sqrt(x(1,:).^2+x(2,:).^2);
phi = atan2(x(1,:), x(2,:));

aa   = 1-r.*r;
rr   = (2*exp(1.0))*r./(sqrt(aa.*aa + 4*exp(2)*(r.*r))+aa);
pphi = (2*pi)*p(1,:)+log(rr./r)+phi;

y = [ ...
  1+(1-p(2,:)).*(rr.*sin(pphi)-1); ...
    (1-p(2,:)).*(rr.*cos(pphi)  ) ...
  ];
