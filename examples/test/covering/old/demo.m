function demo(choice, atlas)
% Full test for covering codes.

if nargin>=2
  
  func = str2func(choice);
  fprintf('\n************\nrunning demo %s\n', choice);
  tm = tic;
  bd = func(atlas); %#ok<NASGU>
  toc(tm);
  
elseif nargin==0

  demos = {'run_0D_min_regular' 'run_0D_min_empty' 'run_0D_min_singular' ...
    'run_0D_min_ev_BP0' 'run_0D_min_ev_BP1' 'run_0D_min_ev_BP2'};
  for i=1:numel(demos)
    demo(demos{i}, '0d');
    drawnow;
    pause(0.5);
  end

  demos = {'run_1D_min_regular' 'run_1D_min_empty' 'run_1D_min_singular' ...
    'run_1D_min_regular_MX' 'run_1D_min_ev_BP0' 'run_1D_min_ev_BP1' ...
    'run_1D_min_ev_BP2'};
  for i=1:numel(demos)
    demo(demos{i}, '1ds');
    drawnow;
    pause(0.5);
  end

  demos = {'run_1D_min_regular' 'run_1D_min_empty' 'run_1D_min_singular' ...
    'run_1D_min_regular_MX' 'run_1D_min_ev_BP0' 'run_1D_min_ev_BP1' ...
    'run_1D_min_ev_BP2'};
  for i=1:numel(demos)
    demo(demos{i}, '1d');
    drawnow;
    pause(0.5);
  end
  
    demos = {'run_2D_min_regular' 'run_2D_min_empty' 'run_2D_min_singular' ...
    'run_2D_min_regular_MX' ...
    ... %'run_2D_min_ev_BP0' 
    'run_2D_min_ev_BP1' ...
    'run_2D_min_ev_BP2'};
  for i=1:numel(demos)
    demo(demos{i}, '2d');
    drawnow;
    pause(0.5);
  end
else
  error('%s: wrong number of arguments', mfilename);
end
end

function bd = run_0D_min_regular(atlas)
% cover_0d regular problem
opts = [];
opts = coco_set(opts, 'cont', 'atlas', atlas);

opts = coco_add_func(opts, 'circle', @circle, [], 'zero', ...
  'x0', [1;0]+sqrt([0.5;0.55]) );

opts = coco_add_parameters(opts, '', [1 2], {'x' 'y'});

bd = coco(opts, '1', [], 0, {'x' 'y'}, {[1 2], [0 1]});

u  = coco_bd_col(bd, {'x' 'y'});
plot(u(1,:), u(2,:), 'b.-')
axis equal
end

function bd = run_0D_min_empty(atlas)
% cover_0d empty problem
opts = [];
opts = coco_set(opts, 'cont', 'atlas', atlas);

opts = coco_add_func(opts, 'circle', @empty, [], 'zero', ...
  'x0', [1;0]+sqrt([0.5;0.55]) );

opts = coco_add_parameters(opts, '', [1 2], {'x' 'y'});

bd = coco(opts, '1', [], 0, {'x' 'y'}, {[], [0 1]});
end

function bd = run_0D_min_singular(atlas)
% cover_0d singular problem
opts = [];
opts = coco_set(opts, 'cont', 'atlas', atlas);

opts = coco_add_func(opts, 'circle', @singular, [], 'zero', ...
  'x0', [1;0]+sqrt([0.5;0.55]) );

opts = coco_add_parameters(opts, '', [1 2], {'x' 'y'});

bd = coco(opts, '1', [], 0, {'x' 'y'}, {[], [0 1]});
end

function bd = run_0D_min_ev_BP0(atlas)
% cover_0d_ev, initial point inside computational domain
opts = [];
opts = coco_set(opts, 'cont', 'atlas', atlas);

opts = coco_add_func(opts, 'circle', @circle, [], 'zero', ...
  'x0', [1;0]+sqrt([0.55;0.5]) );

opts = coco_add_parameters(opts, '', [1 2], {'x' 'y'});

bd = coco(opts, '1', [], 0, {'x' 'y'}, {[], [0 1]});

u  = coco_bd_col(bd, {'x' 'y'});
plot(u(1,:), u(2,:), 'b.-')
axis equal
end

