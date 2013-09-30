function [ hh ] = coll_plot(run, prefix, labs, coords, varargin)

holdstat = ishold;

if ~holdstat
	cla;
	hold on
end

fid = coco_get_id(prefix, 'coll');
bd  = coco_bd_read(run);

if ischar(labs)
  labs = coco_bd_labs(bd, labs);
else
  labs = labs(:)';
end

hh = [];
for lab = labs
  h    = [];
  data = coco_read_solution(fid, run, lab);
  segs = data.sol.seglist;
  T = segs(end).t0(end);
  for i=1:numel(segs)
    x  = [segs(i).t0/T ; segs(i).t0 ; segs(i).x0];
    x  = x(coords+2,:);
    switch numel(coords)
      case 2
        hp = plot(...
          x(1,1), x(2,1), 'bo', ...
          x(1,end), x(2,end), 'bo', ...
          x(1,:), x(2,:), varargin{:});
        h  = [h ; hp]; %#ok<AGROW>
      case 3
        hp = plot3(...
          x(1,1), x(2,1), x(3,1), 'bo', ...
          x(1,end), x(2,end), x(3,end), 'bo', ...
          x(1,:), x(2,:), x(3,:), varargin{:});
        h  = [h ; hp]; %#ok<AGROW>
      otherwise
        error('%s: argument ''coords'' must contain two or three integers', ...
          mfilename);
    end
    drawnow
  end
  hh = [hh h]; %#ok<AGROW>
end

if ~holdstat
	hold off
end

if nargout<1
  clear hh
end
