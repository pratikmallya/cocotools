function J = linode_DFDX(x, p, mode)

p1 = p(1,:);

x1 = x(1,:);
x3 = x(3,:);

m        = numel(x1);
J        = zeros(3,3,m);
J(1,2,:) = ones(m,1);
J(2,1,:) = -p1;
J(2,2,:) = -ones(m,1);
J(2,3,:) = -sin(x3);

end