clear p
p = coco_opts_tree;
p = p.prop_set('compalg.alg', 'A', struct('a', 1, 'b', 2));
p = p.prop_set('compalg.alg', 'norm', true);
p = p.prop_set('compalg.eq1.alg', 'norm', false);
p = p.prop_set('compalg.eq1.alg', 'A', struct('a', 4, 'c', 3));
p.print_tree(true);

fprintf('%s = %d\n', 'compalg.alg.norm', p.prop_get('compalg.eq1.alg', 'norm'));
fprintf('%s = %d\n', 'compalg.eq1.alg.norm', p.prop_get('compalg.eq1.alg', 'norm'));
fprintf('%s = %d\n', 'compalg.eq2.alg.norm', p.prop_get('compalg.eq2.alg', 'norm'));
