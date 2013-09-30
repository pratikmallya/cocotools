function J = linearode_DFDX(xx, pp, ~)

p1 = pp(1,:);

x1 = xx(1,:);
x2 = xx(2,:);
x3 = xx(3,:);

J        = zeros(3,3,numel(x1));
J(1,2,:) = ones(numel(x1),1);
J(2,1,:) = -p1;
J(2,2,:) = -ones(numel(x1),1);
J(2,3,:) = -sin(x3);

end