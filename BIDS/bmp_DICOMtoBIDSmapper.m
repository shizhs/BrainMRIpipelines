function DICOM2BIDS = bmp_DICOMtoBIDSmapper (varargin)
%
% DESCRIPTION
% =================================================================================================
%
%   bmp_DICOMtoBIDSmapper generates DICOM-to-BIDS mappings. This is done by 1) passing, as 
%   arguments, a cell array of key DICOM fieldnames and a cell array of DICOM fieldvalues 
%   associated to them, or 2) passing the name of dataset which mapping has been preset. Curretly
%   available preset mappings include ADNI.
%
%
% ARGUMENTS
% ================================================================================================
%
%   Senario 1 : Let BMP suggest DICOM-to-BIDS mappings. Two input arguments are needed in thhis
%               senario:
%
%               varargin{1} = Cell array of DICOM key field names.
%
%               varargin{2} = Cell array of unique values in DICOM key fields specified in
%                             varargin{1}.
%
%               These two cell arrays can be generated by calling bmp_DICOMenquirer.
%
%
%   Senario 2 : Use predefined DICOM-to-BIDS mappings for public datasets or CHeBA datasets. One
%               input argument is needed in this senario:
%
%               varargin{1} = dataset name.
%
%               Currently supported datasets include 'ADNI'.
%
%
% SUPPORTED MODALITIES
% ================================================================================================
%
%   ----------------------------------------------
%   |   DATETYPE   |   MODALITY   |   KEYWORDS   |
%   ----------------------------------------------
%   |   anat       |   T1w        |   'MPRAGE'   |
%   |              |              |   'T1'       |
%   ----------------------------------------------
%   |   anat       |   FLAIR      |   'FLAIR'    |
%   ----------------------------------------------
%   |   dwi        |   dwi        |   'DTI'      |
%   ----------------------------------------------
%   |   perf       |   asl        |   'ASL'      |
%   ----------------------------------------------
%   
%   All keywords are case-insensitive.
%
%
% HISTORY
% ================================================================================================
%
%   04 December 2022 - first version.
%
%
% ==============================  END OF bmp_DICOMtoBIDSmapper HEADER ===========================



	supported_datasets = 	{
							'ADNI'
							};

	
	if nargin == 2

		fnam_arr = varargin{1};
		fval_arr = varargin{2};

		% Make guesses
		fprintf ('%s : Trying to suggest field(s) for DICOM-to-BIDS convertion.\n', mfilename);
		fprintf ('%s : ''SeriesDescription'' is prioritised from our experience.\n', mfilename);

		if any (strcmp (fnam_arr, 'SeriesDescription'))

			fprintf ('%s : ''SeriesDescription'' is found and used as key fieldname.\n', mfilename);

			fnam = 'SeriesDescription';

		elseif any (strcmp (fnam_arr, 'ProtocolName'))

			fprintf ('%s : ''SeriesDescription'' is not found. ''ProtocolName'' is found, and it is preferred after ''SeriesDescription''. Therefore, ''ProtocolName'' is used as key fieldname.\n', mfilename);

			fnam = 'ProtocolName';

		end

		fval = fval_arr{find (strcmp (fnam_arr, fnam)),1};


		% initialise 'criteria'
		clear criteria;
		criteria.T1w = struct();
		criteria.FLAIR = struct();
		criteria.dwi = struct();
		criteria.asl = struct();
		

		% Assuming 'SeriesDescription' and 'ProtocolName' sharing the same keywords
		for i = 1 : size (fval,1)

			% guess T1w DICOM-to-BIDS mapping
			% +++++++++++++++++++++++++++++++
			if contains (fval{i,1}, 'MPRAGE', IgnoreCase=true)

				fprintf ('%s : Substring ''MPRAGE'' (case-insensitive) exists in ''%s''. I guess this corresponds to T1w.\n', mfilename, fval{i,1});

				if ~ (isfield (criteria.T1w, 'fieldname') || isfield (criteria.T1w, 'fieldvalue')

					criteria.T1w(1).fieldname = fnam;
					criteria.T1w(1).fieldvalue = fval{i,1};

					% criteria.T1w(i)
					%              ^
					%              |
					%              --------- index used to identify all matched keywords.
					%                        The first element in the array, i.e., criteria.T1w(1),
					%                        is prioritised.

				else

					warning ('%s : ''MPRAGE'' (case-insensitive) has been found, which is thought to relate to T1w. However, it seems another criterion for T1w had already been found (''%s'' in field ''%s''). This criterion may have keyword ''T1'' (case-insensitive). Therefore, I am confused now. Both keyfields have been documented, but I''ll prefer keyword ''MPRAGE'' (case-insensitive).\n', mfilename, criteria.T1w.fieldvalue, criteria.T1w.fieldname);

					criteria.T1w(2).fieldname = criteria.T1w(1).fieldname;
					criteria.T1w(2).fieldvalue = criteria.T1w(1).fieldvalue;

					criteria.T1w(1).fieldname = fnam;
					criteria.T1w(1).fieldvalue = fval{i,1};

				end

			elseif contains (fval{i,1}, 'T1', IgnoreCase=true)

				fprintf ('%s : Substring ''T1'' (case-insensitive) exists in ''%s''. I guess this corresponds to T1w.\n', mfilename, fval{i,1});

				if ~ (isfield (criteria.T1w, 'fieldname') || isfield (criteria.T1w, 'fieldvalue')

					criteria.T1w(1).fieldname = fnam;
					criteria.T1w(1).fieldvalue = fval{i,1};

				else

					warning ('%s : ''T1'' (case-insensitive) has been found, which is thought to relate to T1w. However, it seems another criterion for T1w had already been found (''%s'' in field ''%s''). This criterion may have keyword ''MPRAGE'' (case-insensitive). Therefore, I am confused now. Both keyfields have been documented, but I''ll prefer keyword ''MPRAGE'' (case-insensitive).\n', mfilename, criteria.T1w.fieldvalue, criteria.T1w.fieldname);
				end

			end


			% guess FLAIR DICOM-to-BIDS mapping
			% +++++++++++++++++++++++++++++++++
			if contains (fval{i,1}, 'FLAIR', IgnoreCase=true)

				fprintf ('%s : Substring ''FLAIR'' (case-insensitive) exists in ''%s''. I guess this corresponds to T2-weighted FLAIR.\n', mfilename, fval{i,1});

				if ~ (isfield (criteria.FLAIR, 'fieldname') || isfield (criteria.FLAIR, 'fieldvalue'))

					criteria.FLAIR(1).fieldname = fnam;
					criteria.FLAIR(1).fieldvalue = fval{i,1};

				end

			end


			% guess dMRI DICOM-to-BIDS mapping
			% ++++++++++++++++++++++++++++++++
			if contains (fval{i,1}, 'DTI', IgnoreCase=true)

				fprintf ('%s : Substring ''DTI'' (case-insensitive) exists in ''%s''. I guess this corresponds to diffusion MRI.\n', mfilename, fval{i,1});

				if ~ (isfield (criteria.dwi, 'fieldname') || isfield (criteria.dwi, 'fieldvalue'))

					criteria.dwi(1).fieldname = fnam;
					criteria.dwi(1).fieldvalue = fval{i,1};

				end

			end


			% guess ASL DICOM-to-BIDS mapping
			% +++++++++++++++++++++++++++++++
			if contains (fval{i,1}, 'ASL', IgnoreCase=true)

				fprintf ('%s : Substring ''ASL'' (case-insensitive) exists in ''%s''. I guess this corresponds to ASL perfusion imaging.\n', mfilename, fval{i,1});

				if ~ (isfield (criteria.asl, 'fieldname') || isfield (criteria.asl, 'fieldvalue'))

					criteria.asl(1).fieldname = fnam;
					criteria.asl(1).fieldvalue = fval{i,1};

				end

			end

		end



		% suggest DICOM2BIDS for bmp_BIDSgenerator
		fprintf ('%s : Making suggestions for DICOM-to-BIDS mapping for bmp_BIDSgenerator.\n', mfilename);
		fprintf ('%s : These suggestions may only work for dataset-level mapping.\n', mfilename);


		clear DICOM2BIDS;

		if isfield (criteria.T1w, 'fieldname') && isfield (criteria.T1w, 'fieldvalue')

			DICOM2BIDS.anat.T1w.DICOM(1).(criteria.T1w(1).fieldname) = criteria.T1w(1).fieldvalue;

			% DICOM2BIDS.anat.T1w.DICOM(1)
			%                           ^
			%                           |
			%                           --------- In case multiple criteria to identify
			%                                     a modality. Will implement in the future.
			%
			% Note there's no DICOM2BIDS.anat.T1w.BIDS field here, as nothing to specify

		end

		if isfield (criteria.FLAIR, 'fieldname') && isfield (criteria.FLAIR, 'fieldvalue')

			DICOM2BIDS.anat.FLAIR.DICOM(1).(criteria.FLAIR(1).fieldname) = criteria.FLAIR(1).fieldvalue;

		end

		if isfield (criteria.dwi, 'fieldname') && isfield (criteria.dwi, 'fieldvalue')

			DICOM2BIDS.dwi.dwi.DICOM(1).(criteria.dwi(1).fieldname) = criteria.dwi(1).fieldvalue;

		end

		if isfield (criteria.asl, 'fieldname') && isfield (criteria.asl, 'fieldvalue')

			DICOM2BIDS.perf.asl.DICOM(1).(criteria.asl(1).fieldname) = criteria.asl(1).fieldvalue;

		end



	elseif nargin == 1 && any(strcmp(supported_datasets, varargin{1}))

			switch varargin{1}

				case 'ADNI'

					DICOM2BIDS = bmp_ADNI ('retrieve');

			end

	else

		error ('bmp_DICOMtoBIDSmapper:InvalidInputs',...
				'%s : Invalid inputs. Inputs should be 1) cell arrays of fieldnames and fieldvalues, or 2) name of supported datasets (e.g., ADNI).');

	end

end