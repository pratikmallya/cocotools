function Jp = alg_fhan_DFDP(data, x, p)

if isempty(data.dfdphan)
  Jp = coco_ezDFDP('f(x,p)', data.fhan, x, p);
else
  Jp = data.dfdphan(x, p);
end

end