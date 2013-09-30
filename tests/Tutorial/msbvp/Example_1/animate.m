function animate(run, fac)

if nargin<2
  fac=0.75;
end

d = fileparts(mfilename('fullpath'));
curr_dir = cd(d);

k = 1;
if exist('cache.mat', 'file')
  load('cache');
else
  bd = coco_bd_read(run);
labs = coco_bd_labs(bd);
  addpath('..');
  addpath('../../coll/Pass_1')
  for lab = labs
    [sol data] = msbvp_read_solution('', run, lab);
    N  = data.nsegs;
    XX = zeros(size(sol{1}.x,1),N+1);
    YY = XX;
    ZZ = XX;
    for i=1:N+1
      n       = mod(i-1,N)+1;
      XX(:,i) = sol{n}.x(:,1);
      YY(:,i) = sol{n}.x(:,2);
      ZZ(:,i) = sol{n}.x(:,3);
    end
    sols{k} = struct('X', XX, 'Y', YY, 'Z', ZZ); %#ok<AGROW>
    k=k+1;
  end
  rmpath('../../coll/Pass_1')
  rmpath('..');
  save('cache', 'sols');
end
cd(curr_dir);
i = 1;
inc = 1;
M = ceil(fac*size(sols{i}.X,1));
k=0;
while k<=1
  clf
  hold on
  surf(sols{i}.X(1:M,:), sols{i}.Y(1:M,:), sols{i}.Z(1:M,:), ...
    'FaceColor', 0.9*[1 1 1], 'MeshStyle', 'column');
  plot3(sols{i}.X(1,:), sols{i}.Y(1,:), sols{i}.Z(1,:), 'k.-', 'LineWidth', 2);
  plot3(sols{i}.X(M,:), sols{i}.Y(M,:), sols{i}.Z(M,:), 'k.-', 'LineWidth', 2);
  hold off
  grid on
  axis([-1.5 1.5 -2 2 -0.5 2]);
  view([50 15]);
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
