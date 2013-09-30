function J = lorentz_DFDX2(xx, pp, ~)

s = pp(1,:);
r = pp(2,:);
b = pp(3,:);

x1 = xx(1,:);
x2 = xx(2,:);
x3 = xx(3,:);

J = zeros(3,3,numel(s));
J(1,1,:) = -s;
J(1,2,:) = s;
J(2,1,:) = r-x3;
J(2,2,:) = -ones(numel(s),1);
J(2,3,:) = -x1;
J(3,1,:) = x2;
J(3,2,:) = x1;
J(3,3,:) = -b;

end