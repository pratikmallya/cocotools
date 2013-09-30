function [J] = caricature_DX(x,p)

phi = atan2(x(1),x(2));
phix= x(2)/(x(1)^2+x(2)^2);
phiy= -x(1)/(x(1)^2+x(2)^2);

r   = sqrt(x(1).^2+x(2).^2);
rx = x(1)/r;
ry = x(2)/r;

aa   = 1-r^2;
aax = -2*r*rx;
aay = -2*r*ry;

bb = sqrt(aa^2+4*exp(2)*r^2);
bbx= (aa*aax+4*exp(2)*r*rx)/bb;
bby= (aa*aay+4*exp(2)*r*ry)/bb;

rr = 2*exp(1)*r/(bb+aa);
rrx= 2*exp(1)*rx/(bb+aa)-2*exp(1)*r*(bbx+aax)/(bb+aa)^2;
rry= 2*exp(1)*ry/(bb+aa)-2*exp(1)*r*(bby+aay)/(bb+aa)^2;

pphi = 2*pi*p(1)+log(rr/r)+phi;
pphix = (rrx*r-rr*rx+phix*r*rr)/(r*rr);
pphiy = (rry*r-rr*ry+phiy*r*rr)/(r*rr);

y1x = (1-p(2))*(rrx*sin(pphi)+rr*cos(pphi)*pphix);
y1y = (1-p(2))*(rry*sin(pphi)+rr*cos(pphi)*pphiy);

y2x = (1-p(2))*(rrx*cos(pphi)-rr*sin(pphi)*pphix);
y2y = (1-p(2))*(rry*cos(pphi)-rr*sin(pphi)*pphiy);

J = [y1x y1y; y2x y2y];