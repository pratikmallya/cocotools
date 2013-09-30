function [opts fbc] = linode_bc_F(opts, x, p)

fbc = opts.bcond.Phi * x - opts.bcond.b;
