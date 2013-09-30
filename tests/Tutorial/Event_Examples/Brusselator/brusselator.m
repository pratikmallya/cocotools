function f = brusselator(x, y, z, p)

r = p(:,4) ./ sqrt(p(:,5));
A = p(:,3) ./ (1 + exp(r)) .* ...
    (exp(r .* z) + exp(r .* (1 - z)));

f = [-p(:,4).^2./p(:,1).*((p(:,6) + 1).*x - x.^2.*y - A) ...
    -p(:,4).^2./p(:,2).*(x.^2.*y - p(:,6).*x)];

end