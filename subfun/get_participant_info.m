function opt = get_participant_info(opt, tgt_name)
% collects the particants.tsv file from the json files

content = spm_jsonread([tgt_name '.json']);
try
    opt.gender{opt.iGroup,opt.iSub} = content.PatientSex;
    opt.age(opt.iGroup,opt.iSub) = str2double(content.PatientAge(1:3));
catch
    warning('Could not get participant age or gender.')
    opt.gender{opt.iGroup,opt.iSub} = '?';
    opt.age(opt.iGroup,opt.iSub) = NaN;
end
end
