function coco_rm_this_path
rmpath(fileparts(mfilename('fullpath')));
end
