function J = linode_DFDXDX(x, p, mode)

x3 = x(3,:);

J = zeros(3,3,3,numel(x3));
J(2,3,3,:) = -cos(x3);

end