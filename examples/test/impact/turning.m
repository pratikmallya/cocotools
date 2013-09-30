function [opts y] = turning(opts, xp, varargin)
% TURNING   Detection of grazing
%
%   TURNING(OPTS,XP) Expression for h_turning

seg   = 1;
x1idx = opts.coll.x1idx((seg-1)*3+(1:3));
x1idx = opts.pdat.xidx(x1idx);
x1    = xp(x1idx,:);
p     = xp(opts.pdat.pidx,:);

[opts y(1,:)] = ev_turning(opts,x1,p);

% if numel(y)==1
% 	fprintf('x = [% .2e % .2e % .2e]; turning = % .2e\n', ...
% 		x1(1), x1(2), x1(3), y);
% end
