function J = linearode_DFDXDX(xx, pp, ~)

x3 = xx(3,:);

J = zeros(3,3,3,numel(x3));
J(2,3,3,:) = -cos(x3);

end