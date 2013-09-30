function [ segs t x ] = coll_read_sol(prefix, run, lab)

fid  = coco_get_id(prefix, 'coll');
data = coco_read_solution(fid, run, lab);
segs = data.sol.seglist;
t    = data.sol.tbp;
x    = data.sol.xbp;
