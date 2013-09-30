function animate(run,bd)
addpath('..');
for lab=coco_bd_labs(bd)
  [t,x] = coll_read_sol('', run, lab); %#ok<ASGLU>
  clf
  % plot(t, x(2,:), 'b.-')
  plot(x(1,:), x(2,:), 'b.-')
  axis([-2.5 2.5 -1 1]);
  axis equal
  grid on
  drawnow
  pause(0.1)
end
end
