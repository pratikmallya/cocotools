function [h, term, dir] = event(x, p, s)
% event functions

switch s
    case 1
        h = [p(6)-x(1); x(2)];
        term = [1; 0];
        dir = [-1; -1];
    case 2
        h = 2*pi-x(3);
        term = 1;
        dir = -1;
    case 3
        h = x(2);
        term = 1;
        dir = -1;
    case 'all'
        h = [p(6)-x(1); 2*pi-x(3); x(2)];
        term = [1; 1; 1];
        dir = [-1; -1; -1];
end     
end