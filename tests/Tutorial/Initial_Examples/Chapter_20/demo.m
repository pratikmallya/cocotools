% - I removed usage of atlas in Pass_11 as it does not support adaptation
% - this also came before integration in atlas codes was even discussed
% - this demo now runs three times with different remesh functions

%% command line version
echo on
addpath('../../Atlas_Algorithms/Pass_12');
%% without adaptation
%!tkn1
N          = 7;
p0         = 1;
data       = struct();
data.x_idx = 1:N;
data.p_idx = N+1;
data.t     = linspace(-1, 1, N)';
u0         = [tanh(p0*data.t)/tanh(p0); p0];
%!tkn2
prob = coco_add_func(coco_prob(), 'tanh', @tanh_F, data, ...
  'zero', 'u0', u0);
prob = coco_add_pars(prob, 'pars', N+1, 'p');
prob = coco_add_event(prob, 'UZ', 'p', [1 4 7 10]);
prob = coco_set(prob, 'cont', 'h0', 1', 'hmax', 1);
coco(prob, '1', [], 1, 'p', [1 11]);
%!tkn3
prob = coco_add_slot(prob, 'tanh', @coco_save_data, data, 'save_full');
coco(prob, '1', [], 1, 'p', [1 11]);
echo off

bd = coco_bd_read('1');
labs = coco_bd_labs(bd, 'UZ');
figure(1)
clf
for i=1:numel(labs)
  subplot(2,2,i)
  [soldata sol] = coco_read_solution('tanh','1',labs(i));
  plot(soldata.t, sol.x(soldata.x_idx), 'Marker', '.')
  hold on
  plot(-1:.01:1,tanh(sol.x(soldata.p_idx)*(-1:.01:1))/tanh(sol.x(soldata.p_idx)),'r');
  hold off
  grid on
  drawnow
end

%% with adaptation (constant order), start with adapted solution
echo on
%!tkn4
data.N    = N;
data.pdim = 1;
data.xtr  = zeros(N+data.pdim,1);
data.xtr([1 N:N+data.pdim]) = [1 N:N+data.pdim];
data.th   = linspace(-1, 1, N)';
data.s    = .3;
data.HINC = 2;
data.HDEC = 0;
data = coco_func_data(data);
%!tkn5
data.t    = [-1; 1/p0*atanh((-1+2/(N-1)*(1:N-2)')*tanh(p0)); 1];
u0        = [tanh(p0*data.t)/tanh(p0); p0];
prob = coco_add_func(coco_prob(), 'tanh', @tanh_F, data, 'zero', ...
  'u0', u0, 'remesh', @remesh);
%!tkn6
prob = coco_add_pars(prob, 'pars', N+1, 'p');
prob = coco_add_event(prob, 'UZ', 'p', [1 4 7 10]);
prob = coco_set(prob, 'cont', 'atlas', @atlas_1d_min.create);
prob = coco_set(prob, 'cont', 'NAdapt', 1, 'h0', 1, 'hmax', 1);
coco(prob, '2', [], 1, 'p', [1 11]);
%!tkn7
prob = coco_add_slot(prob, 'tanh', @coco_save_data, data, 'save_full');
coco(prob, '2', [], 1, 'p', [1 11]);
echo off

bd = coco_bd_read('2');
labs = coco_bd_labs(bd, 'UZ');
figure(2)
clf
for i=1:numel(labs)
  subplot(2,2,i)
  [soldata sol] = coco_read_solution('tanh','2',labs(i));
  plot(soldata.t, sol.x(soldata.x_idx), 'Marker', '.')
  hold on
  plot(-1:.01:1,tanh(sol.x(soldata.p_idx)*(-1:.01:1))/tanh(sol.x(soldata.p_idx)),'r');
  hold off
  grid on
  drawnow
end

%% with adaptation (variable order), start with adapted solution
echo on
%!tkn8
data.t    = [-1; 1/p0*atanh((-1+2/(N-1)*(1:N-2)')*tanh(p0)); 1];
u0        = [tanh(p0*data.t)/tanh(p0); p0];
data.N    = N;
data.pdim = 1;
data.xtr  = zeros(N+data.pdim,1);
data.xtr([1 N:N+data.pdim]) = [1 N:N+data.pdim];
data.th   = linspace(-1, 1, N)';
data.s    = 0.3;
data.HINC = 0.3;
data.HDEC = 0.2;
data = coco_func_data(data);
%!tkn9
prob = coco_add_func(coco_prob(), 'tanh', @tanh_F, data, 'zero', ...
  'u0', u0, 'remesh', @remesh);
prob = coco_add_pars(prob, 'pars', N+1, 'p');
prob = coco_add_event(prob, 'UZ', 'p', [1 4 7 10]);
prob = coco_set(prob, 'cont', 'atlas', @atlas_1d_min.create);
prob = coco_set(prob, 'cont', 'NAdapt', 1, 'h0', 1, 'hmax', 1);
coco(prob, '3', [], 1, 'p', [1 11]);
%!tkn10
prob = coco_add_slot(prob, 'tanh', @coco_save_data, data, 'save_full');
coco(prob, '3', [], 1, 'p', [1 11]);
echo off

bd = coco_bd_read('3');
labs = coco_bd_labs(bd, 'UZ');
figure(3)
clf
for i=1:numel(labs)
  subplot(2,2,i)
  [soldata sol] = coco_read_solution('tanh','3',labs(i));
  plot(soldata.t, sol.x(soldata.x_idx), 'Marker', '.')
  hold on
  plot(-1:.01:1,tanh(sol.x(soldata.p_idx)*(-1:.01:1))/tanh(sol.x(soldata.p_idx)),'r');
  hold off
  grid on
  drawnow
end

rmpath('../../Atlas_Algorithms/Pass_12');