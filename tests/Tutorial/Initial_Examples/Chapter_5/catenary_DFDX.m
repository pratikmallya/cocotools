function J = catenary_DFDX(x)

x1 = x(1,:);
x2 = x(2,:);

J = zeros(2,2, numel(x1));
J(1,2,:) = 1;
J(2,1,:) = -(1+x2.^2)./x1.^2;
J(2,2,:) = -2*x2./x1;

end