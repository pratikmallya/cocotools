function J = chemosz_DFDP(xx, pp, mode)

x1 = xx(1,:);
x2 = xx(2,:);
x3 = xx(3,:);
x4 = xx(4,:);

J = zeros(4,9,numel(x1));
J(1,1,:) = -x1.*x2.*x3;
J(1,3,:) = -x1.*x2.*x4;
J(1,7,:) = ones(numel(x1),1);
J(1,9,:) = -x1;
J(2,1,:) = -x1.*x2.*x3;
J(2,3,:) = -x1.*x2.*x4;
J(2,8,:) = ones(numel(x1),1);
J(3,1,:) = x1.*x2.*x3;
J(3,2,:) = -2*x3.*x3;
J(3,3,:) = 2*x1.*x2.*x4;
J(3,4,:) = -x3;
J(3,6,:) = ones(numel(x1),1);
J(4,2,:) = 2*x3.*x3;
J(4,3,:) = -x1.*x2.*x4;
J(4,5,:) = -x4;
end