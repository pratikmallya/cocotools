function prob = riess_restart_2(prob, run, lab)

prob = riess_restart_1(prob, run, lab);
data = coco_read_solution('riess_save_2', run, lab);
prob = riess_close_het_2(prob, data);

end