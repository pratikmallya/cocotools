function [y]=vibcon(xx,pp)
% p = [eps ka2 be V ga Q M eta ka1]

eps = pp(1,:);
ka2 = pp(2,:);
be  = pp(3,:);
V   = pp(4,:);
ga  = pp(5,:);
Q   = pp(6,:);
M   = pp(7,:);
eta = pp(8,:);
ka1 = pp(9,:);

x1  = xx(1,:);
x1d = xx(2,:);
x2  = xx(3,:);
x2d = xx(4,:);
set = xx(5,:);
cet = xx(6,:);

T1 = ka1.*(x1d-x2d);
T2 = Q.*Q.*(1+eps.*cet).*(x1-x2);
T3 = T1+T2;
T4 = ka2.*x2d+x2-be.*V.*V.*(1-ga.*x2d.*x2d).*x2;

y(1,:) =  x1d;
y(2,:) = -T3;
y(3,:) =  x2d;
y(4,:) =  M.*T3-T4;

% Harmonic oscillator
ss     = set.*set+cet.*cet;
y(5,:) =       set + eta.*cet - set.*ss;
y(6,:) = -eta.*set +      cet - cet.*ss;
