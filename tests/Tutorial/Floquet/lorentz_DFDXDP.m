function J = lorentz_DFDXDP(xx, pp, ~)

s = pp(1,:);

J = zeros(3,3,numel(s),3);
J(1,1,:,1) = -ones(numel(s),1);
J(1,2,:,1) = ones(numel(s),1);
J(2,1,:,2) = ones(numel(s),1);
J(3,3,:,3) = -ones(numel(s),1);

end