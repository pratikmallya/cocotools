function y = linearode(xx, pp, ~)

p1 = pp(1,:);

x1 = xx(1,:);
x2 = xx(2,:);
x3 = xx(3,:);

y(1,:) = x2;
y(2,:) = -x2 - p1.*x1 + cos(x3);
y(3,:) =  1;

end