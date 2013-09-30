function prob = riess_start_2(prob, run)

bd   = coco_bd_read(run);
labs = coco_bd_labs(bd, 'ALL');
endpoints = [];
labels = [];
for lab=labs
  sol       = coll_read_solution('col2', run, lab);
  endpoints = [endpoints; sol.x(1,:)];
  labels    = [labels; lab];
end
sol     = coll_read_solution('col1', run, 1);
pt      = repmat(sol.x(end,:), [size(endpoints, 1) 1]);
[m1 i1] = min(sqrt(sum((endpoints-pt).*(endpoints-pt), 2)));

prob = riess_restart_1(prob, run, labels(i1));

vgap        = endpoints(i1,:)-pt(i1,:);
data.gapvec = vgap/norm(vgap);
vphase      = endpoints(i1+1,:)-endpoints(i1-1,:);
data.vphase = vphase/norm(vphase);

prob = riess_close_het_2(prob, data);

end