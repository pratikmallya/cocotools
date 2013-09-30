function prob = period(u0, n)

prob = coco_prob();
prob = coco_add_func(prob, 'henon_1', @henon, [], 'zero', ...
  'u0', u0(1:6));
for i=2:n-1
  prob = coco_add_func(prob, sprintf('henon_%d', i), @henon, [], ...
    'zero', 'uidx', [1; 2; 2*i+1; 2*i+2], 'u0', u0(2*i+3:2*i+4));
end
prob = coco_add_func(prob, sprintf('henon_%d', n), @henon, [], ...
  'zero', 'uidx', [1; 2; 2*n+1; 2*n+2; 3; 4]);

end