function y = chemosz(xx, pp, mode)

p1 = pp(1,:);
p2 = pp(2,:);
p3 = pp(3,:);
p4 = pp(4,:);
p5 = pp(5,:);
p6 = pp(6,:);
p7 = pp(7,:);
p8 = pp(8,:);
p9 = pp(9,:);

x1 = xx(1,:);
x2 = xx(2,:);
x3 = xx(3,:);
x4 = xx(4,:);

T1 = p1.*x1.*x2.*x3;
T2 = p3.*x1.*x2.*x4;
T3 = 2*p2.*x3.*x3;

y(1,:) = -T1-T2+p7-p9.*x1;
y(2,:) = -T1-T2+p8;
y(3,:) =  T1-T3+2*T2-p4.*x3+p6;
y(4,:) = -T2+T3-p5.*x4;

end