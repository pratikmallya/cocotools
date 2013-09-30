function [data y] = ev_turning(opts, data, x, p) %#ok<INUSL>
% p = [ m ; Ff ; k ; om ; a ; b ; e ]

a  = p(5,:);
om = p(4,:);

qcp = a .* cos( x(3,:) );

y = -(x(2,:) - om .* qcp);
