function [data y] = ev_impact(opts, data, x, p) %#ok<INUSL>
% p = [ m ; Ff ; k ; om ; a ; b ; e ]

a  = p(5,:);
b  = p(6,:);

qc = -b + a .* sin( x(3,:) );

y = x(1,:) - qc;
