function demo(choice)
% Run basic continuation problems with minimal covering codes.

% atlas_0d = '0d_min';
% atlas_0d = '0d_recipes';
atlas_0d = '0d';

% atlas_1d = '1d_min';
% atlas_1d = '1d_recipes';
% atlas_1d = '1ds';
atlas_1d = '1d';
% atlas_1d = @atlas1.create;

if nargin>=1
  func = str2func(choice);
  fprintf('\n************\nrunning demo %s\n', choice);
  tm = tic;
  bd = func(atlas_0d, atlas_1d); %#ok<NASGU>
  toc(tm);
else
  demos = {'run_0D_min_regular' 'run_0D_min_empty' 'run_0D_min_singular' ...
    'run_0D_min_ev_BP0' 'run_0D_min_ev_BP1' 'run_0D_min_ev_BP2' ...
    'run_1D_min_regular' 'run_1D_min_empty' 'run_1D_min_singular' ...
    'run_1D_min_regular_MX' 'run_1D_min_ev_BP0' 'run_1D_min_ev_BP1' ...
    'run_1D_min_ev_BP2'};
  for i=1:numel(demos)
    demo(demos{i});
    drawnow;
    pause(0.5);
  end
end
end

function bd = run_0D_min_regular(atlas_0d, atlas_1d) %#ok<INUSD>
% cover_0d regular problem
opts = [];
opts = coco_set(opts, 'cont', 'atlas', atlas_0d);
% opts = coco_set(opts, 'cont', 'corrector', 'broyden');

opts = coco_add_func(opts, 'circle', @circle, [], 'zero', ...
  'x0', [1;0]+sqrt([0.5;0.55]) );

opts = coco_add_pars(opts, '', [1 2], {'x' 'y'});

bd = coco(opts, '1', [], 0, {'x' 'y'}, {[1 2], [0 1]});

u  = coco_bd_col(bd, {'x' 'y'});
plot(u(1,:), u(2,:), 'b.-')
axis equal
end

function bd = run_0D_min_empty(atlas_0d, atlas_1d) %#ok<INUSD>
% cover_0d empty problem
opts = [];
opts = coco_set(opts, 'cont', 'atlas', atlas_0d);

opts = coco_add_func(opts, 'circle', @empty, [], 'zero', ...
  'x0', [1;0]+sqrt([0.5;0.55]) );

opts = coco_add_pars(opts, '', [1 2], {'x' 'y'});

bd = coco(opts, '1', [], 0, {'x' 'y'}, {[], [0 1]});
end

function bd = run_0D_min_singular(atlas_0d, atlas_1d) %#ok<INUSD>
% cover_0d singular problem
opts = [];
opts = coco_set(opts, 'cont', 'atlas', atlas_0d);

opts = coco_add_func(opts, 'circle', @singular, [], 'zero', ...
  'x0', [1;0]+sqrt([0.5;0.55]) );

opts = coco_add_pars(opts, '', [1 2], {'x' 'y'});

bd = coco(opts, '1', [], 0, {'x' 'y'}, {[], [0 1]});
end

function bd = run_0D_min_ev_BP0(atlas_0d, atlas_1d) %#ok<INUSD>
% cover_0d_ev, initial point inside computational domain
opts = [];
opts = coco_set(opts, 'cont', 'atlas', atlas_0d);

opts = coco_add_func(opts, 'circle', @circle, [], 'zero', ...
  'x0', [1;0]+sqrt([0.55;0.5]) );

opts = coco_add_pars(opts, '', [1 2], {'x' 'y'});

bd = coco(opts, '1', [], 0, {'x' 'y'}, {[], [0 1]});

u  = coco_bd_col(bd, {'x' 'y'});
plot(u(1,:), u(2,:), 'b.-')
axis equal
end

function bd = run_0D_min_ev_BP1(atlas_0d, atlas_1d) %#ok<INUSD>
% cover_0d_ev, initial point on boundary of computational domain
opts = [];
opts = coco_set(opts, 'cont', 'atlas', atlas_0d);
opts = coco_set(opts, 'cont', 'LogLevel', 2);

