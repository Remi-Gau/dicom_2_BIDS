function opt = get_participant_info(opt, iSub, anat_tgt_name)
content = spm_jsonread([anat_tgt_name '.json']);
try
    opt.gender{iSub} = content.PatientSex;
    opt.age(iSub) = str2double(content.PatientAge(1:3));
catch
    warning('Could not get participant age or gender.')
    opt.gender{iSub} = '?';
    opt.age(iSub) = NaN;
end
end