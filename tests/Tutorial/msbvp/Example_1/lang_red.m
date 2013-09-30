function y = lang_red(x, p)

x1 = x(1,:);
x2 = x(2,:);
ro = p(2,:);

y(1,:) = (x2-0.7).*x1;
y(2,:) = 0.6+x2-x2.^3/3-x1.^2.*(1+ro.*x2);

end