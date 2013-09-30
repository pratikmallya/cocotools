function prob = compalg_sol2sys(prob, oid, varargin)

ttbid = coco_get_id(oid, 'compalg');
str = coco_stream(varargin{:});
run = str.get;
if ischar(str.peek)
  stbid = coco_get_id(str.get, 'compalg');
else
  stbid = ttbid;
end
lab = str.get;

data = coco_read_solution(stbid, run, lab);
for i=1:data.neqs
  soid = coco_get_id(stbid, sprintf('eqn%d', i));
  toid = coco_get_id(ttbid, sprintf('eqn%d', i));
  prob = alg_sol2eqn(prob, toid, run, soid, lab);
end
prob = compalg_close_sys(prob, ttbid, data);

end