function coco_open_recipes_file(varargin)
%Open Recipes' tutorial file(s).
p = fileparts(mfilename('fullpath'));
p = fullfile(p, '..', '..', 'examples', 'tutorial', 'Recipes');
for i=1:nargin
  p = fullfile(p, varargin{:});
  edit(p);
end
end
