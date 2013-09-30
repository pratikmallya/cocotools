function [data y] = empty(prob, data, u)
y = sum(u(:).^2)+1;
end