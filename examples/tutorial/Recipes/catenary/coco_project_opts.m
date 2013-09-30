function opts = coco_project_opts(opts)
% Define toolboxes for Recipes for Continuation.
opts = coco_set(opts, 'cont', 'linsolve', 'recipes');
opts = coco_set(opts, 'cont', 'corrector', 'recipes');
opts = coco_set(opts, 'cont', 'atlas_classes', ...
  { [] 'atlas_kd' ; 0 'atlas_0d_recipes' ; 1 'atlas_1d_recipes' });
end
