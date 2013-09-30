function J = lang_DFDX(x, p)

x1 = x(1,:);
x2 = x(2,:);
x3 = x(3,:);

om  = p(1,:);
ro  = p(2,:);
eps = p(3,:);

J = zeros(3,3,size(x,2));
J(1,1,:) = (x3-0.7);
J(1,2,:) = -om;
J(1,3,:) = x1;
J(2,1,:) = om;
J(2,2,:) = (x3-0.7);
J(2,3,:) = x2;
J(3,1,:) = -2*x1.*(1+ro.*x3)+3*eps.*x3.*x1.^2;
J(3,2,:) = -2*x2.*(1+ro.*x3);
J(3,3,:) = 1-x3.^2-ro.*(x1.^2+x2.^2)+eps.*x1.^3;

end
