function y = lag_base(i,t,x)
ti = t(i);
t(i) = [];
y = ones(size(x));
for i=1:numel(t)
  y = y.*(x-t(i))/(ti-t(i));
end
end
