function [x T] = stpnt2(segnum, t) %#ok<INUSL>

[tt xx yy zz] = textread('po2.dat', '%f %f %f %f');

T             = 8.15760;
x = interp1(tt, [xx yy zz], t)';
