s=10;
b=8/3;
r=470/19;
p0 = [s; r; b];
x0 = [-sqrt(b*(r-1)); -sqrt(b*(r-1)); r-1];
opts = po_Hopf2sol([], '', @lorentz, x0, p0);
bd1 = coco(opts, 'run1', [], 1, 'PAR(2)', [24.05 25]);

labs = coco_bd_labs(bd1, 'all');
cla;
grid on;
hold on;
for lab=labs
    [t x] = coll_read_sol('', 'run1', lab);
    plot3(x(1,:), x(2,:), x(3,:), 'b.-')
end
hold off