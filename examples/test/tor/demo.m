clf;

p0 = [-5.88192e-01 ; 0.5 ; -0.6 ; 0.6 ; 0.328578 ; 0.933578];

opts = coco_set('coll', 'NTST', 25, 'NCOL', 4);
opts = coco_set(opts, 'pocont', 'bifurcations', 'on');
% opts = coco_set(opts, 'coll', 'vareqn', 'on');

% opts = coco_set(opts, 'cont', 'NPR', 200);
opts = coco_set(opts, 'cont', 'ItMX', [50 50]);
opts = coco_set(opts, 'cont', 'LogLevel', 1);
opts = coco_set(opts, 'nwtn', 'TOL', 1.0e-5);
opts = coco_set(opts, 'nwtn', 'SubItMX', 3);

opts = coco_set(opts, 'cont', 'covering', @cover_1d_min_ev.create);
bd1 = coco(opts, 'po1', 'pocont', 'ipo', 'po', @tor, ...
	@stpnt1, p0, {'PAR(1)' 'Period' 'SN' 'PD' 'TR'}, [-0.65, -0.55]);

pars = coco_bd_col(bd1, 'PAR(1)');
pars = [ pars ; p0(2)*ones(size(pars)) ; coco_bd_col(bd1, '||U||')];
plot3(pars(1,:), pars(2,:), pars(end,:), 'b.-');
axis([-0.65 -0.58 0.35 0.65 24 32]);
grid on
drawnow

%%
p0 = [-5.90624e-01 ; 0.5 ; -0.6 ; 0.6 ; 0.328578 ; 0.933578];

bd2 = coco(opts, 'po2', 'pocont', 'ipo', 'po', @tor, ...
	@stpnt2, p0, {'PAR(1)' 'Period' 'SN' 'PD' 'TR'}, [-0.65, -0.55]);

pars = coco_bd_col(bd2, 'PAR(1)');
pars = [ pars ; p0(2)*ones(size(pars)) ; coco_bd_col(bd2, '||U||')];
hold on
plot3(pars(1,:), pars(2,:), pars(end,:), 'r.-');
hold off
drawnow

%%
PDlabs = coco_bd_labs(bd2, 'PD');
for PDlab = PDlabs
  bd3 = coco(opts, 'pd1', 'pocont', 'po', 'PD', ...
    'po2', PDlab, {'PAR(1)' 'Period' 'PAR(2)' 'SN' 'PD' 'TR'}, [-0.65, -0.55]);
  
  pars = coco_bd_col(bd3, {'PAR(1)' 'PAR(2)' '||U||'});
  hold on
  plot3(pars(1,:), pars(2,:), pars(end,:), 'g.-');
  hold off
  drawnow
end

%%
SNlabs = coco_bd_labs(bd1, 'SN');
bd4 = coco(opts, 'lp1', 'pocont', 'po', 'SN', ...
	'po1', SNlabs(end-1), {'PAR(1)' 'Period' 'PAR(2)' 'SN' 'PD' 'TR'}, [-0.65, -0.55]);

pars = coco_bd_col(bd4, {'PAR(1)' 'PAR(2)' '||U||'});
hold on
plot3(pars(1,:), pars(2,:), pars(3,:), 'y.-'); % BP curve
hold off
drawnow

bd4 = coco(opts, 'lp1', 'pocont', 'po', 'SN', ...
	'po1', SNlabs(end), {'PAR(1)' 'Period' 'PAR(2)' 'SN' 'PD' 'TR'}, [-0.65, -0.55]);

pars = coco_bd_col(bd4, {'PAR(1)' 'PAR(2)' '||U||'});
hold on
plot3(pars(1,:), pars(2,:), pars(3,:), 'm.-'); % SN curve
hold off
drawnow

%%
opts = coco_set(opts, 'cont', 'ItMX', 100);
TRlabs = coco_bd_labs(bd2, 'TR');
bd5 = coco(opts, 'tr1', 'pocont', 'po', 'TR', ...
  'po2', TRlabs(1), {'PAR(1)' 'Period' 'PAR(2)' 'SN' 'PD' 'TR'}, [-0.65, -0.55]);

pars = coco_bd_col(bd5, {'PAR(1)' 'PAR(2)' '||U||'});
hold on
plot3(pars(1,:), pars(2,:), pars(3,:), 'c.-');
hold off
drawnow
