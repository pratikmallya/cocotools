function [data y] = ev_percond(opts, data, x, p) %#ok<INUSD,INUSL>
% p = [ m ; Ff ; k ; om ; a ; b ; e ]

% bug: x0p and x0 are not yet accessible this way
xx  = data.coll.W * x;
y   = data.x0p * (xx - data.x0);
