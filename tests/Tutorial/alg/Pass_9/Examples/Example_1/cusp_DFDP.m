function J = cusp_DFDP(x, p)

x = x(1,:);

J = zeros(1,2,numel(x));
J(1,1,:) = 1;
J(1,2,:) = -x;

end