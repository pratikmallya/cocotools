function J = lorentz_DFDP2(xx, pp, ~)

x1 = xx(1,:);
x2 = xx(2,:);
x3 = xx(3,:);

J = zeros(3,3,numel(x1));
J(1,1,:) = -x1+x2;
J(2,2,:) = x1;
J(3,3,:) = -x3;

end