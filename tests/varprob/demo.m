% clf

clear segs;

segs(1).fname = [];
segs(1).t0    = [0 1/3];
segs(1).x0    = zeros(3,2);
segs(1).NTST  = 10;
segs(1).NCOL  = 4;

segs(2).fname = [];
segs(2).t0    = [1/3 2/3];
segs(2).x0    = zeros(3,2);
segs(2).NTST  = 5;
segs(2).NCOL  = 6;

segs(3).fname = [];
segs(3).t0    = [2/3 1];
segs(3).x0    = zeros(3,2);
segs(3).NTST  = 10;
segs(3).NCOL  = 4;

opts = coco_set('coll', 'NTST', 25, 'NCOL', 4);
opts = coco_set(opts, 'cont', 'ItMX', 1000);
opts = coco_set(opts, 'coll', 'vareqn', 'on');
% opts = coco_set(opts, 'cont', 'LogLevel', 3);
% opts = coco_set(opts, 'cont', 'h_max', 100);

bd = coco(opts, '1', 'bvp', 'isol', 'sol', @linode, 'linode_bc', ...
	segs, 1, 'PAR(1)', [0.5 1.5]);

load('data/1/sol1.mat', 'data');
M0 = squeeze(data.M0(:,1,:));
M1 = squeeze(data.M1(:,1,:));

for i=2:size(data.M0, 2)
  M1 = M1 * (squeeze(data.M0(:,i,:))\squeeze(data.M1(:,i,:)));
end

M = expm(linode(eye(3,3), [1 1 1]));

eig(M)
eig(M1,M0)
