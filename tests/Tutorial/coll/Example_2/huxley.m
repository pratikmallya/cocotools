function y = huxley(x, p)

x1 = x(1,:);
x2 = x(2,:);
p1 = p(1,:);
p2 = p(2,:);

y(1,:) = x2;
y(2,:) = p2.*x2-x1.*(1-x1).*(x1-p1);

end