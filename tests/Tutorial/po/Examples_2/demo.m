% - added a second parameter for the suspicious looking '6'
%   this is needed in next demo on continuation with constant period
% - changed run name to be consistent with demo in Examples_3
% - check the necessity of the pnames argument in po_isol2orb, to me this
%   looks like it should have the coll_in input sequence, it would also
%   look a bit more consistent with calls to coll
% - for the same reason one could probably ommit the pnames argument in
%   bvp and hspo

echo on
addpath('../../coll/Pass_1')
addpath('../')
%!tkn1
t0 = (0:2*pi/100:2*pi)';
x0 = 0.01*(cos(t0)*[1 0 -1]-sin(t0)*[0 1 0]);
p0 = [0; 6];
%!tkn2
prob = coco_prob();
prob = po_isol2orb(prob, '', @marsden, t0, x0, {'p1' 'p2'}, p0);
coco(prob, 'po', [], 1, {'p1' 'po.period'}, [-1 1]);
%!tkn3
%!tkn5
bd = coco_bd_read('po');
labs = coco_bd_labs(bd, 'all');
cla;
grid on;
hold on;
for lab=labs
    sol = po_read_solution('', 'po', lab);
    plot3(sol.x(:,1), sol.x(:,2), sol.x(:,3), 'b.-')
end
hold off
drawnow

rmpath('../../coll/Pass_1')
rmpath('../')

% prob = po_Hopf2orb2(prob, '', @lorentz, [sqrt(20); sqrt(20); 20], ...
%   {'s', 'r', 'b'}, [3; 21; 1]);
% % prob = po_Hopf2orb2(prob, '', @lienard, [0; 0], 'r', 0);
% [data uidx] = coco_get_func_data(prob, 'po.seg.coll', ...
%   'data', 'uidx');
% ampdata.W   = data.W;
% ampdata.ys  = repmat(zeros(3,1), [data.coll.NTST*data.coll.NCOL 1]);
% ampdata.wts = data.wts2;
% prob = coco_add_func(prob, 'amp', @po_Hopfamp, ampdata, ...
%   'inactive', 'amp', 'uidx', uidx(data.xbp_idx));
% %!tkn4
% bd   = coco(prob, 'run', [], 1, 'amp', [0 10]);