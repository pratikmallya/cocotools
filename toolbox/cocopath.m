function cp = cocopath(cocodir, ignore)

if nargin<1
  cocodir = mfilename('fullpath');
  cocodir = fileparts(cocodir);
end

if nargin<2
    % ignore = { 'covering' };
    ignore = { 'cover1d' 'cover_kd' 'coverkd' 'collocation'};
end

cp = coco_genpath(cocodir, ignore);

end

function p = coco_genpath(d, ignore)

p = { d };

files = dir(d);
if isempty(files)
  return
end

isdir = logical(cat(1,files.isdir));
dirs  = files(isdir);
prune = { '.' '@' '+' };

for i=1:length(dirs)
   dirname = dirs(i).name;
   if ~( any(strncmp(dirname, prune, 1)) || ...
           strcmp(dirname, 'private') || ...
           any(strcmp(dirname, ignore)) )
      p = [p coco_genpath(fullfile(d,dirname), ignore)]; %#ok<AGROW>
   end
end

end
