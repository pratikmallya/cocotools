function [data y] = linphase(prob, data, xp)
  y = data.vphase*(xp(1:3)-xp(4:6));
end