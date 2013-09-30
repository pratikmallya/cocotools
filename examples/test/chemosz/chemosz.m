function [y]=chemosz(xx,pp)
% p = [k1 k2 k3 k4 k5 k6 k7 k8 k_7]

k1  = pp(1,:);
k2  = pp(2,:);
k3  = pp(3,:);
k4  = pp(4,:);
k5  = pp(5,:);
k6  = pp(6,:);
k7  = pp(7,:);
k8  = pp(8,:);
k_7 = pp(9,:);

A = xx(1,:);
B = xx(2,:);
X = xx(3,:);
Y = xx(4,:);

T1 = k1.*A.*B.*X;
T2 = k3.*A.*B.*Y;
T3 = 2*k2.*X.*X;

y(1,:) = -T1-T2+k7-k_7.*A;
y(2,:) = -T1-T2+k8;
y(3,:) =  T1-T3+2*T2-k4.*X+k6;
y(4,:) = -T2+T3-k5.*Y;
