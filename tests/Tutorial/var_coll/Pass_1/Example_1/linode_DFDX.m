function J = linode_DFDX(x, p)

x1 = x(1,:);
x3 = x(3,:);
p1 = p(1,:);

J = zeros(3,3,numel(x1));
J(1,2,:) = 1;
J(2,1,:) = -p1;
J(2,2,:) = -1;
J(2,3,:) = -sin(x3);

end