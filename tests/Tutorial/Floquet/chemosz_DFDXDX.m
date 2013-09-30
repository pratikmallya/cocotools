function J = chemosz_DFDXDX(xx, pp, ~)

p1 = pp(1,:);
p2 = pp(2,:);
p3 = pp(3,:);

x1 = xx(1,:);
x2 = xx(2,:);
x3 = xx(3,:);
x4 = xx(4,:);

J = zeros(4,4,4,numel(p1));
J(1,2,1,:) = -p1.*x3-p3.*x4;
J(1,3,1,:) = -p1.*x2;
J(1,4,1,:) = -p3.*x2;
J(2,2,1,:) = -p1.*x3-p3.*x4;
J(2,3,1,:) = -p1.*x2;
J(2,4,1,:) = -p3.*x2;
J(3,2,1,:) = p1.*x3+2*p3.*x4;
J(3,3,1,:) = p1.*x2;
J(3,4,1,:) = 2*p3.*x2;
J(4,2,1,:) = -p3.*x4;
J(4,4,1,:) = -p3.*x2;
J(1,1,2,:) = -p1.*x3-p3.*x4;
J(1,3,2,:) = -p1.*x1;
J(1,4,2,:) = -p3.*x1;
J(2,1,2,:) = -p1.*x3-p3.*x4;
J(2,3,2,:) = -p1.*x1;
J(2,4,2,:) = -p3.*x1;
J(3,1,2,:) = p1.*x3+2*p3.*x4;
J(3,3,2,:) = p1.*x1;
J(3,4,2,:) = 2*p3.*x1;
J(4,1,2,:) = -p3.*x4;
J(4,4,2,:) = -p3.*x1;
J(1,1,3,:) = -p1.*x2;
J(1,2,3,:) = -p1.*x1;
J(2,1,3,:) = -p1.*x2;
J(2,2,3,:) = -p1.*x1;
J(3,1,3,:) = p1.*x2;
J(3,2,3,:) = p1.*x1;
J(3,3,3,:) = -4*p2;
J(4,3,3,:) = 4*p2;
J(1,1,4,:) = -p3.*x2;
J(1,2,4,:) = -p3.*x1;
J(2,1,4,:) = -p3.*x2;
J(2,2,4,:) = -p3.*x1;
J(3,1,4,:) = 2*p3.*x2;
J(3,2,4,:) = 2*p3.*x1;
J(4,1,4,:) = -p3.*x2;
J(4,2,4,:) = -p3.*x1;
end