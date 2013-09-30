function coco_use_recipes_toolbox( varargin )
%Add/remove Recipes' tutorial toolbox(es) to/from search path.

p   = fileparts(mfilename('fullpath'));
p   = fullfile(p, '..', '..', 'examples', 'tutorial', 'Recipes');
tbx = {};

for i = 1:nargin
  t = fullfile(p, varargin{i});
  assert(exist(t, 'dir')==7, 'toolbox ''%s'' not found', t);
  tbx = [ tbx t ]; %#ok<AGROW>
end

while exist('coco_rm_this_path', 'file')==2
  coco_rm_this_path;
end

if nargin>0
  addpath(tbx{:});
end

end
