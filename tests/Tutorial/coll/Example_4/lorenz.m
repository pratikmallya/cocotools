function y = lorenz(x, p, mode)

y(1,:) = p(1,:).*(x(2,:)-x(1,:));
y(2,:) = p(2,:).*x(1,:)-x(2,:)-x(1,:).*x(3,:);
y(3,:) = x(1,:).*x(2,:)-p(3,:).*x(3,:);

if mode==2
    y=-y;
end

end
