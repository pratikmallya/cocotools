function J = linearode_DFDP(xx, pp, ~)

x1 = xx(1,:);

J        = zeros(3, 1, numel(x1));
J(2,1,:) = -x1;
end