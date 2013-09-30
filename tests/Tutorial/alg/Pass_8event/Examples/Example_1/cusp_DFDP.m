function J = cusp_DFDP(x, p)

x = x(1,:);
m = numel(x);

J = zeros(1,2,m);
J(1,1,:) = ones(1,m);
J(1,2,:) = -x;

end