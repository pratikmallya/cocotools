function [data y] = ellipse(prob, data, u)
y = (2*(u(1)-1))^2+u(2)^2-1;
end