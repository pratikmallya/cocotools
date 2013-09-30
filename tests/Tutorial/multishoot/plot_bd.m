function plot_bd(bd, p_idx, x_idx)

if nargin<2
  p_idx = 1;
end
if nargin<3
  x_idx = 1;
end

was_hold = ishold;

% plot bifurcation diagram
x = coco_bd_col(bd, 'x');
p = coco_bd_col(bd, 'p');

plot(p(p_idx,:),x(x_idx,:),'-', 'LineWidth', 2)

if ~was_hold
  hold on
end

% plot end points
labs = coco_bd_labs(bd, 'EP');
for lab=labs
  x = coco_bd_val(bd, lab, 'x');
  p = coco_bd_val(bd, lab, 'p');
  plot(p(p_idx,:),x(x_idx,:),'go', 'MarkerSize', 4, 'LineWidth', 2)
end

% plot limit points
labs = coco_bd_labs(bd, 'LP');
for lab=labs
  x = coco_bd_val(bd, lab, 'x');
  p = coco_bd_val(bd, lab, 'p');
  plot(p(p_idx,:),x(x_idx,:),'ro', 'MarkerSize', 4, 'LineWidth', 2)
end

% plot branch points
labs = coco_bd_labs(bd, 'BP');
for lab=labs
  x = coco_bd_val(bd, lab, 'x');
  p = coco_bd_val(bd, lab, 'p');
  plot(p(p_idx,:),x(x_idx,:),'ko', 'MarkerSize', 4, 'LineWidth', 2)
end

% plot period-doubling points
labs = coco_bd_labs(bd, 'PD');
for lab=labs
  x = coco_bd_val(bd, lab, 'x');
  p = coco_bd_val(bd, lab, 'p');
  plot(p(p_idx,:),x(x_idx,:),'mo', 'MarkerSize', 4, 'LineWidth', 2)
end

% plot user-defined points
labs = coco_bd_labs(bd, 'GZ');
for lab=labs
  x = coco_bd_val(bd, lab, 'x');
  p = coco_bd_val(bd, lab, 'p');
  plot(p(p_idx,:),x(x_idx,:),'bo', 'MarkerSize', 4, 'LineWidth', 2)
end

if ~was_hold
  hold off
end
drawnow

end
