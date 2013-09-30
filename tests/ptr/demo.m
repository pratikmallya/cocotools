function demo

fprintf('********************* running coco_func_data class test\n');
coco_func_data.pointers('query');

A = struct('A', 2, 'B', 2);
B = struct('A', 2, 'C', 2);
C = struct('B', 2, 'C', 2);

p1 = coco_func_data(A);
p2 = coco_func_data(B);
p3 = p1.protect;

p1.pr.D = 4;
p2.sh.D = 3;
p2.pr.B = 3;
p2.data.A = 2;

p1.data.C = 2;

printp(p1, p2, p3);

p1.p2 = p2;

p1 = coco_func_data();
p2 = coco_func_data();
p3 = coco_func_data();

p2.p3 = p3;
p1.p2 = p2;

p1.p2.pr.p3

coco_func_data.pointers('query');
coco_func_data.pointers('set', []);
coco_func_data.pointers('query');

end

function printp(varargin)
for k=1:numel(varargin)
  p = varargin{k};
  data = p.data;
  fnames = fieldnames(data);
  pname = inputname(k);
  fprintf('%s.data(', pname);
  for i=1:numel(fnames)
    d = data.(fnames{i});
    if isfloat(d)
      fprintf(' %s=%g', fnames{i}, d);
    else
      fprintf(' %s=%s', fnames{i}, class(d));
    end
  end
  fprintf(' ); ');
  data = p.pr;
  fnames = fieldnames(data);
  pname = inputname(k);
  fprintf('%s.pr(', pname);
  for i=1:numel(fnames)
    d = data.(fnames{i});
    if isfloat(d)
      fprintf(' %s=%g', fnames{i}, d);
    else
      fprintf(' %s=%s', fnames{i}, class(d));
    end
  end
  fprintf(' ); ');
  data = p.sh;
  fnames = fieldnames(data);
  pname = inputname(k);
  fprintf('%s.sh(', pname);
  for i=1:numel(fnames)
    fprintf(' %s=%d', fnames{i}, data.(fnames{i}));
  end
  fprintf(' )\n');
end
end
