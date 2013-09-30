function [data y] = ev_stickp(opts, data, x, p) %#ok<INUSD,INUSL>
% p = [ m ; Ff ; k ; om ; a ; b ; e ]

y = x(2,:);
