function J = linode_DFDXDP(x, p, mode)

p1 = p(1,:);
m          = numel(p1);
J          = zeros(3,3,m,1);
J(2,1,:,1) = -ones(m,1);

end