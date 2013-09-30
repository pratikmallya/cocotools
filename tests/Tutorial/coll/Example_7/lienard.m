function y = lienard(xx, pp, ~)

p1 = pp(1,:);

x1 = xx(1,:);
x2 = xx(2,:);

y(1,:) = x2;
y(2,:) = -x2.^3+p1.*x2-x1;

end