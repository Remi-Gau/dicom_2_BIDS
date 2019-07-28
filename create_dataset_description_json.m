function create_dataset_description_json(tgt_dir, opt)
% %  Required fields:
% dd_json.Name = 'olfiddis'; % name of the dataset
% dd_json.BIDSVersion = '1.1.0'; % The version of the BIDS standard that was used
% 
% %  Recommended fields:
% dd_json.License = '';% what license is this dataset distributed under? The 
%       % use of license name abbreviations is suggested for specifying a license. 
%       % A list of common licenses with suggested abbreviations can be found in appendix III.
% dd_json.Authors = {'','',''};% List of individuals who contributed to the 
%       % creation/curation of the dataset
% dd_json.Acknowledgements = ''; % who should be acknowledge in helping to collect the data
% dd_json.HowToAcknowledge = ''; % Instructions how researchers using this 
%       % dataset should acknowledge the original authors. This field can also be used 
%       % to define a publication that should be cited in publications that use the
%       % dataset.
% dd_json.Funding = {'','',''}; % sources of funding (grant numbers)
% dd_json.ReferencesAndLinks = {'','',''};% a list of references to 
%       % publication that contain information on the dataset, or links.
% dd_json.DatasetDOI = ''; %the Document Object Identifier of the dataset 
%       % (not the corresponding paper).


opts.indent = opt.indent;

dataset_description_json_name = fullfile(tgt_dir, ...
    'dataset_description.json');

fprintf('\ncreating %s', dataset_description_json_name)

dd_json = opt.dd_json;


%% Write JSON

jsonSaveDir = fileparts(dataset_description_json_name);
if ~isdir(jsonSaveDir)
    fprintf('Warning: directory to save json file does not exist: %s \n',jsonSaveDir)
end

spm_jsonwrite(dataset_description_json_name,dd_json, opts)

end