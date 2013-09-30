function [opts argnum] = curve_isol2sol(opts, prefix, f, x0, p0, varargin) %#ok<INUSL>
% Parser of toolbox curve for continuation starting at initial point
% (x0,p0). Called by coco as follows:
%   coco(opts, RUN, 'curve','isol','sol', @func, x0, p0, PAR, PAR_INT)

% We simply forward this call to the constructor. In principle, this
% function could handle more arguments for user-friendliness.
opts   = curve_create(opts, f, x0, p0, 1, [], [], []);

% We need to tell COCO how many arguments have been processed, including
% the argument 'prefix', which is ignored here.
argnum = 4;
end