opts = coco_add_func(opts, 'circle', @circle, [], 'zero', ...
  'x0', [1;0]+sqrt([0.55;0.5]) );

opts = coco_add_pars(opts, '', [1 2], {'x' 'y'});

bd = coco(opts, '1', [], 0, {'x' 'y'}, {[], [0 sqrt(0.5)]});

u  = coco_bd_col(bd, {'x' 'y'});
plot(u(1,:), u(2,:), 'b.-')
axis equal
end

function bd = run_0D_min_ev_BP2(atlas_0d, atlas_1d) %#ok<INUSD>
% cover_0d_ev, initial point outside computational domain
opts = [];
opts = coco_set(opts, 'cont', 'atlas', atlas_0d);
opts = coco_set(opts, 'cont', 'LogLevel', 2);

opts = coco_add_func(opts, 'circle', @circle, [], 'zero', ...
  'x0', [1;0]+sqrt([0.55;0.5]) );

opts = coco_add_pars(opts, '', [1 2], {'x' 'y'});

bd = coco(opts, '1', [], 0, {'x' 'y'}, {[], [0 0.1]});

u  = coco_bd_col(bd, {'x' 'y'});
plot(u(1,:), u(2,:), 'b.-')
axis equal
end

function bd = run_1D_min_regular(atlas_0d, atlas_1d) %#ok<INUSL>
% cover_1d regular problem
opts = [];
opts = coco_set(opts, 'cont', 'atlas', atlas_1d);
opts = coco_set(opts, 'cont', 'FP', true);
opts = coco_set(opts, 'cont', 'BP', true);

opts = coco_set(opts, 'cont', 'ItMX', 20);
% opts = coco_set(opts, 'cont', 'NPR', 1);

opts = coco_add_func(opts, 'circle', @circle, [], 'zero', ...
  'x0', [1;0]+sqrt([0.5;0.55]) );

opts = coco_add_pars(opts, '', [1 2], {'x' 'y'});

bd = coco(opts, '1', [], 1, {'x' 'y' 'atlas_FP' 'atlas_BP'}, {[], [-1 1]});

u  = coco_bd_col(bd, {'x' 'y'});
plot(u(1,:), u(2,:), 'b.-')
axis equal
end

function bd = run_1D_min_empty(atlas_0d, atlas_1d) %#ok<INUSL>
% cover_1d empty problem
opts = [];
opts = coco_set(opts, 'cont', 'atlas', atlas_1d);
opts = coco_set(opts, 'cont', 'ItMX', 20);

opts = coco_add_func(opts, 'circle', @empty, [], 'zero', ...
  'x0', [1;0]+sqrt([0.5;0.55]) );

opts = coco_add_pars(opts, '', [1 2], {'x' 'y'});

bd = coco(opts, '1', [], 1, {'x' 'y'}, {[], [-1 1]});
end

function bd = run_1D_min_singular(atlas_0d, atlas_1d) %#ok<INUSL>
% cover_1d singular problem
opts = [];
opts = coco_set(opts, 'cont', 'atlas', atlas_1d);
opts = coco_set(opts, 'cont', 'ItMX', 20);

opts = coco_add_func(opts, 'circle', @singular, [], 'zero', ...
  'x0', [1;0]+sqrt([0.5;0.55]) );

opts = coco_add_pars(opts, '', [1 2], {'x' 'y'});

bd = coco(opts, '1', [], 1, {'x' 'y'}, {[], [-1 1]});
end

function bd = run_1D_min_regular_MX(atlas_0d, atlas_1d) %#ok<INUSL>
% cover_1d regular problem, MX at point 15
opts = [];
opts = coco_set(opts, 'cont', 'atlas', atlas_1d);
opts = coco_set(opts, 'cont', 'ItMX', 20);

data.pt = 15;
opts = coco_add_func(opts, 'circle', @circle, data, 'zero', ...
  'x0', [1;0]+sqrt([0.5;0.55]) );

opts = coco_add_pars(opts, '', [1 2], {'x' 'y'});

bd = coco(opts, '1', [], 1, {'x' 'y'}, {[], [-1 1]});

