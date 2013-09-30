function circ01
% set up basic continuation

opts = [];

% add continuation problem (zero problem)
opts = coco_add_func(opts, 'circle', @circle, [], 'zero', ...
  'x0', sqrt([0.5;0.5]) );

% define u(1)='x' and u(2)='y' as parameters
opts = coco_add_parameters(opts, '', [1 2], {'x' 'y'});

% run continuation, name branch '1'
bd = coco(opts, '1', [], {'x' 'y'}, [-2 2]);

% plot circle
u  = coco_bd_col(bd, {'x' 'y'});
plot(u(1,:), u(2,:))

end

function [data y] = circle(opts, data, u) %#ok<INUSL>
y = u(1)^2 + u(2)^2 - 1;
end
