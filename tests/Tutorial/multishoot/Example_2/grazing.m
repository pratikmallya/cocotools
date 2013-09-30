function [data y] = grazing(opts, data, u) %#ok<INUSL>
% Detect grazing at end of first segment.

% Is this comment wrong? The usage of this function suggests:
% Detect grazing at start of second segment.

y = u(1) - u(2);
end

