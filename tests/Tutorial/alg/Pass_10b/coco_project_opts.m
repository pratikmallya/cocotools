function prob = coco_project_opts(prob)

prob = coco_set(prob, 'cont', 'linsolve', 'recipes');
prob = coco_set(prob, 'cont', 'corrector', 'recipes');
prob = coco_set(prob, 'cont', 'atlas', @atlas_2d_min.create);

end