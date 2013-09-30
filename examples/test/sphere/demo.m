clf
%view([-25 50]);
%view([55 -10]);
%view([0 0])
grid on
drawnow

% par = [ x ; y ; a ; b ]
a  = 1;
b  = 5;
p0 = [ 0.5 ; 0.5/a ; a ; b ];
z0 = 0.5/b;
axis([0.4 sqrt(1-0.16) 0.4 sqrt(1-0.16) -1/b 1/b]); view([135 0])

fprintf('\n********************\n\n');

% rmdir('data', 's');

opts = [];

% opts = coco_set(opts, 'cont', 'atlas' , @cover1d); %bug: update
% opts = coco_set(opts, 'cont'    , 'ItMX'    , 30);
opts = coco_set(opts, 'cont', 'atlas' , @coverkd); %bug: update
opts = coco_set(opts, 'cont'    , 'ItMX'    , 5000);

opts = coco_set(opts, 'cont'    , 'NPR'     , 10 );
opts = coco_set(opts, 'cont'    , 'NSV'     , 100);
opts = coco_set(opts, 'cont'    , 'LogLevel', 4);

opts = coco_set(opts, 'cont'    , 'al_max'   , 10     );
opts = coco_set(opts, 'cont'    , 'h0'       , 0.25/b );
opts = coco_set(opts, 'cont'    , 'h_max'    , 0.50/b );
opts = coco_set(opts, 'cont'    , 'h_min'    , 0.02/b );
opts = coco_set(opts, 'cont'    , 'h_fac_max', 2.0    );

opts = coco_set(opts, 'cont'    , 'MaxRes'   , 0.1/b  );

data.lt = 'b*';
data.mode = 1;
opts = coco_add_slot(opts, 'plot_chart', @plot_chart, data, ...
  'fsm_bcb_update');
data.lt = 'r+';
data.mode = 2;
opts = coco_add_slot(opts, 'plot_chart', @plot_chart, data, ...
  'fsm_ecb_predict');

% opts = coco_add_func(opts, 'user:plane', 'alcont', @plane, [], ...
%   'internal', {'H' 'Z'}, 'vectorised', 'on');
% 
% opts = coco_add_event(opts, 'UZ', 'SP', 'H',  0);
opts = coco_set(opts, 'all', 'CleanData', 1);

[bd atlas] = coco(opts, 'x', 'alcont', 'isol', 'sol', ...
  @sphere, z0, p0, ...
  2, {'PAR(1)' 'PAR(2)'}, {[0.4 2] [0.4 2]});

if isempty(atlas)
  return;
end

z = [bd{2:end,10}];
p = [bd{2:end,11}];
x = p(1,:);
y = p(2,:);

clf
[Tri X] = coverkd_triangulate(atlas);
trimesh(Tri, X(:,2), X(:,3), X(:,1));hold on

hold on
idx = strcmp('EP', bd(2:end,4));
plot3(x(idx), y(idx), z(idx), 'r*');
idx = strcmp('UZ', bd(2:end,4));
plot3(x(idx), y(idx), z(idx), 'y*');
idx = strcmp('RO', bd(2:end,4)) | cellfun('isempty', bd(2:end,4)) ;
plot3(x(idx), y(idx), z(idx), 'b*');
hold off
drawnow

% coverkd_plotCovering(atlas, 2,3,1);
