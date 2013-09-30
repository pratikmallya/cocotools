function opts = print_headline(opts)
%COCO_PRINT_HEADLINE  Print headline for point information.
%
%   OPTS = COCO_PRINT_HEADLINE(OPTS) prints a headline for the screen
%   output of the bifurcation diagram during computation. This function
%   calls OPTS.CONT.PRINT_HEADLINE to allow printing of a headline for
%   additional output data.
%
%   See also: coco_print_data
%

if nargout<1
	error('%s: too few output arguments', mfilename);
end

if opts.cont.LogLevel(1) < 1
	return;
end

op_idx   = opts.efunc.op_idx;
op_names = coco_idx2par(opts, op_idx);

if ~isfield(opts.cont, 'op_idx')
	op_len   = max(cellfun(@numel, op_names), 12);
	op_sfmt  = sprintf(' %%%ds', op_len(2:end));
	op_fmt   = sprintf(' %%%d.4e', op_len(2:end));

	opts.cont.op_idx   = op_idx;
	opts.cont.op_fmt   = op_fmt;
	opts.cont.op_sfmt  = op_sfmt;
	opts.cont.pp_width = op_len(1);
end

if opts.cont.LogLevel(1) >= 2
  fprintf('%5s %11s  %-5s %6s %*s %12s  %8s', 'STEP', 'STEP SIZE', ...
    'TYPE', 'LABEL', opts.cont.pp_width, op_names{1}, ...
		'||U||', 'TIME');
elseif opts.cont.LogLevel(1) >= 1
  fprintf('%5s  %-5s %6s %*s %12s  %8s', 'STEP', ...
    'TYPE', 'LABEL', opts.cont.pp_width, op_names{1}, ...
		'||U||', 'TIME');
end

fprintf(opts.cont.op_sfmt, op_names{2:end});

opts = coco_emit(opts, 'cont_print', 'init');
fprintf('\n');
