function [y]=imp_pslip(x,p)
% p = [ m ; Ff ; k ; om ; a ; b ; e ]

m  = p(1,:);
Ff = p(2,:);
k  = p(3,:);
om = p(4,:);

y(1,:) = x(2,:);
y(2,:) = (-Ff - k .* x(1,:)) ./ m;
y(3,:) = om;
