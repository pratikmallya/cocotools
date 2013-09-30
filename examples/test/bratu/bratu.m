function [y]=bratu(x,p)
% p = [p1]

y(1,:) = x(2,:);
y(2,:) = -p(1,:) .* exp(x(1,:));
