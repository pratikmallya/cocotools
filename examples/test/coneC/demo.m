clf
axis([-2 2 -2 2 0 2])
%view([150 30]);
view(2)
grid on
drawnow
%plotCone

% par = [ x ; y ; alpha ]

fprintf('********************\n\n');

% rmdir('data', 's');

opts = [];

opts = coco_set(opts, 'cont', 'atlas' , @coverkd); % bug: update
opts = coco_set(opts, 'cont'    , 'ItMX'    , 2000);
opts = coco_set(opts, 'cont'    , 'NPR'     , 100);
opts = coco_set(opts, 'cont'    , 'al_max'  , 15   );
opts = coco_set(opts, 'cont'    , 'MaxRes'  , 0.5  );
opts = coco_set(opts, 'cont'    , 'h0'      , 0.2);
opts = coco_set(opts, 'cont'    , 'h_max'   , 0.5);
opts = coco_set(opts, 'cont'    , 'h_min'   , 0.01);
opts = coco_set(opts, 'cont'    , 'LogLevel', 4);

data.lt = 'b*';
data.mode = 1;
opts = coco_add_slot(opts, 'plot_chart', @plot_chart, data, ...
  'fsm_bcb_update');
data.lt = 'r+';
data.mode = 2;
opts = coco_add_slot(opts, 'plot_chart', @plot_chart, data, ...
  'fsm_ecb_predict');

opts = coco_add_func(opts, 'user:plane', 'alcont', @plane, [], ...
  'internal', {'H' 'Z'}, 'vectorised', 'on');

opts = coco_add_event(opts, 'UZ', 'SP', 'H',  0);
opts = coco_set(opts, 'all', 'CleanData', 1);

[bd atlas] = coco(opts, 'x', 'alcont', 'isol', 'sol', @cone, ...
	[0.8], [0;0.8;0], 2, {'PAR(1)' 'PAR(2)' 'Z'}, ...
    {[] [] [0.3, 1.5]}); %#ok<NBRAK>

z = coco_bd_col(bd, 'X');
p = coco_bd_col(bd, 'PARS');
x = p(1,:);
y = p(2,:);

clf
plotCone
hold on
idx = find(strcmp('EP', coco_bd_col(bd, 'TYPE') ));
plot3(x(idx), y(idx), z(idx), 'r*');
idx = find(strcmp('UZ', coco_bd_col(bd, 'TYPE') ));
plot3(x(idx), y(idx), z(idx), 'y*');
idx = strcmp('RO', coco_bd_col(bd, 'TYPE') );
idx = idx | cellfun('isempty', coco_bd_col(bd, 'TYPE') );
idx = find(idx);
plot3(x(idx), y(idx), z(idx), 'b*');
hold off
drawnow

% [Tri X] = coverkd_triangulate(atlas); trimesh(Tri, X(:,2), X(:,3), X(:,1));

% coverkd_plotCovering(atlas, 2,3,1);
