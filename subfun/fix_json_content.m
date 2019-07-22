function fix_json_content(json_file_name, opt)

fprintf(' cleaning %s\n', json_file_name)

opts.indent = opt.indent;

content = spm_jsonread(json_file_name);

field_names = fieldnames(content);

field_of_interest = ~cellfun('isempty', strfind(field_names, 'Patient'));
for i_field = find(field_of_interest)
    content = rmfield(content, field_names(i_field));
end

if isfield(content, 'NiftiCreator')
    content = rmfield(content, 'NiftiCreator');
end

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

spm_jsonwrite(json_file_name, content, opts)
end