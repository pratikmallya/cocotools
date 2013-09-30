function [data y] = huxley_bcs(prob, data, u)

m   = size(u(1,:),2);
x10 = u(1:2,:);
x20 = u(3:4,:);
par = u(5:6,:);
eps = u(7:8,:);

vu = [sqrt(4*par(1,:)+par(2,:).^2)-par(2,:); 2*par(1,:)];
vu = vu/norm(vu,2);
vs = [-sqrt(4*(1-par(1,:))+par(2,:).^2)-par(2,:); 2*(1-par(1,:))];
vs = vs/norm(vs,2);

y = [x10-eps(1,:).*vu; x20-([ones(1,m); zeros(1,m)]+eps(2,:)*vs)];

end