function y = lienard(xx, pp)

x1 = xx(1,:);
x2 = xx(2,:);
p1 = pp(1,:);

y(1,:) = x2;
y(2,:) = -x2.^3+p1.*x2-x1;

end