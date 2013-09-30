function [opts argnum] = cac_isol2sol(opts, varargin)
% opts = [];
% fhan = {@f1, @f2};
% 
% x0 = {[0.1 0.4 0.2]',[0.8 0.6 0.3]'};
% p0 = {[0.02 0.12]',[0.43],[0.87]};
% x0 = {[0.4],[0.4]};
% p0 = {[],[],[0;0.5;0]};
%% process input arguments
%  varargin = { prefix, fhan, [dfdxhan, [dfdphan,]] x0, p0 }

argidx = 1;
prefix = varargin{argidx};

fhan   = varargin{argidx+1};
x0     = varargin{argidx+2};
p0     = varargin{argidx+3};
argnum = argidx + 3;

%% create instance of toolbox alcont 1

arglist = { fhan{1} , x0{1} , [ p0{1} ; p0{3} ] };
opts = alcont_isol2sol(opts, 'item1', arglist{:});

%% create instance of toolbox alcont 2

arglist = { fhan{2} , x0{2} , [ p0{2} ; p0{3} ] };
opts = alcont_isol2sol(opts, 'item2', arglist{:});

%% Equating the parameters

data.ip_idx1 = 1:numel(p0{1});
data.sp_idx1 = numel(p0{1})+(1:numel(p0{3}));
data.ip_idx2 = 1:numel(p0{2});
data.sp_idx2 = numel(p0{2})+(1:numel(p0{3}));

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
