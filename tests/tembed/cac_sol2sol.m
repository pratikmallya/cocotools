function [opts argnum] = cac_sol2sol(opts, prefix, rrun, rlab, varargin)

%% process input arguments
%  varargin = {}

argnum = 3;

%% create instance of toolbox alcont 1

opts = alcont_sol2sol(opts, 'item1', rrun, rlab);

%% create instance of toolbox alcont 2

opts = alcont_sol2sol(opts, 'item2', rrun, rlab);

%% Equating the parameters

fid  = coco_get_id(prefix, 'cac_data');
data = coco_read_solution(fid, rrun, rlab);

[fdata xidx] = coco_get_func_data(opts, 'item1.alcont', 'data', 'xidx');
item1_pidx   = xidx( fdata.p_idx );
item1_ipidx  = item1_pidx(data.ip_idx1);
item1_spidx  = item1_pidx(data.sp_idx1);

[fdata xidx] = coco_get_func_data(opts, 'item2.alcont', 'data', 'xidx');
item2_pidx   = xidx( fdata.p_idx );
item2_ipidx  = item2_pidx(data.ip_idx2);
item2_spidx  = item2_pidx(data.sp_idx2);

xidx = [item1_spidx item2_spidx];
A    = [ ones(size(item1_spidx))' -ones(size(item2_spidx))' ];
b    = zeros(size(A,1),1);
fid  = coco_get_id(prefix, 'cac');
opts = coco_add_functionals(opts, fid, 'shared_pars', A, b, xidx);

%% add call back function

fid  = coco_get_id(prefix, 'cac_data');
opts = coco_add_slot(opts, fid, @coco_save_data, data, 'save_full');

%% Add all free parameters if top level toolbox
if isempty(prefix)
  xidx = [ item1_ipidx item2_ipidx item2_spidx ];
  opts = coco_add_parameters(opts, prefix, xidx, 1:numel(xidx));
end
