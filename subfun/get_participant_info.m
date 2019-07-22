function opt = get_participant_info(opt, anat_tgt_name)
content = spm_jsonread([anat_tgt_name '.json']);
try
    opt.gender{opt.iSub} = content.PatientSex;
    opt.age(opt.iSub) = str2double(content.PatientAge(1:3));
catch
    warning('Could not get participant age or gender.')
    opt.gender{opt.iSub} = '?';
    opt.age(opt.iSub) = NaN;
end
end