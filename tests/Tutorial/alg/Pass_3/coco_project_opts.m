function prob = coco_project_opts(prob)
prob = coco_set(prob, 'cont', 'linsolve', 'recipes');
prob = coco_set(prob, 'cont', 'corrector', 'recipes');
prob = coco_set(prob, 'cont', 'atlas_classes', ...
  { [] 'atlas_kd' ; 0 'atlas_0d_recipes' ; 1 'atlas_1d_recipes' });
end