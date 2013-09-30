function plot_crv(bd2s1, bd2s2)

% plot k-b-om
% axis([2.5 6.5 0.5 0.9 0.93 1.1]);

for bds = bd2s1
  bds = bds{1}; %#ok<FXSET>
  css = [ bds{2:end,9} ]; % om b k
  k  = css(3,:);
  b  = css(2,:);
  om = css(1,:);
  plot3(k, b, om, 'k-', 'LineWidth', 0.5);
end

for bds = bd2s2
  bds = bds{1}; %#ok<FXSET>
  css = [ bds{2:end,9} ]; % om k b
  k  = css(2,:);
  b  = css(3,:);
  om = css(1,:);
  plot3(k, b, om, 'k-', 'LineWidth', 0.5);
end
