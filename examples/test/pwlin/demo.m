fprintf('**************************\n\n');

clear segs;

p0 = [1;1;1];
f  = @(t,x) pwlin_1(x,p0);
[t1,x1]=ode45(f, [0 pi], [0;1.1]);
f  = @(t,x) pwlin_2(x,p0);
[t2,x2]=ode45(f, [0 pi], [0;-1.1]);

segs(1).fname = '1';
segs(1).t0    = t1;
segs(1).x0    = x1';
segs(1).NTST  = 5;
segs(1).NCOL  = 6;

segs(2).fname = '2';
segs(2).t0    = t2;
segs(2).x0    = x2;
segs(2).NTST  = 10;
segs(2).NCOL  = 4;

opts = coco_set('coll', 'NTST', 10, 'NCOL', 4);
%opts = coco_set(opts, 'cont', 'ItMX', [20 30]);
opts = coco_set(opts, 'coll', 'vareqn', 'on');
opts = coco_set(opts, 'nwtn', 'TOL', 1.0e-5);
opts = coco_set(opts, 'nwtn', 'ItMX', 10);
opts = coco_set(opts, 'nwtn', 'SubItMX', 3);
% opts = coco_set(opts, 'cont', 'LogLevel', 3);
% opts = coco_set(opts, 'cont', 'h_max', 100);

bd = coco(opts, '1', 'bvp', 'isol', 'sol', @pwlin, ...
	segs, p0, 'PAR(2)', [0.1 2]);

labs = coco_bd_labs(bd, 'all');
clf

evm = [];
grad_h = [ [1;0] [1;0] ];

for lab=labs
  sol  = coco_read_solution('coll', '1', lab);
  data = sol.sol;
	
	if isfield(data, 'M0')
		ii = [2:size(data.M0, 2) 1];
		E  = eye(size(data.M0,1), size(data.M0,3));
		M  = E;

		for i=1:size(data.M0, 2)
			A  = E + ((data.f0(:,ii(i))-data.f1(:,i)) * grad_h(:,i)') ...
				/ (grad_h(:,i)'*data.f1(:,i));
			M = A * squeeze(data.M1(:,i,:)) * (squeeze(data.M0(:,i,:))\M);
		end

		evals = eig(M);

		evm = [evm [lab;evals]]; %#ok<AGROW>
	end
  
  hold on
  plot(data.xbp(1,:), data.xbp(2,:), '.-')
  hold off
  grid on
end

axis equal
display(evm)

%% test restart

opts = coco_set(opts, 'coll', 'vareqn', 'off');

bd = coco(opts, '2', 'bvp', 'sol', 'sol', ...
	'1', labs(1), 'PAR(2)', [0 0.2]);

labs = coco_bd_labs(bd, 'all');

for lab=labs
  sol  = coco_read_solution('coll', '2', lab);
  data = sol.sol;
	
  hold on
  plot(data.xbp(1,:), data.xbp(2,:), 'r.-')
  hold off
  grid on
end