function bd = run_0D_min_ev_BP1(atlas)
% cover_0d_ev, initial point on boundary of computational domain
opts = [];
opts = coco_set(opts, 'cont', 'atlas', atlas);
opts = coco_set(opts, 'cont', 'LogLevel', 2);

opts = coco_add_func(opts, 'circle', @circle, [], 'zero', ...
  'x0', [1;0]+sqrt([0.55;0.5]) );

opts = coco_add_parameters(opts, '', [1 2], {'x' 'y'});

bd = coco(opts, '1', [], 0, {'x' 'y'}, {[], [0 sqrt(0.5)]});

u  = coco_bd_col(bd, {'x' 'y'});
plot(u(1,:), u(2,:), 'b.-')
axis equal
end

function bd = run_0D_min_ev_BP2(atlas)
% cover_0d_ev, initial point outside computational domain
opts = [];
opts = coco_set(opts, 'cont', 'atlas', atlas);
opts = coco_set(opts, 'cont', 'LogLevel', 2);

opts = coco_add_func(opts, 'circle', @circle, [], 'zero', ...
  'x0', [1;0]+sqrt([0.55;0.5]) );

opts = coco_add_parameters(opts, '', [1 2], {'x' 'y'});

bd = coco(opts, '1', [], 0, {'x' 'y'}, {[], [0 0.1]});

u  = coco_bd_col(bd, {'x' 'y'});
plot(u(1,:), u(2,:), 'b.-')
axis equal
end

function bd = run_1D_min_regular(atlas)
% cover_1d regular problem
opts = [];
opts = coco_set(opts, 'cont', 'atlas', atlas);
opts = coco_set(opts, 'cont', 'FP', true);
opts = coco_set(opts, 'cont', 'BP', true);

opts = coco_add_func(opts, 'circle', @circle, [], 'zero', ...
  'x0', [1;0]+sqrt([0.5;0.55]) );

opts = coco_add_parameters(opts, '', [1 2], {'x' 'y'});

opts = coco_set(opts, 'cont', 'ItMX', 20);
bd   = coco(opts, '1', [], 1, {'x' 'y' 'atlas_FP' 'atlas_BP'}, {[], [-1 1]});
u    = coco_bd_col(bd, {'x' 'y'});
plot(u(1,:), u(2,:), 'b.-')
axis equal
grid on
drawnow

opts = coco_set(opts, 'cont', 'ItMX', -20);
bd   = coco(opts, '1', [], 1, {'x' 'y' 'atlas_FP' 'atlas_BP'}, {[], [-1 1]});
u    = coco_bd_col(bd, {'x' 'y'});
hold on
plot(u(1,:), u(2,:), 'r.-')
hold off
axis equal
drawnow

opts = coco_set(opts, 'cont', 'ItMX', 0);
bd   = coco(opts, '1', [], 1, {'x' 'y' 'atlas_FP' 'atlas_BP'}, {[], [-1 1]});
u    = coco_bd_col(bd, {'x' 'y'});
hold on
plot(u(1,:), u(2,:), 'g.-')
hold off
axis equal

end

function bd = run_1D_min_empty(atlas)
% cover_1d empty problem
opts = [];
opts = coco_set(opts, 'cont', 'atlas', atlas);
opts = coco_set(opts, 'cont', 'ItMX', 20);

opts = coco_add_func(opts, 'circle', @empty, [], 'zero', ...
  'x0', [1;0]+sqrt([0.5;0.55]) );

opts = coco_add_parameters(opts, '', [1 2], {'x' 'y'});

bd = coco(opts, '1', [], 1, {'x' 'y'}, {[], [-1 1]});
end

function bd = run_1D_min_singular(atlas)
% cover_1d singular problem
opts = [];
opts = coco_set(opts, 'cont', 'atlas', atlas);
opts = coco_set(opts, 'cont', 'ItMX', 20);

opts = coco_add_func(opts, 'circle', @singular, [], 'zero', ...
  'x0', [1;0]+sqrt([0.5;0.55]) );

opts = coco_add_parameters(opts, '', [1 2], {'x' 'y'});

bd = coco(opts, '1', [], 1, {'x' 'y'}, {[], [-1 1]});
end

function bd = run_1D_min_regular_MX(atlas)
% cover_1d regular problem, MX at point 15
opts = [];
opts = coco_set(opts, 'cont', 'atlas', atlas);
opts = coco_set(opts, 'cont', 'ItMX', 20);

