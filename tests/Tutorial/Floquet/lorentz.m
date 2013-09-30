function y = lorentz(xx, pp, mode)

s = pp(1,:);
r = pp(2,:);
b = pp(3,:);

x1 = xx(1,:);
x2 = xx(2,:);
x3 = xx(3,:);

y(1,:) = -s.*x1+s.*x2;
y(2,:) = -x1.*x3+r.*x1-x2;
y(3,:) = x1.*x2-b.*x3;

if ~isempty(mode)
    y = -y;
end

end