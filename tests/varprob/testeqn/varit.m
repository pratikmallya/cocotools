function y = varit(x, la, si)

ala = conj(la)+la;
if abs(ala)<1.0e-8
  ela = 1;
else
  ela = (exp(ala)-1)/ala;
end
y   = 3/(1+exp(la)+si*conj(x)*ela);

end
