function y = pneta(x, p, ~)

p1 = p(1,:);

x1 = x(1,:);
x2 = x(2,:);

y(1,:) = x2;
y(2,:) = (0.5*p1).*x2-p1.*x2.^3-x1;

end