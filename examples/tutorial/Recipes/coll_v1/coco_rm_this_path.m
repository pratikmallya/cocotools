function coco_rm_this_path
% Remove toolbox from search path.
rmpath(fileparts(mfilename('fullpath')));
end
