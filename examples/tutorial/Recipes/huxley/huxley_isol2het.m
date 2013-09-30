function prob = huxley_isol2het(prob, segs, eps0)

prob = coll_isol2seg(prob, 'huxley1', @huxley, ...
  segs(1).t0, segs(1).x0, segs(2).p0);
prob = coll_isol2seg(prob, 'huxley2', @huxley, ...
  segs(2).t0, segs(2).x0, segs(2).p0);

prob = huxley_close_het(prob, eps0);

end