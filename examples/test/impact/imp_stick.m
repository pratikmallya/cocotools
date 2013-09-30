function [y]=imp_stick(x,p)
% p = [ m ; Ff ; k ; om ; a ; b ; e ]

om = p(4,:);

y  = zeros(size(x));

y(3,:) = om;
