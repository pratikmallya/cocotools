function [val] = coco_bd_val(bd, lab, name)

func = @(x) ~isempty(x) && x==lab;
labs = coco_bd_col(bd, 'LAB', 0);
row  = cellfun(func, labs);
col  = coco_bd_col(bd, name, 0);
val  = col{row};
