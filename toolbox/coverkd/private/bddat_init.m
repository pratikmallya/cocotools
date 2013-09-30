function [opts bd] = bddat_init(opts)
%BDDAT_INIT  Initialise bifurcation diagram.
%
%   [OPTS BD] = BDDAT_INIT(OPTS) initialises the cell array bddat.bd with a
%   row containing the headings for all columns.
%
%   See also:
%

if ~isfield(opts.cont, 'op_idx')
	op_idx   = opts.efunc.op_idx;
	op_names = coco_idx2par(opts, op_idx);
	op_len   = max(cellfun(@numel, op_names), 12);
	op_sfmt  = sprintf(' %%%ds', op_len(2:end));
	op_fmt   = sprintf(' %%%d.4e', op_len(2:end));

	opts.cont.op_idx   = opts.efunc.pidx2midx(op_idx);
	opts.cont.op_fmt   = op_fmt;
	opts.cont.op_sfmt  = op_sfmt;
	opts.cont.pp_width = op_len(1);
end

bd = { 'Br', 'It', 'StepSize', 'TYPE', 'SLAB', 'LAB', op_names{1}, ...
	'||U||', op_names };

[opts res] = coco_emit(opts, 'bddat', 'init');
for i=1:size(res,1)
  bd = [bd res{i,2}]; %#ok<AGROW>
end
