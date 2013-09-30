function J = lorentz_DFDXDX(xx, pp, ~)

s = pp(1,:);

J = zeros(3,3,3,numel(s));
J(2,3,1,:) = -ones(numel(s),1);
J(3,2,1,:) = ones(numel(s),1);
J(3,1,2,:) = ones(numel(s),1);
J(2,1,3,:) = -ones(numel(s),1);

end