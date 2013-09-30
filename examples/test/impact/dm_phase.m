function [data y] = dm_phase(opts, data, x, p) %#ok<INUSD,INUSL>
% p = [ m ; Ff ; k ; om ; a ; b ; e ]

y = zeros(size(x));

y(1,:) = x(1,:);
y(2,:) = x(2,:);
