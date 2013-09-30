function hx = event_dx(x, p, s)
% event functions

hx = zeros(1,3);
switch s
    case 1
        hx(1) = -1;
    case 2
        hx(3) = -1;
    case 3
        hx(2) = 1;
end     
end