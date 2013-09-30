function y = catenary(x, p, model)

x1 = x(1,:);
x2 = x(2,:);

y(1,:) = x2;
y(2,:) = (1+x2.^2)./x1;

end