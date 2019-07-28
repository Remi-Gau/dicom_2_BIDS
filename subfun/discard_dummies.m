function discard_dummies(func_src_dir, nb_dummies)

fprintf('\n\n discarding %i dummies from from: %s', nb_dummies, func_src_dir)

dummy_dir = [deblank(func_src_dir) '-dummy'];

% first we bring them back into the main pool in case the
% number of dummies we want to set aside has changed since last
% time we ran the conversion
if exist(dummy_dir, 'dir')
    dummies = spm_select('FPList', dummy_dir, ...
        '^.*.dcm$');
    for i_dummy = 1:size(dummies,1)
        movefile(dummies(i_dummy,:), func_src_dir)
    end
else
    mkdir(dummy_dir)
end

% then we select the ones we want to discard and move them into
% the dummy folder
dummies = spm_select('FPList', func_src_dir, ...
    '^.*.dcm$');
if ~isempty(dummies)
    for i_dummy = 1:nb_dummies
        movefile(dummies(i_dummy,:), dummy_dir)
    end
end

end