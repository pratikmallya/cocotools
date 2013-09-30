function J = lorentz_DFDXDX(x, p)

s = p(1,:);

J = zeros(3,3,3,numel(s));
J(2,3,1,:) = -1;
J(3,2,1,:) = 1;
J(3,1,2,:) = 1;
J(2,1,3,:) = -1;

end