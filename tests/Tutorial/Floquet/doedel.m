function y = doedel(x, p, mode)

y(1,:) = 1-x(1,:).^2;
y(2,:) = p(1,:).*x(1,:) + p(2,:).*x(2,:);

if mode==2
    y=-y;
end

end
