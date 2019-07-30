function bring_back_dummies(func_src_dir,opt)

dummy_dir = [deblank(func_src_dir) '-dummy'];

dummies = spm_select('FPList', dummy_dir, ...
    '^.*.dcm$');
for i_dummy = 1:size(dummies,1)
    movefile(dummies(i_dummy,:), func_src_dir)
end

pause(opt.pauseTime)

rmdir(dummy_dir)

end