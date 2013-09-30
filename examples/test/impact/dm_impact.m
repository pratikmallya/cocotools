function [data y] = dm_impact(opts, data, x, p) %#ok<INUSL>
% p = [ m ; Ff ; k ; om ; a ; b ; e ]

a  = p(5,:);
e  = p(7,:);
om = p(4,:);

qcp = a .* cos( x(3,:) );

y(1,:) = x(1,:);
y(2,:) = -e .* x(2,:) + (1+e) .* om .* qcp;
y(3,:) = x(3,:);
