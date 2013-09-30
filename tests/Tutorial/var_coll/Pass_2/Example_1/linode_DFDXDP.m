function J = linode_DFDXDP(x, p)

p1 = p(1,:);

J = zeros(3,3,1,numel(p1));
J(2,1,1,:) = -1;

end