data.pt = 15;
opts = coco_add_func(opts, 'circle', @circle, data, 'zero', ...
  'x0', [1;0]+sqrt([0.5;0.55]) );

opts = coco_add_parameters(opts, '', [1 2], {'x' 'y'});

bd = coco(opts, '1', [], 1, {'x' 'y'}, {[], [-1 1]});

u  = coco_bd_col(bd, {'x' 'y'});
plot(u(1,:), u(2,:), 'b.-')
axis equal
end

function bd = run_1D_min_ev_BP0(atlas)
% cover_1d regular problem, initial point inside computational domain
opts = [];
opts = coco_set(opts, 'cont', 'atlas', atlas);
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
opts = coco_add_parameters(opts, 'cont', [1 2], {'x' 'y'});
opts = coco_add_event(opts, 'UZ', 'y', linspace(0,1,5));

% events on regular monitor function
opts = coco_add_parameters(opts, 'reg', [1 2], {'XR' 'YR'}, 'regular');
opts = coco_add_event(opts, 'UYR', 'YR', linspace(0,1,5));

% events on singular monitor function
opts = coco_add_parameters(opts, 'sing', [1 2], {'XS' 'YS'}, 'singular');
opts = coco_add_event(opts, 'UYS', 'YS', linspace(0,1,5));

% multi event
opts = coco_add_event(opts, 'MUL', 'YR', 0, 'y', 0, 'YS', 0);

bd = coco(opts, '1', [], 1, {'x' 'y' 'atlas_FP' 'atlas_BP'}, {[1 2] [-0.5 2]});

u  = coco_bd_col(bd, {'x' 'y'});
plot(u(1,:), u(2,:), 'b.-')
axis equal
end

function bd = run_1D_min_ev_BP1(atlas)
% cover_1d regular problem, initial point on boundary of computational
% domain
opts = [];
opts = coco_set(opts, 'cont', 'atlas', atlas);

opts = coco_add_func(opts, 'circle', @circle, [], 'zero', ...
  'x0', [1;0]+sqrt([0.5;0.55]) );

opts = coco_add_parameters(opts, '', [1 2], {'x' 'y'});

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

function bd = run_1D_min_ev_BP2(atlas)
% cover_1d regular problem, initial point outside computational domain
opts = [];
opts = coco_set(opts, 'cont', 'atlas', atlas);
opts = coco_set(opts, 'cont', 'ItMX', 20);

opts = coco_add_func(opts, 'circle', @circle, [], 'zero', ...
  'x0', [1;0]+sqrt([0.5;0.55]) );

opts = coco_add_parameters(opts, '', [1 2], {'x' 'y'});

bd = coco(opts, '1', [], 1, {'x' 'y'}, [1 1.5]);

u  = coco_bd_col(bd, {'x' 'y'});
plot(u(1,:), u(2,:), 'b.-')
axis equal
end


function bd = run_2D_min_regular(atlas)
% cover_2d regular problem

opts = [];
opts = coco_set(opts, 'cont', 'atlas', atlas);
opts = coco_set(opts, 'cont', 'h', .5);
opts = coco_set(opts, 'cont', 'thk', .3);
opts = coco_set(opts, 'cont', 'sp', 'first');
opts = coco_set(opts, 'cont', 'PtMX', 500);
opts = coco_add_func(opts, 'sphere', @sphere, [], 'zero', ...
  'x0', [1;1;0] );
opts = coco_add_parameters(opts, '', 1:3, {'x', 'y', 'z'});
[bd atlas1] = coco(opts, 'sphere', [], 2, {'x', 'y', 'z'}, {[0.5 1.5]});

clf
hold on
for i=1:numel(atlas1)
    chart = atlas1{i};
    n = size(chart.sg,2);
    pts = repmat(chart.x, [1 n]) + chart.TS*(chart.sg*chart.R);
    for j=1:n
        plot3([pts(1,mod(j-1,n)+1),pts(1,mod(j+1-1,n)+1)],...
            [pts(2,mod(j-1,n)+1),pts(2,mod(j+1-1,n)+1)],...
            [pts(3,mod(j-1,n)+1),pts(3,mod(j+1-1,n)+1)],'r');
    end
%     pause
end
u  = coco_bd_col(bd, {'x' 'y' 'z'});
plot3(u(1,:), u(2,:), u(3,:), 'b.')
hold off
axis equal
view(60,30)


