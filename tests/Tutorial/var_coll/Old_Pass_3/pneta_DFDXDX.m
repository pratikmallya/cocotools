function J = pneta_DFDXDX(x, p, ~)

p1 = p(1,:);
x2 = x(2,:);

J          = zeros(2,2,2,numel(x2));
J(2,2,2,:) = -6*p1.*x2;

end