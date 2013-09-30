function y = stickslip_events(x, p, model)

switch model
  case 'collision'
    y = 0.5-x(1,:);
  case 'phase'
    y = pi/2-x(3,:);
  case 'minsep'
    y = x(2,:);
  case 'rest'
    y = x(1,:);
end

end