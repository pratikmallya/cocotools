function data = tor_update(data, x, p, varargin)
data.x0 = circshift(x, [0 -1]);
data.f0 = circshift(tor(x, repmat(p, 1, size(x,2))), [0 -1])';
end
