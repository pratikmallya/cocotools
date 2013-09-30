function y = pneta(x, p)

x1 = x(1,:);
x2 = x(2,:);
p  = p(1,:);

y = [x2; (0.5*p).*x2-p.*x2.^3-x1];

end