u  = coco_bd_col(bd, {'x' 'y'});
plot(u(1,:), u(2,:), 'b.-')
axis equal
end

function bd = run_1D_min_ev_BP0(atlas_0d, atlas_1d) %#ok<INUSL>
% cover_1d regular problem, initial point inside computational domain
opts = [];
opts = coco_set(opts, 'cont', 'atlas', atlas_1d);
opts = coco_set(opts, 'cont', 'FP', true);
opts = coco_set(opts, 'cont', 'BP', true);

% opts = coco_set(opts, 'cont', 'atlas', '1ds');
% opts = coco_set(opts, 'cont', 'LP', true);
% opts = coco_set(opts, 'cont', 'BP', true);
% opts = coco_set(opts, 'cont', 'interp', 'cubic');

opts = coco_set(opts, 'cont', 'ItMX', 20);

opts = coco_add_func(opts, 'circle', @circle, [], 'zero', ...
  'x0', [1;0]+sqrt([0.5;0.55]) );

% events on embedded monitor function
opts = coco_add_pars(opts, 'cont', [1 2], {'x' 'y'});
opts = coco_add_event(opts, 'UZ', 'y', linspace(0,1,5));

% events on regular monitor function
opts = coco_add_pars(opts, 'reg', [1 2], {'XR' 'YR'}, 'regular');
opts = coco_add_event(opts, 'UYR', 'YR', linspace(0,1,5));

% events on singular monitor function
opts = coco_add_pars(opts, 'sing', [1 2], {'XS' 'YS'}, 'singular');
opts = coco_add_event(opts, 'UYS', 'YS', linspace(0,1,5));

% multi event
opts = coco_add_event(opts, 'MUL', 'YR', 0, 'y', 0, 'YS', 0);

bd = coco(opts, '1', [], 1, {'x' 'y' 'atlas_FP' 'atlas_BP'}, {[1 2] [-0.5 2]});

u  = coco_bd_col(bd, {'x' 'y'});
plot(u(1,:), u(2,:), 'b.-')
axis equal
end

function bd = run_1D_min_ev_BP1(atlas_0d, atlas_1d) %#ok<INUSL>
% cover_1d regular problem, initial point on boundary of computational
% domain
opts = [];
opts = coco_set(opts, 'cont', 'atlas', atlas_1d);

opts = coco_add_func(opts, 'circle', @circle, [], 'zero', ...
  'x0', [1;0]+sqrt([0.5;0.55]) );

opts = coco_add_pars(opts, '', [1 2], {'x' 'y'});

% empty domain
opts = coco_set(opts, 'cont', 'ItMX', 25);
bd = coco(opts, '1', [], 1, {'x' 'y'}, [1+sqrt(0.5) 1+sqrt(0.5)]); %#ok<NASGU>

% continuation direction outside computational domain
opts = coco_set(opts, 'cont', 'ItMX', -25);
bd = coco(opts, '1', [], 1, {'x' 'y'}, [1+sqrt(0.5) 2]); %#ok<NASGU>

% continuation starting at boundary
opts = coco_set(opts, 'cont', 'ItMX', 25);
bd = coco(opts, '1', [], 1, {'x' 'y'}, [1+sqrt(0.5) 2]);

u  = coco_bd_col(bd, {'x' 'y'});
plot(u(1,:), u(2,:), 'b.-')
axis equal
end

function bd = run_1D_min_ev_BP2(atlas_0d, atlas_1d) %#ok<INUSL>
% cover_1d regular problem, initial point outside computational domain
opts = [];
opts = coco_set(opts, 'cont', 'atlas', atlas_1d);
opts = coco_set(opts, 'cont', 'ItMX', 20);

opts = coco_add_func(opts, 'circle', @circle, [], 'zero', ...
  'x0', [1;0]+sqrt([0.5;0.55]) );

opts = coco_add_pars(opts, '', [1 2], {'x' 'y'});

bd = coco(opts, '1', [], 1, {'x' 'y'}, [1 1.5]);

u  = coco_bd_col(bd, {'x' 'y'});
plot(u(1,:), u(2,:), 'b.-')
axis equal
end
