function [data y] = ev_phase(opts, data, x, p) %#ok<INUSD,INUSL>
% p = [ m ; Ff ; k ; om ; a ; b ; e ]

y = 2*pi - x(3,:);
