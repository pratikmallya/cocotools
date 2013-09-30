function plot_bd(bd, pidx, pw)

subplot(2,1,pw)

x = coco_bd_col(bd, 'X');
p = coco_bd_col(bd, 'PARS');
p = p(pidx,:);

plot(p, x, 'b-');
grid on

idx = find(strcmp('LP', coco_bd_col(bd, 'TYPE') ));
hold on
plot(p(idx), x(idx), 'ro', 'LineWidth', 2, 'MarkerSize', 6);
hold off

idx = find(strcmp('RN', coco_bd_col(bd, 'TYPE') ));
hold on
plot(p(idx), x(idx), 'ms', 'LineWidth', 2, 'MarkerSize', 6);
hold off

idx = find(strcmp('BP', coco_bd_col(bd, 'TYPE') ));
hold on
plot(p(idx), x(idx), 'kx', 'LineWidth', 2, 'MarkerSize', 6);
hold off

drawnow

end