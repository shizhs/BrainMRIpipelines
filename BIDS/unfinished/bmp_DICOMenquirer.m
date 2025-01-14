function varargout = bmp_DICOMenquirer (varargin)
%
% DESCRIPTION
% ===================================================================================
%
%   This script aims to enquire information stored in DICOM header. The script also
%   generates suggested possible DICOM key fields to construct DICOM-to-BIDS mapping, 
%   and unique values in the key fields. The outputs can then be used in
%   'bmp_DICOMtoBIDSmapper' to create DICOM-to-BIDS mapping.
%
%
% USAGE
% ===================================================================================
%
%   [suggested_field_names, unique_val_in_fields] ...
%           = bmp_DICOMenquirer ([<DICOM_directory>], [Name, Value])
%
%
% ARGUMENTS
% ===================================================================================
%
%   DICOM_directory = Path to DICOM directory. Default is pwd.
%
%   Name-Value pairs
%
%     Name  : 'KeyFields'.
%
%     Value : A cell arry to specify fields in DICOM info to distinguish different 
%             imaging modality. Current default is 
%             { 
%               'SeriesDescription'
%               'ProtocolName'
%               'SequenceName'
%               'SeriesNumber'
%             }.
%
%
% OUTPUTS
% ===================================================================================
%
%   varargout{1} = vertical cell array of suggested field names.
%
%   varargout{2} = vertical cell array of cell arrays of unique values in suggested 
%                  fields.
%
%   Enquiry results will also be displayed in MATLAB Command Window.
%
% 
% EXAMPLES
% ===================================================================================
%
%   bmp_DICOMenquirer;
%
%   bmp_DICOMenquirer ('KeyFields', {'SeriesDescription'});
%
%   bmp_DICOMenquirer ('/path/to/DICOM');
%
%   bmp_DICOMenquirer ('/path/to/DICOM', ...
%           'KeyFields', {'SeriesDescription';'Seriesnumber'});
%
%   [fname,fval] = bmp_DICOMenquirer;
%
% 
%
% DEPENDENCIES
% ===================================================================================
%
%   - Image Processing Toolbox
%
% 
% HISTORY
% ===================================================================================
%
%   29 Nov 2022 - first version.
%
% 
%
% KNOWN ISSUES
% ===================================================================================
%
%   None.
%


	defaultDICOMdirectory        = pwd;
	defaultKeyFields             = {
									'SeriesDescription'
									'ProtocolName'
									'SequenceName'
									'SeriesNumber'
									};

	p = inputParser;

	addOptional  (p, 'DICOM_directory',     defaultDICOMdirectory,      @isfolder);
	addParameter (p, 'KeyFields',           defaultKeyFields,           @iscell);

	parse (p, varargin{:});



	fprintf ('%s : Started (%s).\n', mfilename, string(datetime));


	% Get paths to all DICOM files
	all_dir = dir (fullfile (p.Results.DICOM_directory, '**'));
	all_DICOM = all_dir (~[all_dir.isdir]); % exclude folders
	clear all_dir;

	fprintf ('%s : %s has %d DICOM files.\n', mfilename, p.Results.DICOM_directory, size (all_DICOM,1));
	fprintf ('%s : Below key fileds will be used to distinguish different modalities.\n', mfilename);
	for i = 1 : size (p.Results.KeyFields, 1)
		fprintf ('  - %s\n', p.Results.KeyFields{i,1});
	end

	keyFields = cell (size (all_DICOM, 1), size (p.Results.KeyFields, 1));

	fprintf ('%s : Reading DICOM files (this takes some time) ...', mfilename);
	for i = 1 : size (p.Results.KeyFields, 1)
		for j = 1 : size (all_DICOM, 1)
			dcm = dicominfo (fullfile (all_DICOM(j).folder, all_DICOM(j).name));
			if ~isfield (dcm, p.Results.KeyFields{i,1}) || ...
				isempty (dcm.(p.Results.KeyFields{i,1}))
				keyFields{j,i} = 'Field not exist or is empty';
			else
				keyFields {j,i} = dcm.(p.Results.KeyFields{i,1});
				if isnumeric (keyFields{j,i}) % convert numbers to strings, otherwise unique function doesn't work
					keyFields{j,i} = num2str (keyFields{j,i});
				end
			end
		end
	end
	fprintf (' DONE!\n');


	all_uniq_val = cell (size (p.Results.KeyFields,1), 1); % an N*1 cell array to save unique values for each field.

	for i = 1 : size (p.Results.KeyFields,1)
		all_uniq_val{i,1} = unique (keyFields (:,i));
		fprintf ('%s : Key field ''%s'' has %d different value(s):\n', mfilename, p.Results.KeyFields{i}, size(all_uniq_val{i,1},1));
		for j = 1 : size (all_uniq_val{i,1}, 1)
			fprintf ('  - %s\n', all_uniq_val{i,1}{j,1});
		end
	end


	fprintf ('%s : Note that the following fields do not exist or are empty. They may not be good fields to distinguish modalities.\n', mfilename);
	for i = 1 : size (p.Results.KeyFields,1)
		if any (strcmp (keyFields(:,i), 'Field not exist or is empty'))
			fprintf ('  - %s\n', p.Results.KeyFields{i,1});
		end
	end

	varargout{1} = cell (0,1); % suggested keyfield names
	varargout{2} = cell (0,1); % unique values of suggested keyfields

	fprintf ('%s : The following fields exist for all DICOM files, and can be used to distinguish modalities.\n', mfilename);
	for i = 1 : size (p.Results.KeyFields,1)
		if ~ any (strcmp (keyFields(:,i), 'Field not exist or is empty'))
			fprintf ('  - %s\n', p.Results.KeyFields{i,1});
			varargout{1}{end+1,1} = p.Results.KeyFields{i,1};
			varargout{2}{end+1,1} = all_uniq_val{i,1};
		end
	end

	fprintf ('%s : Finished (%s).\n', mfilename, string(datetime));
end