opts = coco_set(opts, 'cont', 'PtMX', 0);
coco(opts, 'sphere', [], 2, {'x', 'y', 'z'}, {[0.5 1.5]});
end

function bd = run_2D_min_empty(atlas)
% cover_2d empty problem
opts = [];
opts = coco_set(opts, 'cont', 'atlas', atlas);
opts = coco_set(opts, 'cont', 'PtMX', 20);

opts = coco_add_func(opts, 'circle', @empty, [], 'zero', ...
  'x0', [1;1;0] );

opts = coco_add_parameters(opts, '', 1:3, {'x', 'y', 'z'});

bd = coco(opts, 'sphere', [], 2, {'x', 'y', 'z'});
end

function bd = run_2D_min_singular(atlas)
% cover_2d singular problem
opts = [];
opts = coco_set(opts, 'cont', 'atlas', atlas);
opts = coco_set(opts, 'cont', 'PtMX', 20);

opts = coco_add_func(opts, 'circle', @singular, [], 'zero', ...
  'x0', [1;1;0] );

opts = coco_add_parameters(opts, '', 1:3, {'x', 'y', 'z'});

bd = coco(opts, 'sphere', [], 2, {'x', 'y', 'z'});
end

function bd = run_2D_min_regular_MX(atlas)
% cover_2d regular problem, MX at point 15
opts = [];
opts = coco_set(opts, 'cont', 'atlas', atlas);
opts = coco_set(opts, 'cont', 'PtMX', 20);

data.pt = 15;
opts = coco_add_func(opts, 'sphere', @sphere, data, 'zero', ...
  'x0', [1;1;0] );

opts = coco_add_parameters(opts, '', 1:3, {'x', 'y', 'z'});

bd = coco(opts, 'sphere', [], 2, {'x', 'y', 'z'});
end
% 
% function bd = run_1D_min_ev_BP0(atlas)
% % cover_1d regular problem, initial point inside computational domain
% opts = [];
% opts = coco_set(opts, 'cont', 'atlas', atlas);
% opts = coco_set(opts, 'cont', 'FP', true);
% opts = coco_set(opts, 'cont', 'BP', true);
% 
% % opts = coco_set(opts, 'cont', 'atlas', '1ds');
% % opts = coco_set(opts, 'cont', 'LP', true);
% % opts = coco_set(opts, 'cont', 'BP', true);
% % opts = coco_set(opts, 'cont', 'interp', 'cubic');
% 
% opts = coco_set(opts, 'cont', 'ItMX', 20);
% 
% opts = coco_add_func(opts, 'circle', @circle, [], 'zero', ...
%   'x0', [1;0]+sqrt([0.5;0.55]) );
% 
% % events on embedded monitor function
% opts = coco_add_parameters(opts, 'cont', [1 2], {'x' 'y'});
% opts = coco_add_event(opts, 'UZ', 'y', linspace(0,1,5));
% 
% % events on regular monitor function
% opts = coco_add_parameters(opts, 'reg', [1 2], {'XR' 'YR'}, 'regular');
% opts = coco_add_event(opts, 'UYR', 'YR', linspace(0,1,5));
% 
% % events on singular monitor function
% opts = coco_add_parameters(opts, 'sing', [1 2], {'XS' 'YS'}, 'singular');
% opts = coco_add_event(opts, 'UYS', 'YS', linspace(0,1,5));
% 
% % multi event
% opts = coco_add_event(opts, 'MUL', 'YR', 0, 'y', 0, 'YS', 0);
% 
% bd = coco(opts, '1', [], 1, {'x' 'y' 'atlas_FP' 'atlas_BP'}, {[1 2] [-0.5 2]});
% 
% u  = coco_bd_col(bd, {'x' 'y'});
% plot(u(1,:), u(2,:), 'b.-')
% axis equal
% end
% 
function bd = run_2D_min_ev_BP1(atlas)
% cover_2d regular problem, initial point on boundary of computational
% domain
opts = [];
opts = coco_set(opts, 'cont', 'atlas', atlas);
opts = coco_set(opts, 'cont', 'h', .2);
opts = coco_set(opts, 'cont', 'thk', .1);
opts = coco_set(opts, 'cont', 'sp', 'first');
opts = coco_set(opts, 'cont', 'PtMX', 500);
opts = coco_add_func(opts, 'sphere', @sphere, '', 'zero', ...
  'x0', [1;1;0] );

