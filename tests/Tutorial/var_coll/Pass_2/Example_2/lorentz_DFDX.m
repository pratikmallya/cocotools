function J = lorentz_DFDX(x, p)

x1 = x(1,:);
x2 = x(2,:);
x3 = x(3,:);
s  = p(1,:);
r  = p(2,:);
b  = p(3,:);

J = zeros(3,3,numel(s));
J(1,1,:) = -s;
J(1,2,:) = s;
J(2,1,:) = r-x3;
J(2,2,:) = -1;
J(2,3,:) = -x1;
J(3,1,:) = x2;
J(3,2,:) = x1;
J(3,3,:) = -b;

end