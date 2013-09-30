function y = hspo_bc(data, T, x0, x1, p)

y = [];
for i=1:data.nsegs
  y = [y;
    data.hhan(x1(data.x1_idx{i}), p, data.events{i}); ...
    x0(data.x0_idx{mod(i,data.nsegs)+1})- ...
    data.ghan(x1(data.x1_idx{i}), p, data.resets{i})];
end

end