opts = coco_add_parameters(opts, '', 1:3, {'x', 'y', 'z'});

% empty domain
[bd atlas1]= coco(opts, 'sphere', [], 2, {'x', 'y', 'z'}, [1, 1]);
clf
hold on
for i=1:numel(atlas1)
    chart = atlas1{i};
    n = size(chart.sg,2);
    pts = repmat(chart.x, [1 n]) + chart.TS*(chart.sg*chart.R);
    for j=1:n
        plot3([pts(1,mod(j-1,n)+1),pts(1,mod(j+1-1,n)+1)],...
            [pts(2,mod(j-1,n)+1),pts(2,mod(j+1-1,n)+1)],...
            [pts(3,mod(j-1,n)+1),pts(3,mod(j+1-1,n)+1)],'r');
    end
end
u  = coco_bd_col(bd, {'x' 'y' 'z'});
plot3(u(1,:), u(2,:), u(3,:), 'b.')
hold off
axis equal
view(60,30)

pause(1)

[bd atlas1] = coco(opts, 'sphere', [], 2, {'x', 'y', 'z'}, [1, 2]);
clf
hold on
for i=1:numel(atlas1)
    chart = atlas1{i};
    n = size(chart.sg,2);
    pts = repmat(chart.x, [1 n]) + chart.TS*(chart.sg*chart.R);
    for j=1:n
        plot3([pts(1,mod(j-1,n)+1),pts(1,mod(j+1-1,n)+1)],...
            [pts(2,mod(j-1,n)+1),pts(2,mod(j+1-1,n)+1)],...
            [pts(3,mod(j-1,n)+1),pts(3,mod(j+1-1,n)+1)],'r');
    end
end
u  = coco_bd_col(bd, {'x' 'y' 'z'});
plot3(u(1,:), u(2,:), u(3,:), 'b.')
hold off
axis equal
view(60,30)

pause(1)

[bd atlas1] = coco(opts, 'sphere', [], 2, {'x', 'y', 'z'}, [0, 1]);
clf
hold on
for i=1:numel(atlas1)
    chart = atlas1{i};
    n = size(chart.sg,2);
    pts = repmat(chart.x, [1 n]) + chart.TS*(chart.sg*chart.R);
    for j=1:n
        plot3([pts(1,mod(j-1,n)+1),pts(1,mod(j+1-1,n)+1)],...
            [pts(2,mod(j-1,n)+1),pts(2,mod(j+1-1,n)+1)],...
            [pts(3,mod(j-1,n)+1),pts(3,mod(j+1-1,n)+1)],'r');
    end
end
u  = coco_bd_col(bd, {'x' 'y' 'z'});
plot3(u(1,:), u(2,:), u(3,:), 'b.')
hold off
axis equal
view(60,30)

pause(1)

% continuation starts from corner of computational domain
[bd atlas1] = coco(opts, 'sphere', [], 2, {'x', 'y', 'z'}, {[0, 1],[0 2],[0 1]});
clf
hold on
for i=1:numel(atlas1)
    chart = atlas1{i};
    n = size(chart.sg,2);
    pts = repmat(chart.x, [1 n]) + chart.TS*(chart.sg*chart.R);
    for j=1:n
        plot3([pts(1,mod(j-1,n)+1),pts(1,mod(j+1-1,n)+1)],...
            [pts(2,mod(j-1,n)+1),pts(2,mod(j+1-1,n)+1)],...
            [pts(3,mod(j-1,n)+1),pts(3,mod(j+1-1,n)+1)],'r');
    end
end
u  = coco_bd_col(bd, {'x' 'y' 'z'});
plot3(u(1,:), u(2,:), u(3,:), 'b.')
hold off
axis equal
view(60,30)
end

function bd = run_2D_min_ev_BP2(atlas)
% cover_2d regular problem, initial point outside computational domain
opts = [];
opts = coco_set(opts, 'cont', 'atlas', atlas);
opts = coco_set(opts, 'cont', 'PtMX', 20);

data.pt = 15;
opts = coco_add_func(opts, 'sphere', @sphere, data, 'zero', ...
  'x0', [1;1;0] );

opts = coco_add_parameters(opts, '', 1:3, {'x', 'y', 'z'});

bd = coco(opts, 'sphere', [], 2, {'x', 'y', 'z'},[1.2 1.5]);
end
