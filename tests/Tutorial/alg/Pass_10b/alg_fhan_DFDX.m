function Jx = alg_fhan_DFDX(data, x, p)

if isempty(data.dfdxhan)
  Jx = coco_ezDFDX('f(x,p)', data.fhan, x, p);
else
  Jx = data.dfdxhan(x, p);
end

end