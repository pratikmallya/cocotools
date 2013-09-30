function [data y] = lingap(prob, data, xp)
  y = data.gapvec*(xp(1:3)-xp(4:6));
end