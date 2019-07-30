function fix_json_content(json_file_name, pattern, opt)
% reads the content of a json file from a DICOM conversion and renames some fields
% to make them BIDS compatible. It will also add or remove some fields when needed.

opts.indent = opt.indent;

fprintf(' cleaning %s\n', json_file_name)

content = spm_jsonread(json_file_name);

% remove any fields with Patient in it
field_names = fieldnames(content);
field_of_interest = ~cellfun('isempty', strfind(field_names, 'Patient'));
for i_field = find(field_of_interest)
    content = rmfield(content, field_names(i_field));
end

if isfield(content, 'NiftiCreator')
    content = rmfield(content, 'NiftiCreator');
end

% renames PhaseEncodingDirection to make it BIDS compliant
if isfield(content, 'PhaseEncodingDirection')
    switch content.PhaseEncodingDirection
        case 'x'
            content.PhaseEncodingDirection = 'i';
        case 'y'
            content.PhaseEncodingDirection = 'j';
        case 'z'
            content.PhaseEncodingDirection = 'k';
        case 'x-'
            content.PhaseEncodingDirection = 'i-';
        case 'y-'
            content.PhaseEncodingDirection = 'j-';
        case 'z-'
            content.PhaseEncodingDirection = 'k-';
    end
end

% Add the number of dummies removed to the json for func files
if  strcmp(opt.type, 'func')

    if opt.nb_dummies > 0
        content.NumberOfVolumesDiscardedByUser = opt.nb_dummies;
    end

    TaskName = pattern.output;
    TaskName = strrep(TaskName, '-', '');
    TaskName = strrep(TaskName, '.', '');
    content.TaskName = TaskName;

end

spm_jsonwrite(json_file_name, content, opts)
end
