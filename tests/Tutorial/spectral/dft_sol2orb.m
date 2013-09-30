function prob = dft_sol2orb(prob, oid, varargin)

tbid = coco_get_id(oid, 'dft');
str  = coco_stream(varargin{:});
run  = str.get;
if ischar(str.peek)
  soid = str.get;
  lab  = str.get;
else
  soid = oid;
  lab  = str.get;
end
if strcmp(str.peek, 'end-dft')
  str.skip;
end

[sol data] = dft_read_solution(soid, run, lab);
data       = dft_get_settings(prob, tbid, data);
sol        = dft_init_sol(data, sol.t, sol.x, sol.p);
data       = dft_init_data(data, sol);
prob       = dft_construct_orb(prob, tbid, data, sol);

end