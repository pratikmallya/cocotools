function [x T] = stpnt(segnum, t)

T = 2.12*pi;
x = [0.9 * sin(2*pi*t); 0.8 * cos(2*pi*t) ];
