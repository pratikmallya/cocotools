function animate(run, varargin)
d = fileparts(mfilename('fullpath'));
curr_dir = cd(d);
i = 1;
if exist('cache.mat', 'file')
  load('cache');
else
  addpath('../Pass_6');
  bd = coco_bd_read(run);
  for lab=coco_bd_labs(bd)
    sols{i} = coll_read_solution('', run, lab); %#ok<AGROW>
    i = i+1;
  end
  rmpath('../Pass_6');
  save('cache', 'sols');
end
cd(curr_dir);
i=1;
inc = 1;
k=0;
while k<=1
  clf
  plot(sols{i}.x(:,1), sols{i}.x(:,2), varargin{:})
  axis([-3.5 3.5 -1 1]);
  axis equal
  grid on
  drawnow
  i = i+inc;
  if i>numel(sols)
    inc = -1;
    i = numel(sols);
  elseif i<1
    inc = 1;
    i = 1;
    k=k+1;
  end
  pause(0.1)
end
end
