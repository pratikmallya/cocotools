function [J] = caricature_DP(x,p)

r   = sqrt(x(1).^2+x(2).^2);
phi = atan2(x(1),x(2));

aa   = 1-r^2;
bb = sqrt(aa^2+4*exp(2)*r^2);
rr = 2*exp(1)*r/(bb+aa);
pphi = 2*pi*p(1)+log(rr/r)+phi;

y1beta = (1-p(2))*rr*cos(pphi)*2*pi;
y1alpha = -rr*sin(pphi)+1;

y2beta = -(1-p(2))*rr*sin(pphi)*2*pi;
y2alpha= -rr*cos(pphi);

J = [y1beta y1alpha; y2beta y2alpha];