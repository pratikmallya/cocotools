function J = pneta_DFDX(x, p, ~)

p1 = p(1,:);
x2 = x(2,:);

m        = numel(x2);
J        = zeros(2,2,m);
J(1,2,:) = ones(m,1);
J(2,1,:) = -ones(m,1);
J(2,2,:) = 0.5*p1-3*p1.*x2.^2;

end