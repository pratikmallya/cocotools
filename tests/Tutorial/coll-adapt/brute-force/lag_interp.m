function y = lag_interp(c,t,x)
n = numel(t);
mask = [false true(1,n-1)];
y = zeros(size(x));
for i=1:n
  t0 = t(i);
  c0 = c(i);
  tk = t(mask);
  f  = @(tt) c0*ttprod(tt,tk)/prod(t0-tk);
  y = y + f(x);
  mask = circshift(mask,[0 1]);
end

end

function y = ttprod(tt,tk)
y = ones(size(tt));
for i=1:numel(tk)
  y = y.*(tt-tk(i));
end
end
