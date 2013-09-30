function [sol data] = dft_read_solution(oid, run, lab)

tbid         = coco_get_id(oid, 'dft');
[data chart] = coco_read_solution(tbid, run, lab);

dim = data.dim;
N   = 2*data.dft.NMAX+2;

sol.t = chart.x(data.T_idx)*(0:N)/N;
sol.c = reshape(chart.x(data.xf_idx), [dim data.dft.NMOD*2+1]);
sol.x = reshape(real(data.FinvsW*chart.x(data.xf_idx)), [dim N]);
sol.x = [sol.x sol.x(:,1)]';
sol.p = chart.x(data.p_idx);
sol.T = chart.x(data.T_idx);

end